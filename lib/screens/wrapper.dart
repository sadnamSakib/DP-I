import 'package:design_project_1/screens/authentication/authenticate.dart';
import 'package:design_project_1/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/UserModel.dart';
class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    print(user);
    if(user == null)
      return Authenticate();
    else
      return Home();
  }
}
