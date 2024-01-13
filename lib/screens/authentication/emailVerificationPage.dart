import 'dart:async';
import 'package:design_project_1/screens/authentication/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/UserModel.dart';
import '../../services/authServices/auth.dart';
import '../../main.dart';
import '../wrapper.dart';
import 'chooseRole.dart';

class EmailVerificationPage extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  const EmailVerificationPage( {super.key,  required this.name , required this.email,required this.password});

  @override
  State<EmailVerificationPage> createState() =>

      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final AuthService _auth = AuthService();
  bool isEmailVerified = false;
  Timer? timer;
  @override
  initState()   {
    _auth.registerWithEmailAndPassword(widget.name, widget.email, widget.password);
    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  checkEmailVerified() async {
    if(FirebaseAuth.instance.currentUser == null){
      return;
    }
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email Successfully Verified")));

      timer?.cancel();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  RoleSelectionPage()));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Check your \n Email',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'We have sent you a Email on  ${widget.email}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets
                    .symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'Verifying email....',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 57),
              Padding(
                padding: const EdgeInsets
                    .symmetric(horizontal: 32.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade900,
                    onPrimary: Colors.white,
                    fixedSize: const Size(100, 50),
                  ),
                  child: const Text('Resend'),
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
                    } catch (e) {
                      debugPrint('$e');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}