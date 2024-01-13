import 'package:flutter/material.dart';
import '../../services/authServices/auth.dart';
import '../../utilities/squareTile.dart';
import 'chooseRole.dart';
import 'emailVerificationPage.dart';
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
  String name = '';
  String confirmPassword = '';

  bool matchPassword(){
    if(password != confirmPassword){
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
                    validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                    onChanged: (val) {
                      setState(()=>  name = val);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Full name',
                    ),
                  ),
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
                  TextFormField(
                    validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                    onChanged: (val) {
                      setState(()=>  confirmPassword = val);
                      if(!matchPassword()){
                        setState(() {
                          error = 'Passwords do not match';

                        });
                      }
                      else{
                        setState(() {
                          error = '';
                        });
                        ;
                      }

                    },
                    decoration: const InputDecoration(
                      hintText: 'Confirm password',
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

                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmailVerificationPage(
                                  name: name,
                                  email: email,
                                  password: password,
                                ),
                              ),
                            );
                            print("Navigation success jayna");
                          } catch (e) {
                            print("Navigation error jayna: $e");
                          }

                          print('signed in');


                      }
                    },
                    child: const Text('Register', style: TextStyle(fontSize: 18.0)),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Aligns the children to the center horizontally
                          children: [
                            SizedBox(height: 20.0),
                            Text('Already have an account?', style: TextStyle(fontSize: 16.0)),
                            TextButton(
                              onPressed: () {
                                widget.toggleView();
                              },
                              child: Text('Sign In', style: TextStyle(fontSize: 16.0)),
                            ),
                          ],

                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            //google button
                             Text('Or, Sign up with', style: TextStyle(fontSize: 16.0)),
                           SquareTile(
                               onTap: () async {
                                 dynamic result = await _auth.registerWithGoogle();
                                 if (result == null) {
                                   setState(() {
                                     error = 'Could not sign in with those credentials';
                                   });
                                 }
                                 else{
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RoleSelectionPage(),
                                      ),
                                    );
                                 }
                               },
                                imagePath: 'assets/images/google.png',
                                ),
                          ]
                        )
                      ],

                      )
                    ),
                ],
              ),
            ),
          )
      ),
    );
  }
}

