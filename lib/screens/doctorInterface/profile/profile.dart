import 'dart:io';

import 'package:design_project_1/services/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => ProfileController(),
        child: Consumer<ProfileController>(
          builder: (context,provider,child){
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child:StreamBuilder<DocumentSnapshot>(
                    stream : users.doc(userUID).snapshots(),

                    builder: (context,snapshot)
                    {
                      if(!snapshot.hasData)
                      {
                        return Center(child: CircularProgressIndicator());
                      }else if(snapshot.hasData)
                      {
                        Map<dynamic, dynamic>? userData = snapshot.data?.data() as Map<dynamic, dynamic>?;
                        String imageURL = userData?['profile'] ?? '';

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Stack(
                                alignment: Alignment.bottomCenter,

                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal:15 ),
                                    child: Center(
                                      child: Container(
                                        height: 130,
                                        width: 130,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border:  Border.all(
                                                color: Color(0xFF2144F3),
                                                width: 5
                                            )
                                        ),
                                        child: ClipOval(

                                          child:provider.image == null ?

                                          (imageURL.isEmpty)
                                              ? Icon(Icons.person_2_outlined, size: 35)
                                              : Image.network(
                                            imageURL,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(child: CircularProgressIndicator());
                                            },
                                            errorBuilder: (context,object,stack){
                                              return Container(
                                                child: Icon(Icons.error_outline, color:Colors.redAccent ,),
                                              );
                                            },
                                          ):

                                              Image.file(
                                                File(provider.image!.path).absolute
                                              )
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap:(){
                                   provider.pickImage(context);
                                    },
                                    child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.black,
                                        child: Icon(Icons.add , size:18, color: Colors.white)
                                    ),
                                  )


                                ],
                              ),
                              const SizedBox(height: 40,),
                              ReusableRow(title: 'Username', value: userData?['name'], iconData: Icons.person_2_outlined),
                              ReusableRow(title: 'Email', value: userData?['email'], iconData: Icons.email_outlined),
                              ReusableRow(title: 'Phone', value: userData?['phone'] ?? 'xxx-xxx-xxx', iconData: Icons.phone_android),

                            ],
                          ),
                        );

                      }

                      else {
                        return Center(child: Text('Something went wrong', style: Theme.of(context).textTheme.displayMedium));
                      }

                    }

                ),
              ),
            );
          },
        ),
      )





    );
  }
}


class ReusableRow extends StatelessWidget {

  final String title,value;
  final IconData iconData;
  const ReusableRow({Key? key, required this.title, required this.iconData, required this.value}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: Icon(iconData),
          trailing: Text(value),
        ),
    Divider(color: Colors.white.withOpacity(0.5))
      ],
    );

  }
}
