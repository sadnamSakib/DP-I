import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/viewPatientDetails.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../services/cancellationServices/cancellationNotification.dart';
import '../../../services/notificationServices/notification_services.dart';
import 'AppointmentClass.dart';

class ViewAppointmentScreen extends StatefulWidget {
  final String slotID;
  const ViewAppointmentScreen({Key? key, required this.slotID}) : super(key: key);

  @override
  _ViewAppointmentScreenState createState() => _ViewAppointmentScreenState();
}

class _ViewAppointmentScreenState extends State<ViewAppointmentScreen> {
  final List<Appointments> appointments = [];
  NotificationServices notificationServices = NotificationServices();

  Future<void> fetchValidAppointments() async {
    appointments.clear();

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Appointments')
          .where('slotID', isEqualTo: widget.slotID)
          .get();

      setState(() {
      for (final doc in querySnapshot.docs) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          final appointment = Appointments(
            id: doc.id,
            patientId: data['patientId'],
            patientName: data['patientName'] ?? '',
            isPaid: data['isPaid'] ?? false,
            issue: data['issue'] ?? '',
            doctorId: data['doctorId'] ?? '',
            date: data['date'] ?? '',
            startTime: data['startTime'] ?? '',
            endTime: data['endTime'] ?? '',
            sessionType: data['sessionType'] ?? '',
            slotID: data['slotID'] ?? '',
          );

          print(doc.id);
          appointments.add(appointment);
        }
      }

      });
    } catch (e) {
      print('Error fetching valid appointments: $e');
    }
  }

  @override
  void initState()
  {
    fetchValidAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade900,
        title: Text('View Appointments'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [Colors.white70, Colors.pink.shade50],
          ),
        ),
        child: ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return ListTile(
              tileColor: Colors.teal.shade50,
              title: Text(appointment.patientName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),),
              subtitle:

                  Text('Issue: ${appointment.issue}',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentDetailScreen(appointment: appointment)));
              },


              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  appointment.isPaid
                      ? Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right : 8.0),
                        child: Text('Paid', style: TextStyle(color: Colors.green)),
                      ),

                      Icon(Icons.check_circle, color: Colors.green),

                    ],
                  )
                      : Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right:8.0),
                        child: Text('Not Paid', style: TextStyle(color: Colors.red)),
                      ),
                      Icon(Icons.cancel, color: Colors.red),

                    ],
                  ),
                ],
              ),



              onLongPress: () {
                _showCancellationDialog(appointment);
              },
            );

          },
        ),
      ),
    );
  }

  void _showCancellationDialog(Appointments appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String cancellationReason = '';

        return AlertDialog(
          title: Text('Cancel Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to cancel this appointment?'),
              TextField(
                decoration: InputDecoration(labelText: 'Reason for cancellation'),
                onChanged: (value) {
                  cancellationReason = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _cancelAppointment(appointment,cancellationReason);
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: 'Appointment deleted',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.blue,
                );
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(Appointments appointment, String cancellationReason) {

    print(appointment.id);

    final appointmentReference = FirebaseFirestore.instance.collection('Appointments').doc(appointment.id);
    final collection = FirebaseFirestore.instance.collection('DeletedAppointment');


     collection.add({
      'appointmentID': appointment.id ?? '',
      'slotID': widget.slotID,
      'cancellationReason': cancellationReason ?? '',
      'patientID': appointment.patientId ?? '',
      'appointmentDate': appointment.date ?? '',
      'issue': appointment.issue ?? '',
       'doctorID' : appointment.doctorId
    });
    notifyPatient(appointment.patientId,appointment.doctorId,appointment.date,
      appointment.startTime
    );

    appointmentReference.delete().then((_) {
      print('Appointment with ID ${appointment.id} has been deleted.');
    }).catchError((error) {
      print('Error deleting appointment: $error');
    });


    setState(() {
      appointments.remove(appointment);
    });
  }

  void notifyPatient(String patientId, String doctorId, String date, String startTime) {

    cancellationOfNotification().notifyPatient(patientId,doctorId,date,startTime);

  }}


