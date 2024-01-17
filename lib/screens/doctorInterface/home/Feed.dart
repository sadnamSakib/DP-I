import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/emergencyPortal/Emergency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/authServices/auth.dart';

import '../schedule/dayBasedSchedule.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();

}


Stream<DocumentSnapshot> getUserData() {
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  return FirebaseFirestore.instance.collection('users').doc(userUID).snapshots();

}

Stream<DocumentSnapshot> getDoctorData() {
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  return FirebaseFirestore.instance.collection('doctors').doc(userUID).snapshots();
}


class _FeedState extends State<Feed> {

  final AuthService _auth = AuthService();

  List<ScheduleItem> dayItems = [];


  void fetchSchedule(String today) async {
    print(today);
    dayItems.clear();
    final scheduleCollection = FirebaseFirestore.instance.collection(
        'Schedule');
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final scheduleQuery = scheduleCollection.doc(userUID);
    final dayScheduleQuery = await scheduleQuery.collection('Days').doc(
        today).collection('Slots').get();
      print(dayScheduleQuery.docs.length);

    for (final slots in dayScheduleQuery.docs) {
      final id = slots.id;
      final startTime = slots['Start Time'];
      final endTime = slots['End Time'];
      final sessionType = slots['Session Type'];
      final numberOfPatients = slots['Number of Patients'];
      setState(() {
        dayItems.add(ScheduleItem(
          ID : id,
          startTime: startTime,
          endTime: endTime,
          sessionType: sessionType,
          numberOfPatients: numberOfPatients,
        ));
      });

    }

    // return schedule;
  }
  @override
  void initState() {
    super.initState();
    List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String today = days[DateTime.now().weekday - 1];
    print(today);

    fetchSchedule(today);
    // print(schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink.shade900,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text('DocLinkr'),

          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.pink.shade50],
          ),
        ),

          child: Column(
            // // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: getUserData(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final userData = snapshot.data?.data() as Map<String, dynamic>;
                    final username = userData['name'] as String;
                    return Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Welcome to DocLinkr,',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '$username',
                          style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,

                        ),
                      ],

                    );
                  },
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Your Schedule for today',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: dayItems.length,
                  itemBuilder: (context, index) {
                    final item = dayItems[index];
                    return Card(
                      child: ListTile(
                        title: Text("Session: " + item.sessionType),
                        subtitle: Text("Time: " + item.startTime + ' - ' + item.endTime),
                        trailing: Text("Patients: " + item.numberOfPatients.toString()),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

      ),
    );
  }
}