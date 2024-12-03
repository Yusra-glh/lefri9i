// import 'package:flutter/cupertino.dart';
// import 'package:raven/models/local_notification.dart';

// class NotificationSingleton extends ChangeNotifier {
//   List<LocalNotificationModel> localNotifs = [];
//   static final NotificationSingleton _index = NotificationSingleton._internal();
//   NotificationSingleton._internal();
//   factory NotificationSingleton() {
//     return _index;
//   }
//   addNotif(LocalNotificationModel notif) {
//     localNotifs.add(notif);
//     notifyListeners();
//   }

//   LocalNotificationModel? getNotif(String notifId) {
//     var index = localNotifs.indexWhere((element) => element.id == notifId);
//     if (index != -1) {
//       return localNotifs[index];
//     }
//     return null;
//   }
// }

// final notificationSingleton = NotificationSingleton();
