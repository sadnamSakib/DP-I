import 'dart:io';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:design_project_1/screens/doctorInterface/emergencyPortal/emergencyRequests.dart';
import 'package:design_project_1/screens/patientInterface/medications/currentPrescription.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      onDidReceiveNotificationResponse: (payload) async {
        debugPrint('notification payload: $payload');
        handleMessage(context, message);
      },
      onDidReceiveBackgroundNotificationResponse: (payload) async {
        debugPrint('notification payload: $payload');
        handleMessage(context, message);
      },
    );
  }
  Future<void> firebaseInit(BuildContext context) async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
      }
      showNotification(title: message.notification!.title.toString(), body: message.notification!.body.toString(), payload: message.data.toString());
        initLocalNotification(context, message);
        print(message.notification!.title.toString());


    });
  }

  static Future showNotification({required String title, required String body, required String payload}) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'high_priority_channel',
      'high_priority_channel',
      importance: Importance.high,
      priority: Priority.max,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      0, title, body, notificationDetails, payload: payload,

    );
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
  Future<void> setupInteractMessage(BuildContext context) async {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      handleMessage(context, message);
    });
  }
  void handleMessage(BuildContext context, RemoteMessage message) {
    print("handle message cholse");
    if(message.data['type'] == 'nightmed'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => CurrentPrescriptionScreen(medicationTime: 'night')));
    }
    else if(message.data['type'] == 'morningmed'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => CurrentPrescriptionScreen(medicationTime: 'morning')));
    }
    else if(message.data['type'] == 'noonmed'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => CurrentPrescriptionScreen(medicationTime: 'noon')));
    }
    else if(message.data['type'] == 'emergency'){
      Navigator.push(context, MaterialPageRoute(builder: (context) =>  EmergencyRequestList()));
    }
  }

}