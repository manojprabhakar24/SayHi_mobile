import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../components/search_bar.dart';
import '../calling/call_history.dart';
import '../settings_menu/settings_controller.dart';

class ChatHistory extends StatefulWidget {
  const ChatHistory({Key? key}) : super(key: key);

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  final ChatHistoryController _chatController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();
  final SettingsController _settingsController = Get.find();

  @override
  void initState() {
    super.initState();
    _chatController.getChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColorConstants.backgroundColor,
      floatingActionButton: Container(
        height: 50,
        width: 50,
        color: AppColorConstants.themeColor,
        child: const ThemeIconWidget(
          ThemeIcon.edit,
          size: 25,
          color: Colors.white,
        ),
      ).circular.ripple(() {
        selectUsers();
      }).bP16,
      body: KeyboardDismissOnTap(
          child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ThemeIconWidget(
                ThemeIcon.backArrow,
              ).ripple(() {
                Get.back();
              }),
              BodyLargeText(chatsString.tr, weight: TextWeight.medium),
              _settingsController.setting.value!.enableAudioCalling ||
                      _settingsController.setting.value!.enableVideoCalling
                  ? ThemeIconWidget(
                      ThemeIcon.mobile,
                      color: AppColorConstants.iconColor,
                      size: 25,
                    ).ripple(() {
                      Get.to(() => const CallHistory());
                    })
                  : const SizedBox(
                      width: 25,
                    ),
            ],
          ).setPadding(
              left: DesignConstants.horizontalPadding,
              right: DesignConstants.horizontalPadding,
              top: 8,
              bottom: 16),
          SFSearchBar(
                  showSearchIcon: true,
                  iconColor: AppColorConstants.themeColor,
                  onSearchChanged: (value) {
                    _chatController.searchTextChanged(value);
                  },
                  onSearchStarted: () {
                    //controller.startSearch();
                  },
                  onSearchCompleted: (searchTerm) {})
              .p16,
          Expanded(child: chatListView())
        ],
      )),
    );
  }

  Widget chatListView() {
    return GetBuilder<ChatHistoryController>(
        init: _chatController,
        builder: (ctx) {
          return _chatController.groupedRooms.keys.isNotEmpty
              ? ListView.separated(
                  padding: EdgeInsets.only(
                      top: 20,
                      bottom: 50,
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding),
                  itemCount: _chatController.groupedRooms.keys.length,
                  itemBuilder: (BuildContext context, int index) {
                    String key =
                        _chatController.groupedRooms.keys.toList()[index];
                    List<ChatRoomModel> rooms =
                        _chatController.groupedRooms[key] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Heading5Text(
                          key,
                          weight: TextWeight.bold,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        for (ChatRoomModel room in rooms)
                          Column(
                            children: [
                              Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) {
                                  _chatController.deleteRoom(room);
                                },
                                background: Container(
                                  color: AppColorConstants.red,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Heading6Text(
                                        deleteString.tr,
                                        weight: TextWeight.bold,
                                        color: AppColorConstants.grayscale700,
                                      )
                                    ],
                                  ),
                                ),
                                child: ChatHistoryTile(model: room)
                                    .ripple(() async {
                                  _chatController.clearUnreadCount(
                                      chatRoom: room);

                                  Get.to(() => ChatDetail(chatRoom: room))!
                                      .then((value) {
                                    _chatController.getChatRooms();
                                  });
                                }),
                              ),
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return divider(height: 0.2).vP8;
                  })
              : emptyData(
                  title: noNotificationFoundString,
                  subTitle: '',
                );
        });
  }

  void selectUsers() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: SelectUserForChat(userSelected: (user) {
                _chatDetailController.getChatRoomWithUser(
                    userId: user.id,
                    callback: (room) {
                      EasyLoading.dismiss();

                      Get.close(1);
                      Get.to(() => ChatDetail(
                                // opponent: usersList[index - 1].toChatRoomMember,
                                chatRoom: room,
                              ))!
                          .then((value) {
                        _chatController.getChatRooms();
                      });
                    });
              }),
            ));
  }
}
