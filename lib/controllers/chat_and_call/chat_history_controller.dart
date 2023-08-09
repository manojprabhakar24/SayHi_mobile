import 'dart:async';
import 'package:foap/apiHandler/apis/chat_api.dart';
import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:get/get.dart';
import '../../helper/localization_strings.dart';
import '../../screens/dashboard/dashboard_screen.dart';

class ChatHistoryController extends GetxController {
  final ChatDetailController _chatDetailController = Get.find();
  final DashboardController _dashboardController = Get.find();

  List<ChatRoomModel> allRooms = [];
  final RxList<ChatRoomModel> _searchedRooms = <ChatRoomModel>[].obs;
  RxMap<String, List<ChatRoomModel>> groupedRooms =
      <String, List<ChatRoomModel>>{}.obs;

  Map<String, dynamic> typingStatus = {};
  bool isLoading = false;

  getChatRooms() async {
    isLoading = true;
    allRooms = await getIt<DBManager>().getAllRooms();

    _searchedRooms.value = allRooms;
    update();

    // if (allRooms.isEmpty) {
    ChatApi.getChatRooms(resultCallback: (result) async {
      isLoading = false;
      List<ChatRoomModel> groupChatRooms = result
          // .where((element) => element.isGroupChat == true)
          .toList();
      await getIt<DBManager>().saveRooms(groupChatRooms);

      allRooms = await getIt<DBManager>().getAllRooms();
      // allRooms = await getIt<DBManager>().mapUnReadCount(groupChatRooms);
      _searchedRooms.value = allRooms;
      groupRooms();
      update();
    });
    // } else {
    //   isLoading = false;
    // }
  }

  groupRooms() {
    _searchedRooms.value = _searchedRooms.map((e) {
      ChatRoomModel room = e;
      if (e.lastMessage?.date.isToday == true || e.createAtDate.isToday) {
        room.roomDateForGrouping = todayString;
      } else if (e.lastMessage?.date.isThisWeek == true ||
          e.createAtDate.isThisWeek) {
        room.roomDateForGrouping = thisWeekString;
      } else if (e.lastMessage?.date.isThisMonth == true ||
          e.createAtDate.isThisMonth) {
        room.roomDateForGrouping = thisMonthString;
      } else {
        room.roomDateForGrouping = earlierString;
      }
      return room;
    }).toList();
    groupedRooms.value = _searchedRooms.groupBy((m) => m.roomDateForGrouping);
    update();
  }

  searchTextChanged(String text) {
    if (text.isEmpty) {
      _searchedRooms.value = allRooms;
      groupRooms();
      return;
    }
    _searchedRooms.value = allRooms.where((room) {
      if (room.isGroupChat) {
        return room.name!.toLowerCase().contains(text);
      } else {
        return room.opponent.userDetail.userName.toLowerCase().contains(text);
      }
    }).toList();
    groupRooms();
    update();
  }

  clearUnreadCount({required ChatRoomModel chatRoom}) async {
    getIt<DBManager>().clearUnReadCount(roomId: chatRoom.id);
    int roomsWithUnreadMessageCount =
        await getIt<DBManager>().roomsWithUnreadMessages();
    _dashboardController.updateUnreadMessageCount(roomsWithUnreadMessageCount);

    getChatRooms();
    update();
  }

  deleteRoom(ChatRoomModel chatRoom) {
    allRooms.removeWhere((element) => element.id == chatRoom.id);
    getIt<DBManager>().deleteRooms([chatRoom]);
    update();
    ChatApi.deleteChatRoom(chatRoom.id);
  }

  // ******************* updates from socket *****************//

  newMessageReceived(ChatMessageModel message) async {
    List<ChatRoomModel> existingRooms =
        allRooms.where((room) => room.id == message.roomId).toList();

    if (existingRooms.isNotEmpty &&
        message.roomId != _chatDetailController.chatRoom.value?.id) {
      ChatRoomModel room = existingRooms.first;
      room.lastMessage = message;
      room.whoIsTyping.remove(message.userName);
      typingStatus[message.userName] = null;

      // room.unreadMessages += 1;
      // allRooms.refresh();
      _searchedRooms.refresh();
      update();
      getIt<DBManager>().updateUnReadCount(roomId: message.roomId);
    }

    getChatRooms();
  }

  userTypingStatusChanged(
      {required String userName, required int roomId, required bool status}) {
    var matchedRooms = allRooms.where((element) => element.id == roomId);

    if (matchedRooms.isNotEmpty) {
      var room = matchedRooms.first;

      if (typingStatus[userName] == null) {
        room.whoIsTyping.add(userName);
        _searchedRooms.refresh();
      }

      typingStatus[userName] = DateTime.now();

      // room.isTyping = status;
      // searchedRooms.refresh();
      // update();
      if (status == true) {
        Timer(const Duration(seconds: 5), () {
          if (typingStatus[userName] != null) {
            if (DateTime.now().difference(typingStatus[userName]!).inSeconds >
                4) {
              room.whoIsTyping.remove(userName);
              typingStatus[userName] = null;
              _searchedRooms.refresh();
              update();
            }
          }
        });
      }
      update();
    }
  }

  userAvailabilityStatusChange({required int userId, required bool isOnline}) {
    var matchedRooms =
        allRooms.where((element) => element.opponent.id == userId);

    if (matchedRooms.isNotEmpty) {
      var room = matchedRooms.first;
      room.isOnline = isOnline;
      room.opponent.userDetail.isOnline = isOnline;
      _searchedRooms.refresh();
      // update();
    }
  }
}
