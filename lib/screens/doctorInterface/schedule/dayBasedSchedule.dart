import 'package:flutter/material.dart';

class DayBasedScheduleScreen extends StatefulWidget {
  const DayBasedScheduleScreen({Key? key});

  @override
  State<DayBasedScheduleScreen> createState() => _DayBasedScheduleScreenState();
}

class _DayBasedScheduleScreenState extends State<DayBasedScheduleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _sessionType;

  List<Session> _sessions = [];

  void _showAddSessionDialog() async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Session"),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_startTime == null)
                      ElevatedButton(
                        onPressed: () async {
                          startTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (startTime != null) {
                            setState(() {
                              _startTime = startTime;
                            });
                          }
                        },
                        child: Text("Select Start Time"),
                      ),
                    if (_endTime == null)
                      ElevatedButton(
                        onPressed: () async {
                          endTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (endTime != null) {
                            setState(() {
                              _endTime = endTime;
                            });
                          }
                        },
                        child: Text("Select End Time"),
                      ),
                    if (_startTime != null)
                      ListTile(
                        title: Text("Start Time: ${_startTime!.format(context)}"),
                      ),
                    if (_endTime != null)
                      ListTile(
                        title: Text("End Time: ${_endTime!.format(context)}"),
                      ),
                    DropdownButtonFormField<String>(
                      value: _sessionType,
                      items: ["Online", "Offline"]
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sessionType = value;
                        });
                      },
                      decoration: InputDecoration(labelText: "Session Type"),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _addSession();
                      setState(() {
                        _startTime = null;
                        _endTime = null;
                        _sessionType = null;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Add Session"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addSession() {
    if (_startTime != null && _endTime != null && _sessionType != null) {
      final session = Session(
        startTime: _startTime!,
        endTime: _endTime!,
        sessionType: _sessionType!,
      );

      setState(() {
        _sessions.add(session);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Day-Based Schedule'),
      ),
      body: ListView(
        children: <Widget>[
          for (final session in _sessions)
            Card(
              color: Colors.grey.shade200,
              margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Start Time: ${session.startTime.format(context)}',
                  style : TextStyle(fontSize: 20)),
                  subtitle: Row(
                    children: [
                      Text('End Time: ${session.endTime.format(context)}',
                      style : TextStyle(fontSize: 20)),
                      SizedBox(width: 8), // Add some spacing
                      Text(session.sessionType, style: TextStyle(color: Colors.grey, fontSize: 20),),
                      SizedBox(width: 10),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: session.sessionType == "Online" ? Colors.blue : Colors.red,
                        ),
                      ),
                    ],
                  ),
                )

            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSessionDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class Session {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String sessionType;

  Session({
    required this.startTime,
    required this.endTime,
    required this.sessionType,
  });
}
