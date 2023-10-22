import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Slots.dart';

class BookAppointmentPage extends StatefulWidget {
  final doctorID;

  BookAppointmentPage({required this.doctorID});

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {

  List<TimeSlots> timeSlots = [];

  late DocumentReference doctorReference;
  Map<String, dynamic> doctorData = {};
  final docName='';
  late DocumentReference docUserReference;
  Map<String, dynamic> docUserData={};


  Future<void> fetchTimeSlots(DateTime selectedDay) async {
    timeSlots.clear();
    final scheduleCollection = FirebaseFirestore.instance.collection(
        'Schedule');
    final scheduleQuery = scheduleCollection.doc(widget.doctorID);
    final dayScheduleQuery = await scheduleQuery.collection('Days').doc(
        DateFormat('EEEE').format(selectedDay)).collection('Slots').get();
        print('hereeeeeeeeeeeeeeeee');

    setState(() {
    for(final slots in dayScheduleQuery.docs)
      {
        final _StartTime = slots['Start Time'];
        final _endTime = slots['End Time'];
        final _sessionType = slots['Session Type'];
        print(_StartTime);
        TimeSlots timeSlot = TimeSlots(
          startTime: _StartTime,
          endTime: _endTime,
          sessionType: _sessionType,
        );
        timeSlots.add(timeSlot);
      }

    });
  }
    Future<void> fetchDoctorData(String doctorID) async {
    doctorReference = FirebaseFirestore.instance.collection('doctors').doc(doctorID);


    final doctorSnapshot = await doctorReference.get();

    if (doctorSnapshot.exists) {
      setState(() {
        doctorData = doctorSnapshot.data() as Map<String, dynamic>;
      });
    }
  }

  Future<void> fetchDoctorName(String doctorID) async {
    docUserReference = FirebaseFirestore.instance.collection('users').doc(doctorID);

    final doctUserSnapshot = await docUserReference.get();

    if (doctUserSnapshot.exists) {
      // Document with the specified doctorID exists in Firestore
      // You can access its data, including the 'name' property.
      docUserData = doctUserSnapshot.data() as Map<String, dynamic>;
      print(docUserData['name']);

    } else {
      // Document with the specified doctorID does not exist in Firestore
      // Handle this case as needed
      print('Document does not exist');
    }
    final docUserSnapshot = await docUserReference.get();

    if (docUserSnapshot.exists) {
      setState(() {
        docUserData = docUserSnapshot.data() as Map<String, dynamic>;
        print(docUserData['name']);
        print('vvvvvvvvvvvvvvvvvvvvvvv');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.doctorID);
    fetchDoctorData(widget.doctorID);

    fetchDoctorName(widget.doctorID);
  }

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeSlots? selectedTimeSlot;
  String? healthIssue;
  String? Day;
  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2101),
  //   );
  //
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //     });
  //   }
  // }

  // Future<void> _selectTime(BuildContext context) async {
  //   final TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: selectedTime,
  //   );
  //
  //   if (picked != null && picked != selectedTime) {
  //     setState(() {
  //       selectedTime = picked;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white70, Colors.blue.shade200],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
                          image: DecorationImage(
                            image: AssetImage('assets/images/doctor.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // if (docUserData.isNotEmpty) // Render if docName is available
                            Text(
                              // 'as[pa',
                              docUserData['name'] ?? 'Doctor Name', // Provide a default if the name is not available
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          SizedBox(height: 10),
                          Text(
                            doctorData['specialization'] ?? 'Specilization', // Replace with doctor speciality
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Text('Select a Date', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TableCalendar(
                        calendarFormat: CalendarFormat.week,
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(Duration(days: 6)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            Day = DateFormat('EEEE').format(selectedDay);
                            fetchTimeSlots(selectedDay);
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Select a Time Slot',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 50,

                    child: timeSlots.isEmpty
                        ? Center(
                      child: Text(
                        "No slots available for the this Day",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    )
                        :
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: timeSlots.length,
                      itemBuilder: (context, index) {
                        final timeSlot = timeSlots[index];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTimeSlot = timeSlot;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selectedTimeSlot == timeSlot
                                  ? Colors.blue.shade900
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${timeSlot.startTime} - ${timeSlot.endTime}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selectedTimeSlot == timeSlot
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: selectedTimeSlot == timeSlot
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  timeSlot.sessionType, // Add 'Online' or 'Offline' based on doctor availability along with timeslot
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
,
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      'Health Issue',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 3),
                  TextField(
                    onChanged: (value) {
                      print(healthIssue);
                      setState(() {
                        healthIssue = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Describe your health issue...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    maxLines: 2, // Adjust the number of lines as needed
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(

                      onPressed: () {
                        if (selectedDate != null && selectedTimeSlot != null ) {
                          BookAppointment();
                          // Add logic to book appointment
                          print('Selected Date: $selectedDate');
                          print('Selected Time Slot: $Day');
                          print('Health Issue: $healthIssue');
                        }
                        else{
                          Fluttertoast.showToast(
                            msg: 'Please select a day and slot to book an appointemnt',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.red,
                          );
                        }
                      },
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(Size(200, 50)),
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (selectedTimeSlot != null) {
                              return Colors.green; // Change the color when a time slot is selected
                            }
                            return Colors.blue.shade900; // Default color
                          },
                        ),

                    ),
                      child: Text('Book Appointment',
                      style: TextStyle(fontSize: 16),
                    )
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
