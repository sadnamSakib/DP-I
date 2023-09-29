import 'package:flutter/material.dart';

import '../../services/auth.dart';
class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp({required this.toggleView});
  //const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIgn Up'),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Form(
            key: _formKey,
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      dynamic result = await _auth.registerWithEmailAndPassword(
                          email, password);
                      if (result == null) {
                        setState(() {
                          error = 'Please supply a valid email';
                        });
                      } else {
                        print('signed in');
                        print(result.uid);
                      }
                    }
                  },
                  child: const Text('Register'),
                ),
                const SizedBox(height: 20.0),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14.0),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Aligns the children to the center horizontally
                    children: [
                      SizedBox(height: 20.0),
                      Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          widget.toggleView();
                        },
                        child: Text('Sign In'),
                      ),
                    ],
                  ),
                )

              ],
            ),
          )
      ),
    );
  }
}

