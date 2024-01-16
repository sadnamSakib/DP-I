import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/components/virtualConsultation/call.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/AppointmentClass.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/Reports_Prescriptions.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/viewAppointment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'appointments.dart';
import 'healthTrackerSummaryScreen.dart';
import 'prescribeMedicine.dart';

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
        backgroundColor: Colors.pink.shade900,
        title: Text('Appointment Details'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.pink.shade50],
          )
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.teal.shade800),
                  ),
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
              title: Text('Patient Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),),
              subtitle: Text(widget.appointment.patientName,
              style: TextStyle(
                fontSize: 18,
              ),),
            ),
            ListTile(
              title: Text('Issue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
              subtitle: Text(widget.appointment.issue),
            ),
            ListTile(
              title: Text('Previous Issues',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
              subtitle: Text(
                  userData?['preExistingConditions'].join(", ") ?? ''
              ),          ),
            ListTile(
              title: Text('Phone Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),),
              subtitle: Text(userData?['phone'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 18,
                ),),
            ),
            ListTile(
              title: Text('Session Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
              subtitle: Text(widget.appointment.sessionType,
                style: TextStyle(
                  fontSize: 18,
                ),),
            ),
            ListTile(
              title: Text('Paid',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
              subtitle: Text(widget.appointment.isPaid ? 'Yes' : 'No',
                style: TextStyle(
                  fontSize: 18,
                ),),
            ),
            ElevatedButton(
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.teal.shade800),
              ),
              onPressed: () {
                _showBottomSheet(context);
              },
              child: Text('View Options'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context){
    showModalBottomSheet(
      context : context,
      builder: (context) => Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HealthTrackersScreen(patientId: widget.appointment.patientId)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.bar_chart, // Replace with the icon you want
                    color: Colors.black,
                  ),
                  SizedBox(width: 8.0), // Adjust the spacing between the icon and text
                  Text('View Health Trackers'),
                ],
              ),
            ),

            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReportsandPrescriptions(patientID: widget.appointment.patientId)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.medical_services,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8.0),
                  Text('View Reports and Prescriptions'),
                ],
              ),
            ),
            widget.appointment.sessionType == 'Online' ?  TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CallPage(callID: generateCallID(), userID: userId, userName: userName)),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.call,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8.0),
                  Text('Call Into Session'),
                ],
              ),
            ) : Container(),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PrescribeMedicineScreen(patientId: widget.appointment.patientId)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.content_paste_outlined,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8.0),
                  Text('Prescribe Medicine'),
                ],
              ),
            ),
          ],
        ),
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

      print(id);

      final appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');


       addVisit(widget.appointment.patientId, widget.appointment.doctorId);

      appointmentsCollection.doc(id).delete().then((_) {
        print("Document with ID $id deleted successfully.");
      }).catchError((error) {
        print("Error deleting document: $error");
      });
  }


  Future<void> addVisit(String patientId, String doctorId) async {
    try {
      CollectionReference visitsCollection = FirebaseFirestore.instance.collection('Visits');

      DocumentReference visitDocument = visitsCollection.doc();


      await visitDocument.set({
        'patientId': patientId,
        'doctorId': doctorId,
      });

      print('Visit added successfully!');
    } catch (e) {
      print('Error adding visit: $e');
    }
  }

}