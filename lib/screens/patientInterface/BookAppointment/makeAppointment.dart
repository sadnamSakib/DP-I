import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/home/home.dart';
import 'package:design_project_1/services/BookAppointement.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../viewAppointment/appointmentList.dart';
import 'Slots.dart';

class BookAppointmentPage extends StatefulWidget {
  final doctorID;

  BookAppointmentPage({required this.doctorID});

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {

  List<TimeSlots> timeSlots = [];
  TimeSlots? selectedTimeSlot;

  late DocumentReference doctorReference;
  Map<String, dynamic> doctorData = {};
  final docName='';
  late DocumentReference docUserReference;
  Map<String, dynamic> docUserData={};
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';


  bool hasAppointment = false;


  Future<void> IsBooked(String slotid) async {

    print(slotid);
    final appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');
    final appointmentsQuery = await appointmentsCollection
        .where('patientId', isEqualTo: userUID)
        .where('slotID', isEqualTo: slotid)
        .get();

    // Check if any matching appointments exist
    if (appointmentsQuery.docs.isNotEmpty) {
      // Appointments matching the current user exist for this slot
      // print('Appointments exist for slot $slotid');
      setState(() {

        hasAppointment = true;
      });

    } else {
      // No matching appointments found for this slot
      // print('No appointments for slot $slotid');
    }
  }

  Future<void> fetchTimeSlots(DateTime selectedDay) async {
    setState(() {

    selectedTimeSlot=null;
    hasAppointment=false;
    timeSlots.clear();
    });
    final scheduleCollection = FirebaseFirestore.instance.collection(
        'Schedule');
    final scheduleQuery = scheduleCollection.doc(widget.doctorID);
    final dayScheduleQuery = await scheduleQuery.collection('Days').doc(
        DateFormat('EEEE').format(selectedDay)).collection('Slots').get();

    setState(()  {
      for(final slots in dayScheduleQuery.docs)
      {

        if(!(slots['Number of Patients']== '0')){
          final _StartTime = slots['Start Time'];
          final _endTime = slots['End Time'];
          final _sessionType = slots['Session Type'];

          IsBooked(slots.id);


          print(_StartTime);

          setState(() {
          TimeSlots timeSlot = TimeSlots(
            id: slots.id,
            startTime: timeformatting(_StartTime),
            endTime: timeformatting(_endTime),
            sessionType: _sessionType,
          );
          timeSlots.add(timeSlot);

          });

        }

      }

    });
  }

  String timeformatting(String Time) {


    List<String> timeParts = Time.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    String period = hours >= 12 ? 'PM' : 'AM';
    if (hours > 12) {
      hours -= 12;
    } else if (hours == 0) {
      hours = 12;
    }

    String hour = hours.toString().padLeft(2,'0');
    String minute = minutes.toString().padLeft(2,'0');

    String formattedTime = '$hour:$minute $period';

    print('HOURRRRR');
    print("Formatted Time: $formattedTime");

    return formattedTime;

  }





  Future<void> fetchDoctorData(String doctorID) async {
    doctorReference = FirebaseFirestore.instance.collection('doctors').doc(doctorID);


    final doctorSnapshot = await doctorReference.get();

    if (doctorSnapshot.exists) {
      setState(() {
        doctorData = doctorSnapshot.data() as Map<String, dynamic>;
        print(doctorData['specialization']);
      });
    }
  }

  Future<void> fetchDoctorName(String doctorID) async {
    docUserReference = FirebaseFirestore.instance.collection('users').doc(doctorID);

    final doctUserSnapshot = await docUserReference.get();

    if (doctUserSnapshot.exists) {

      docUserData = doctUserSnapshot.data() as Map<String, dynamic>;
      print(docUserData['name']);


    } else {

      print('Document does not exist');
    }
    final docUserSnapshot = await docUserReference.get();

    if (docUserSnapshot.exists) {
      setState(() {
        docUserData = docUserSnapshot.data() as Map<String, dynamic>;
        print(docUserData['name']);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.doctorID);
    fetchTimeSlots(DateTime.now());

    fetchDoctorName(widget.doctorID);
    fetchDoctorData(widget.doctorID);
  }

  late DateTime selectedDate ;
  late TimeOfDay selectedTime ;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? healthIssue;
  String? Day;


  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text('Book Appointment'),
          backgroundColor: Colors.blue.shade900,
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white70, Colors.blue.shade100],
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
                            image: docUserData['profile'] != null
                                ? DecorationImage(
                              image: NetworkImage(docUserData['profile']),
                              fit: BoxFit.cover,
                            )
                                : DecorationImage(
                              image: AssetImage('assets/images/doctor.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // 'as[pa',
                              docUserData['name'] ?? 'Doctor Name', // Provide a default if the name is not available
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              doctorData['specialization'] ?? '', // Replace with doctor speciality
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              doctorData['degrees']?.join(', ') ?? '', // Replace with doctor speciality
                              style: TextStyle(fontSize: 12),
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
                              selectedDate = selectedDay;
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
                              height: 1000,
                              width: 150,
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

                          onPressed: hasAppointment?
                              ()
                          {

                            Fluttertoast.showToast(
                              msg: 'Appointment already booked for ${Day ?? DateFormat('EEEE').format(DateTime.now())}',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.white,
                              textColor: Colors.blue,
                            );

                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (BuildContext context) => BookAppointmentPage(doctorID: widget.doctorID),
                            ));

                          }:
                              () {
                            if (selectedDate != null && selectedTimeSlot != null && Day != null) {
                              BookAppointment().bookAppointment(widget.doctorID,FirebaseAuth.instance.currentUser?.uid ?? '',
                                  selectedTimeSlot!.id , healthIssue ?? '' ,selectedDate, Day ?? '');
                              Fluttertoast.showToast(
                                msg: 'Appointment booked',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.blue,
                              );
                              print('Selected Date: $selectedDate');
                              print('Selected Time Slot: $Day');
                              print( selectedTimeSlot?.id);
                              // Navigator.pop(context);
                              // fetchTimeSlots(DateTime.now());

                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (BuildContext context) => BookAppointmentPage(doctorID: widget.doctorID),
                              ));

                            }
                            else{
                              Fluttertoast.showToast(
                                msg: 'Please select a day and slot to book an appointment',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.red,
                              );
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (BuildContext context) => BookAppointmentPage(doctorID: widget.doctorID),
                              ));
                            }
                            // Navigator.pop(context);
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
                          child: Text( hasAppointment? 'Appointment Booked'
                              : 'Book Appointment',
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
