import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true
    );


    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted permission");
    }
    else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("user granted provisional permission");
    } else {
      AppSettings.openAppSettings();
      print("user denied permission");
    }
  }

  void initLocalNotification(BuildContext context,
      RemoteMessage message) async {
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    // var iosInitializationSettings = DarwinI();

    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
    );
//
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onSelectNotification: (String? payload){
        print("Notification clicked with payload: $payload");
        return Future.value(null);
      },

    );


  }

  void firebaseInit() =>

      FirebaseMessaging.onMessage.listen((message) {
        if (kDebugMode) {
          print(message.notification!.title.toString());
          print(message.notification!.body.toString());
        }

        showNotification(message);
      });
  Future <void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      'High Importance Channel',
      'CHANNEL DESCRIPTION',
      importance: Importance.max,


    );


    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        'CHANNEL DESCRIPTION',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker'
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,

    );
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print("REFRESH        ");
    });
  }

}