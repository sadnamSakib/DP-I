 import 'package:design_project_1/screens/authentication/resetPassword.dart';
import 'package:design_project_1/screens/wrapper.dart';
import 'package:design_project_1/services/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/UserModel.dart';
Future main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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


