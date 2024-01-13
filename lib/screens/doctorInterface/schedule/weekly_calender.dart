import 'package:flutter/material.dart';

import '../../../services/authServices/auth.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<CalendarPage> {
  final AuthService _auth = AuthService();

  void onDayPressed(String day) {
    // Implement the functionality you want for each day here.
    print("Pressed $day");
    // You can navigate to a new screen, show a dialog, or perform any action you desire.
  }

  Widget circularDayLabel(String day) {
    return Container(
      width: 36, // Adjust the size as needed
      height: 36, // Adjust the size as needed
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.lightBlue, // Adjust the background color
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: Colors.white, // Adjust the text color
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text('Schedule'),
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
          color: Colors.lightBlue.shade50,
          image: DecorationImage(
            image: AssetImage('assets/images/doc.png'), // Replace with your image path
            fit: BoxFit.fitHeight,
            opacity: 0.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Week of October 24, 2023',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1),
                    5: FlexColumnWidth(1),
                    6: FlexColumnWidth(1),
                    7: FlexColumnWidth(1),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // Days of the week with circular labels
                    TableRow(
                      children: [
                        TableCell(
                          child: InkWell(
                            onTap: () => onDayPressed('Mon'),
                            child: circularDayLabel('Mon'),
                          ),
                        ),
                        TableCell(
                          child: InkWell(
                            onTap: () => onDayPressed('Tue'),
                            child: circularDayLabel('Tue'),
                          ),
                        ),
                        TableCell(
                          child: InkWell(
                            onTap: () => onDayPressed('Wed'),
                            child: circularDayLabel('Wed'),
                          ),
                        ),
                        TableCell(
                          child: InkWell(
                            onTap: () => onDayPressed('Thu'),
                            child: circularDayLabel('Thu'),
                          ),
                        ),
                        TableCell(
                          child: InkWell(
                            onTap: () => onDayPressed('Fri'),
                            child: circularDayLabel('Fri'),
                          ),
                        ),
                        TableCell(
                          child: InkWell(
                            onTap: () => onDayPressed('Sat'),
                            child: circularDayLabel('Sat'),
                          ),
                        ),
                        TableCell(
                          child: InkWell(
                            onTap: () => onDayPressed('Sun'),
                            child: circularDayLabel('Sun'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
