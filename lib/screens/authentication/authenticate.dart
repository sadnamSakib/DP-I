import 'package:design_project_1/screens/authentication/sign_up.dart';
import 'package:flutter/material.dart';
import 'sign_in.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool _showSignIn = true;

  void toggleView() {
    setState(() => _showSignIn = !_showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if(_showSignIn)
      return SignIn(toggleView: toggleView);
    else
      return SignUp(toggleView: toggleView);
  }
}