import 'dart:convert';
import 'package:design_project_1/screens/authentication/resetPassword.dart';
import 'package:design_project_1/screens/wrapper.dart';
import 'package:design_project_1/services/authServices/auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
// import 'message.dart';
import 'models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:design_project_1/services/notificationServices/notification_services.dart';
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
    1,
    callback,
    exact: true,
  );
}

void callback() {

  deleteSharedPreferenceData();
}
Future<void> deleteSharedPreferenceData() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.clear();
}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp();
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      value: AuthService().user,
      initialData: UserModel(uid: ''),

      child: MaterialApp(


        title: 'DocLinkr',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          ForgotPassword.id: (context) => const ForgotPassword(),


        },
        home: const Wrapper(),
      ),
    );
  }
}


