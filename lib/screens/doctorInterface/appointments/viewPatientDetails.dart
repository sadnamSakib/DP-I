import 'package:design_project_1/screens/doctorInterface/appointments/viewAppointment.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/models/AppointmentModel.dart';
class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key, required Appointment appointment});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Text("Appointment Detail Screen");
  }
}
