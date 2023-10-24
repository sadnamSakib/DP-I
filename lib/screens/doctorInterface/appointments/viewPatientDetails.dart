import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/components/virtualConsultation/call.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/AppointmentClass.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/viewAppointment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'appointments.dart';
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

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final  userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
  Future username = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) => value.data()!['name']);
  String userName = '';
  String generateCallID() {
    String callID = '';
    callID = widget.appointment.doctorId;
    return callID;
  }
  Map<String, dynamic>? userData;
  @override
  void initState(){
    print('INITSTATE OF ');
    print(widget.appointment.id);
    setState(() {
      username.then((value) => userName = value.toString());
    });

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
                onPressed: () {
                  markAsDone(widget.appointment.id);
                  Fluttertoast.showToast(
                    msg: 'Mark As Done',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.blue,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AppointmentScreen()),
                  );
                },
                child: Text('Mark as Done'),
              ),
            ),
          ),
          ListTile(
            title: Text('Patient name'),
            subtitle: Text(widget.appointment.patientName),
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

           widget.appointment.sessionType == 'Online' ?  ElevatedButton(

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CallPage(callID: generateCallID(), userID: userId, userName: userName)),
              );
            },
            child: Text('Call into Session'),
          ):
               Container()


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

  void markAsDone(String id) {

    print('MARK ASSSSSSSSSSS DONEEEEEEEEEEEEEEE');
    print(id);

      final appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');

      // Delete the document with the specified ID
      appointmentsCollection.doc(id).delete().then((_) {
        print("Document with ID $id deleted successfully.");
      }).catchError((error) {
        print("Error deleting document: $error");
      });
  }

}