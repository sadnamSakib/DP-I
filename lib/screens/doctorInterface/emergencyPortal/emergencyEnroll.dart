import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Emergency.dart';
import 'emergencyRequests.dart';
class EnrollAsEmergencyDoctor extends StatefulWidget {
  const EnrollAsEmergencyDoctor({super.key});

  @override
  State<EnrollAsEmergencyDoctor> createState() => _EnrollAsEmergencyDoctorState();
}

class _EnrollAsEmergencyDoctorState extends State<EnrollAsEmergencyDoctor> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: getDoctorData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return Scaffold(
            appBar:
            AppBar(
                backgroundColor: Colors.pink.shade900,
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('DocLinkr'),
                ),
          )
          ,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter, // 10% of the width, so there are ten blinds.
                  colors: [Colors.white70, Colors.pink.shade50], // whitish to gray// repeats the gradient over the canvas
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Do you want to enroll as an Emergency Doctor? Click below',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Emergency()), // Replace YourNewPage with your actual new page
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.08,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade900,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              'Enroll',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          Icon(
                            Icons.emergency_rounded,
                            color: Colors.red,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  }
}
