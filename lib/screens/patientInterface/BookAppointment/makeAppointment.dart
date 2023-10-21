import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BookAppointmentPage extends StatefulWidget {
  final String doctorID;

  BookAppointmentPage({required this.doctorID});

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<String> timeSlots = [
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '2:00 PM - 3:00 PM',
    // Add more time slots as needed
  ];
  String? selectedTimeSlot;
  String? healthIssue;
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
    return Scaffold(
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
                          Text(
                            'Arpa', // Replace with doctor name
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Heart Specialist', // Replace with doctor speciality
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
                        lastDay: DateTime.now().add(Duration(days: 7)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
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
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: timeSlots.map((timeSlot) {
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

                              color: selectedTimeSlot == timeSlot ? Colors.blue.shade900 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  timeSlot,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selectedTimeSlot == timeSlot ? FontWeight.bold : FontWeight.normal,
                                    color: selectedTimeSlot == timeSlot ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  'Online', // Add 'Online' or 'Offline' based on doctor availability along with timeslot
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
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
                        if (selectedDate != null && selectedTimeSlot != null) {
                          // Add logic to book appointment
                          print('Selected Date: $selectedDate');
                          print('Selected Time Slot: $selectedTimeSlot');
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
