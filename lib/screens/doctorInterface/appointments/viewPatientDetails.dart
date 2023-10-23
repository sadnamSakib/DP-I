import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/components/virtualConsultation/call.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/AppointmentClass.dart';
import 'package:flutter/material.dart';
import 'healthTrackerSummaryScreen.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointments appointment;

  const AppointmentDetailScreen({Key? key, required this.appointment})
      : super(key: key);

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}
class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {

  Map<String, dynamic>? userData;
  @override
  void initState(){
    print('INITSTATE OF ');
    print(widget.appointment.id);

    getUserInfo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Mark as Done'),
              ),
            ),
          ),
          ListTile(
            title: Text(widget.appointment.patientName),
            // subtitle: Text('Gender: Male'),
          ),
          ListTile(
            title: Text('Issue'),
            subtitle: Text(widget.appointment.issue),
          ),
          ListTile(
            title: Text('Previous Issues'),
            subtitle: Text(
                userData?['preExistingConditions'].join(", ") ?? ''
            ),          ),
          ListTile(
            title: Text('Phone Number'),
            subtitle: Text(userData?['phone'] ?? 'N/A'),
          ),
          ListTile(
            title: Text('Session Type'),
            subtitle: Text(widget.appointment.sessionType),
          ),
          ListTile(
            title: Text('Paid'),
            subtitle: Text(widget.appointment.isPaid ? 'Yes' : 'No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HealthTrackersScreen(patientId: widget.appointment.patientId)));
            },
            child: Text('View Health Tracker Information'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CallPage(callID: '123')));
            },
            child: Text('Call into Session'),
          ),
        ],
      ),
    );
  }

  Future<void> getUserInfo() async {
    userData?.clear();
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance.collection('patients').doc(widget.appointment.patientId).get();
      if (document.exists) {
        setState(() {
          userData = document.data() as Map<String, dynamic>;
        });
      } else {
        print(widget.appointment.patientId);
        return null;
      }
    } catch (e) {
      print('Error retrieving user information: $e');
      return null;
    }
  }

}