import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import '../../api_handler/apis/misc_api.dart';
import '../../model/notification_modal.dart';

class NotificationController extends GetxController {
  List<NotificationModel> filteredNotifications = [];
  List<NotificationModel> allNotification = [];

  RxList<NotificationType> selectedNotificationsTypes =
      <NotificationType>[].obs;

  RxMap<String, List<NotificationModel>> groupedNotifications =
      <String, List<NotificationModel>>{}.obs;

  filterNotifications() {
    if (selectedNotificationsTypes.isNotEmpty) {
      filteredNotifications = allNotification
          .where((element) => selectedNotificationsTypes.contains(element.type))
          .toList();
    } else {
      filteredNotifications = allNotification;
    }
    filteredNotifications = filteredNotifications.map((e) {
      NotificationModel notification = e;
      if (e.date.isToday) {
        notification.notificationDate = todayString.tr;
      } else if (e.date.isThisWeek) {
        notification.notificationDate = thisWeekString.tr;
      } else if (e.date.isThisMonth) {
        notification.notificationDate = thisMonthString.tr;
      } else {
        notification.notificationDate = earlierString.tr;
      }
      return notification;
    }).toList();
    groupedNotifications.value =
        filteredNotifications.groupBy((m) => m.notificationDate);
    update();
  }

  getNotifications() {
    MiscApi.getNotifications(resultCallback: (result, metadata) {
      allNotification = result;
      filterNotifications();
    });
  }

  selectNotificationType(NotificationType type) {
    if (selectedNotificationsTypes.contains(type)) {
      selectedNotificationsTypes.remove(type);
    } else {
      selectedNotificationsTypes.add(type);
    }
  }
}
