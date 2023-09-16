import 'package:design_project_1/services/auth.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool _showSignIn = true;


  void toggleView() {
    setState(() {
      _showSignIn = !_showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showSignIn ? 'Sign In' : 'Sign Up'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: _showSignIn
            ? SignInForm(toggleView: toggleView)
            : SignUpForm(toggleView: toggleView),
      ),
    );
  }
}

class SignInForm extends StatelessWidget {
  final VoidCallback toggleView;
  final AuthService _auth = AuthService();

   SignInForm({ required this.toggleView});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
    const TextField(
    decoration: InputDecoration(labelText: 'Email'),
    ),
    const SizedBox(height: 10.0),
    const TextField(
    decoration: InputDecoration(labelText: 'Password'),
    obscureText: true,
    ),
    const SizedBox(height: 20.0),
    ElevatedButton(
    child: const Text('Sign In'),
    onPressed: () async{
    dynamic res = await _auth.signInAnon();
    if(res == null){
    print('error signing in');
    }else{
    print('signed in');
    print(res);
    }
    }
    ),
    TextButton(
    onPressed: toggleView,
    child: const Text('Don\'t have an account? Sign Up'),
    ),
    Text('Or sign in with:'),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    IconButton(
    onPressed: () {},
    icon: const Icon(Icons.facebook),
    ),
    IconButton(
    onPressed: () {},
    icon: const Icon(Icons.email),
    ),
    ],
    ),
    ],
    );
    }
  }

  class SignUpForm extends StatelessWidget {
  final VoidCallback toggleView;

  SignUpForm({ required this.toggleView});

  @override
  Widget build(BuildContext context) {
  var google;
  return Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
  TextField(
  decoration: InputDecoration(labelText: 'Email'),
  ),
  SizedBox(height: 10.0),
  TextField(
  decoration: InputDecoration(labelText: 'Password'),
  obscureText: true,
  ),
  SizedBox(height: 20.0),
  ElevatedButton(
  onPressed: () {},
  child: Text('Sign Up'),
  ),
  TextButton(
  onPressed: toggleView,
  child: Text('Already have an account? Sign In'),
  ),
  Text('Or sign up with:'),
  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  IconButton(
  onPressed: () {},
  icon: const Icon(Icons.facebook),
  ),
  IconButton(
  onPressed: () {},
  icon: Icon(Icons.facebook_rounded),
  ),
  ],
  ),
  ],
  );
  }
  }