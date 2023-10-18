import 'package:design_project_1/screens/patientInterface/healthTracker/kidneyDiseaseTracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class KidneyTracker extends StatefulWidget {
  const KidneyTracker({super.key});

  @override
  State<KidneyTracker> createState() => _KidneyTrackerState();
}

class _KidneyTrackerState extends State<KidneyTracker> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<String> Measurements = ['Food', 'Weight', 'Water','Blood Pressure'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Fitness Tracker'),
      // ),
      body: Column(
        children: <Widget>[
          // Weekly Calendar
          Container(
            // Adjust the height as needed
            color: Colors.grey[200],
              child: TableCalendar(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  // Use `selectedDayPredicate` to determine which day is currently selected.
                  // If this returns true, then `day` will be marked as selected.

                  // Using `isSameDay` is recommended to disregard
                  // the time-part of compared DateTime objects.
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    // Call `setState()` when updating the selected day
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    // Call `setState()` when updating calendar format
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  // No need to call `setState()` here
                  _focusedDay = focusedDay;
                },
              ),
            ),


          // Visualizer
          Container(
            height: 200, // Adjust the height as needed
            color: Colors.blue[100],
            // Add your visualizer here
          ),

          // Fitness Measures
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children:[
                for (String measure in Measurements)
              Card(
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  // Handle tile tap
                },
                child: Center(
                  child: Text(
                    measure,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
              ]

          ),
                  ),
        ],
      ),
    );
  }
}

