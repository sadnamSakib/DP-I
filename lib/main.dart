import 'dart:convert';

import 'package:design_project_1/pushnotification.dart';
import 'package:design_project_1/screens/authentication/resetPassword.dart';
import 'package:design_project_1/screens/wrapper.dart';
import 'package:design_project_1/services/auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'message.dart';
import 'models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'package:firebase_analytics/firebase_analytics.dart';



Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AndroidAlarmManager.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler) ;

  runApp(const MyApp());
  final alarmTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      0, 1); // 3:00 PM

  AndroidAlarmManager.oneShotAt(
    alarmTime,
    1,  // An ID to identify this alarm
    callback,  // The function to call when the alarm triggers
    exact: true,  // Trigger alarm at the exact time
  );
}

void callback() {
  // This function will be executed when the alarm triggers
  deleteSharedPreferenceData();
}
Future<void> deleteSharedPreferenceData() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.clear();
}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp();
  print(message.notification!.title.toString());
  print(message.notification!.body.toString());

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      value: AuthService().user,
      initialData: UserModel(uid: ''),

      child: MaterialApp(
        // navigatorKey: navigatorKey,

        title: 'DocLinkr',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          ForgotPassword.id: (context) => const ForgotPassword(),
          // '/message': (context) => const Message()

        },
        home: const Wrapper(),
      ),
    );
  }
}


