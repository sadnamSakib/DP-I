import 'dart:io';
import 'package:rxdart/rxdart.dart';
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
  CollectionReference doctors = FirebaseFirestore.instance.collection('doctors');

  // Create a combined stream
  late Stream<DocumentSnapshot> combinedStream;

  @override
  void initState() {
    super.initState();

    // Merge the streams using rxdart's StreamGroup
    combinedStream = Rx.combineLatest2(
      users.doc(userUID).snapshots(),
      doctors.doc(userUID).snapshots(),
          (userSnapshot, doctorSnapshot) {
        // You can merge and process the data from both snapshots here if needed
        // For simplicity, you can just return one of the snapshots
        return userSnapshot;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => ProfileController(),
        child: Consumer<ProfileController>(
          builder: (context, provider, child) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: combinedStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
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
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  child: Center(
                                    child: Container(
                                      height: 130,
                                      width: 130,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Color(0xFF2144F3),
                                          width: 5,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: provider.image == null
                                            ? (imageURL.isEmpty)
                                            ? Icon(Icons.person_2_outlined, size: 35)
                                            : Image.network(
                                          imageURL,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (context, object, stack) {
                                            return Container(
                                              child: Icon(Icons.error_outline, color: Colors.redAccent),
                                            );
                                          },
                                        )
                                            : Stack(
                                          children: [
                                            Image.file(
                                              File(provider.image!.path).absolute,
                                            ),
                                            Center(child: CircularProgressIndicator()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    provider.pickImage(context);
                                  },
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.black,
                                    child: Icon(Icons.add, size: 18, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            GestureDetector(
                              onTap: () {
                                provider.showUserNameDialogueAlert(context, userData?['name'] ?? '');
                              },
                              child: ReusableRow(title: 'Username', value: userData?['name'], iconData: Icons.person_2_outlined),
                            ),
                            GestureDetector(
                              onTap: () {
                                provider.showEmailDialogueAlert(context, userData?['email'] ?? '');
                              },
                              child: ReusableRow(title: 'Email', value: userData?['email'], iconData: Icons.email_outlined),
                            ),
                            GestureDetector(
                              onTap: () {
                                provider.showPhoneNumberDialogueAlert(context, userData?['phone'] ?? '');
                              },
                              child: ReusableRow(title: 'Phone', value: userData?['phone'] ?? 'xxx-xxx-xxx', iconData: Icons.phone_android),
                            ),

                            StreamBuilder<DocumentSnapshot>(
                              stream: doctors.doc(userUID).snapshots(),
                              builder: (context, doctorSnapshot) {
                                if (!doctorSnapshot.hasData) {
                                  return Center(child: CircularProgressIndicator());

                                } else if (doctorSnapshot.hasData) {
                                  Map<dynamic, dynamic>? doctorData = doctorSnapshot.data?.data() as Map<dynamic, dynamic>?;
                                  List<dynamic>? degreesList = doctorData?['degrees'];

                                  List<String>? degrees = degreesList?.map((degree) => degree.toString()).toList();

                                  String degreesString = degrees?.join(', ') ?? 'N/A';
                                  return Column(
                                    children: [
                                      ReusableRow(title: 'Chamber Address', value: doctorData?['chamberAddress'] ?? 'xxx-xxx-xxx', iconData: Icons.house),
                                      ReusableRow(title: 'Degrees', value: degreesString, iconData: Icons.list_alt_outlined),
                                      ReusableRow(title: 'specialization', value: doctorData?['specialization'] ?? 'xxx-xxx-xxx', iconData: Icons.star), // Add more rows as needed
                                    ],
                                  );
                                }
                                else{
                                  return Center(child: Text('Something went wrong', style: Theme.of(context).textTheme.displayMedium));

                                }
                              },
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(child: Text('Something went wrong', style: Theme.of(context).textTheme.displayMedium));
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// class ReusableRow extends StatelessWidget {
//   final String title;
//   final String? value;
//   final IconData iconData;
//
//   const ReusableRow({Key? key, required this.title, required this.iconData, this.value}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ListTile(
//           title: Text(title),
//           leading: Icon(iconData),
//           trailing: Text(value ?? 'N/A'),
//         ),
//         Divider(color: Colors.white.withOpacity(0.5)),
//       ],
//     );
//   }
// }
class ReusableRow extends StatelessWidget {
  final String title;
  final String? value;
  final IconData iconData;

  const ReusableRow({Key? key, required this.title, required this.iconData, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15), // Add more space at the bottom
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueGrey, // Change the background color to your desired color
        borderRadius: BorderRadius.circular(10), // Add rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1), // Color of the shadow
            spreadRadius: 1.5, // Spread radius
            blurRadius: 8, // Blur radius
            offset: Offset(0, 2), // Offset of the shadow
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Icon(
          iconData,
          color: Colors.white,
        ),
        trailing: Text(
          value ?? 'N/A',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
