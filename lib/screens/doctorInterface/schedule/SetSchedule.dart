import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

class SetSchedule extends StatefulWidget {
  final String selectedDay;
  final String startTime;
  final String endTime;
  final String sessionType;

  const SetSchedule({
    Key? key,
    required this.selectedDay,
    required this.startTime,
    required this.endTime,
    required this.sessionType,
  }) : super(key: key);

      @override
      State<SetSchedule> createState() => _SetScheduleState();

  // Add a method for performing backend work
  void AddSchedule() {
    // Add your backend logic here
    print('Performing backend work...');
    print('Selected Day: $selectedDay');
    print('Start Time: $startTime');
    print('End Time: $endTime');
    print('Session Type: $sessionType');


    String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

    CollectionReference dayDocument = FirebaseFirestore.instance.collection('Schedule');

    addDay(userUID, selectedDay, startTime, endTime, sessionType);

  }
}

// Add a day to a user's schedule
void addDay(String userUID, String dayName, String StartTime, String EndTime, String SessionType) {
  print('HEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');
  FirebaseFirestore.instance.collection('Schedule').doc(userUID).collection('Days').doc(dayName).set({
    'Start Time': StartTime,
    'End Time': EndTime,
    'Session Type': SessionType,
  });
}



class _SetScheduleState extends State<SetSchedule> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
