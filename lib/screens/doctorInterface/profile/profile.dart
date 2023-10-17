import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
      body: SafeArea(
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Center(
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
                              child:
                              Image(
                                fit: BoxFit.cover,
                                // image: NetworkImage(userData['image'].toString()),

                                image: NetworkImage('https://images.unsplash.com/photo-1551884170-09fb70a3a2ed?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=876&q=80'),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context,object,stack){
                                  return Container(
                                    child: Icon(Icons.error_outline, color:Colors.redAccent ,),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40,),
                        ReusableRow(title: 'Username', value: userData?['name'], iconData: Icons.person_2_outlined),
                        ReusableRow(title: 'Email', value: userData?['email'], iconData: Icons.email_outlined),
                        ReusableRow(title: 'Phone', value: userData?['phone'] ?? 'xxx-xxx-xxx', iconData: Icons.phone_android),

                      ],
                    );

                  }

              else {
                return Center(child: Text('Something went wrong', style: Theme.of(context).textTheme.displayMedium));
            }

            }

        ),
      ),
    ),
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
        Divider(color: Colors.white),
      ],
    );

  }
}
