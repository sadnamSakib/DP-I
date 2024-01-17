import 'package:design_project_1/screens/authentication/sign_in.dart';
import 'package:design_project_1/screens/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ForgotPassword extends StatefulWidget {
  static String id = 'forgot-password';
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  String email = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
final TextEditingController emailController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
  Future passwordReset() async {

    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
    } catch (e) {
      print(email);
    }
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Provide your email address',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                TextFormField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    icon: Icon(
                      Icons.mail,
                      color: Colors.white,
                    ),
                    errorStyle: TextStyle(color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade900,
                    fixedSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text('Send Email', style: TextStyle(fontSize: 18.0)),
                  onPressed: () {
                    passwordReset();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Wrapper()));
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
