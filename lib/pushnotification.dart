// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import 'main.dart'; // Assuming you have defined navigatorKey in main.dart
// import 'message.dart'; // Make sure this import is correct based on your project structure
//
// class PushNotifications {
//   static final _firebaseMessaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   // request notification permission
//   static Future<void> init() async {
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//     // get the device fcm token
//     final token = await _firebaseMessaging.getToken();
//     print("device token: $token");
//   }
//
//   // initialize local notifications
//   static Future<void> localNotificationInit() async {
//     // initialise the plugin. app_icon needs to be added as a drawable resource to the Android head project
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//     final InitializationSettings initializationSettings =
//     InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: onNotificationTap,
//     );
//   }
//
//   // on tap local notification in foreground
//   static void onNotificationTap(ReceivedNotification receivedNotification) {
//     navigatorKey.currentState!
//         .pushNamed("/message", arguments: receivedNotification.payload);
//   }
//
//   // show a simple notification
//   static Future<void> showSimpleNotification({
//     required String title,
//     required String body,
//     required String payload,
//   }) async {
//     const AndroidNotificationDetails androidNotificationDetails =
//     AndroidNotificationDetails(
//       'your channel id',
//       'your channel name',
//       : 'your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );
//     const NotificationDetails notificationDetails =
//     NotificationDetails(android: androidNotificationDetails);
//     await _flutterLocalNotificationsPlugin
//         .show(0, title, body, notificationDetails, payload: payload);
//   }
// }
