import 'package:design_project_1/screens/authentication/resetPassword.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/authServices/auth.dart';

import '../../utilities/squareTile.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
          backgroundColor: Colors.blue.shade900,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  TextFormField(
                    validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) {
                      setState(()=>  email = val);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                    onChanged: (val) {
                      setState(()=>  password = val);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue.shade900,
                      onPrimary: Colors.white,
                      fixedSize: const Size(100, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        //print('valid');
                        dynamic result = await _auth.signInWithEmailAndPassword(
                            email, password);
                        if (result == null) {
                          setState(() {
                            error = 'Could not sign in with those credentials';
                          });
                        }
                      }
                    },
                    child: const Text('Sign In', style: TextStyle(fontSize: 20.0)),
                    ),
                  const SizedBox(height: 20.0),
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 20.0),
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context, MaterialPageRoute(builder: (context)
                                {
                                  return ForgotPassword();
                                },
                              ),
                            );
                          },
                          child: Text('Forgot Password?'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.0),
                            Text('Don\'t have an account?'),
                            TextButton(
                              onPressed: () {
                                widget.toggleView();
                              },
                              child: Text('Register'),
                            ),
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:[
                              //google button
                              Text("or Login with "),
                              SquareTile(
                                onTap: () async {
                                  dynamic result = await _auth.signInWithGoogle();
                                  if (result == null) {
                                    setState(() {
                                      error = 'Could not sign in with those credentials';
                                    });
                                  }
                                },
                                imagePath: 'assets/images/google.png',
                              ),

                            ]
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
    );
  }
}
