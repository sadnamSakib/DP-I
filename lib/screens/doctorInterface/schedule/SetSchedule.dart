

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class SetSchedule extends StatefulWidget {
  final String selectedDay;
  final String startTime;
  final String endTime;
  final String sessionType;
  final String numberofPatients;

  const SetSchedule({
    Key? key,
    required this.selectedDay,
    required this.startTime,
    required this.endTime,
    required this.sessionType,
    required this.numberofPatients,
  }) : super(key: key);

  @override
  State<SetSchedule> createState() => _SetScheduleState();

  void AddSchedule() {
    print('Performing backend work...');
    print('Selected Day: $selectedDay');
    print('Start Time: $startTime');
    print('End Time: $endTime');
    print('Session Type: $sessionType');
    print('Session Type: $numberofPatients');

    final slots = Slot(
      StartTime: startTime,
      EndTime: endTime,
      SessionType: sessionType,
      NumberOfPatients: numberofPatients,
    );
    print(slots.StartTime);
    List<Slot> listofslot=[];
    listofslot.add(slots);

    String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

    addDay(userUID, selectedDay, listofslot);
  }
}

class Slot {
  String StartTime;
  String EndTime;
  String SessionType;
  String NumberOfPatients;

  Slot({
    required this.StartTime,
    required this.EndTime,
    required this.SessionType,
    this.NumberOfPatients = '4', // Set a default value
  });
}



void addDay(String userUID, String dayName, List<Slot> slots) {
  CollectionReference daysCollection =
  FirebaseFirestore.instance.collection('Schedule').doc(userUID).collection('Days');

  // daysCollection.doc(dayName).get().then((daySnapshot) {
  //   if (daySnapshot.exists) {
      // For each slot, add it to the day document
      for (Slot slot in slots) {
        daysCollection.doc(dayName).collection('Slots').add({
          'Start Time': slot.StartTime,
          'End Time': slot.EndTime,
          'Session Type': slot.SessionType,
          'Number of Patients': slot.NumberOfPatients,
        });
      }
    // }
  // });
}

class _SetScheduleState extends State<SetSchedule> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

