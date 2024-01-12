import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/emergencyPortal/chat.dart';
import 'package:design_project_1/screens/patientInterface/profile/profile.dart';
import 'package:design_project_1/screens/patientInterface/BookAppointment/doctorFinderPage.dart';
import 'package:design_project_1/screens/patientInterface/healthTracker/tracker.dart';
import 'package:design_project_1/screens/patientInterface/viewAppointment/appointmentList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:design_project_1/services/auth.dart';
import 'package:design_project_1/screens/patientInterface/emergencyPortal/requestEmergencyScreen.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import '../../../services/SearchBarDelegator.dart';

import '../profile/InfromationSelectionPage.dart';

import '../../../services/notification_services.dart';


class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  NotificationServices notificationServices = NotificationServices();

  final AuthService _auth = AuthService();
  int _currentIndex = 2; // Track the current tab index
  @override
  void initState() {
    super.initState();
    setState(() {
      _currentIndex = 2;
    });
    notificationServices.requestNotificationPermission();
     notificationServices.firebaseInit(context);
     notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) async {
    print("device   token");
    print(value);
    await FirebaseFirestore.instance.collection('patients').doc(FirebaseAuth.instance.currentUser?.uid).update({
      'deviceToken': value,
    });
    });
  }
  List<Widget> _buildScreens() {
    return [
      Tracker(),
      RequestEmergencyScreen(),
      DoctorFinder(),
      AppointmentListPage(),
      InformationSelectionScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(icon: Icon(Icons.track_changes,color:Colors.indigo),
          inactiveIcon:  Icon(Icons.track_changes , color: Colors.grey)),
      PersistentBottomNavBarItem(icon: Icon(Icons.summarize_outlined,color:Colors.indigo),
          inactiveIcon:  Icon(Icons.summarize_outlined , color: Colors.grey)),
      PersistentBottomNavBarItem(icon: Icon(Icons.home,color:Colors.indigo),
          inactiveIcon:  Icon(Icons.home , color: Colors.grey)),
      PersistentBottomNavBarItem(icon: Icon(Icons.calendar_month,color:Colors.indigo),
          inactiveIcon:  Icon(Icons.calendar_month , color: Colors.grey)),
      PersistentBottomNavBarItem(icon: Icon(Icons.person,color:Colors.indigo),
          inactiveIcon:  Icon(Icons.person , color: Colors.grey))
    ];
  }
  SearchDelegate<String> createSearchBarDelegate() {
    return SearchBarDelegate();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: PersistentTabView(
              context,
              controller: PersistentTabController(initialIndex: 2),
              screens: _buildScreens(),
              items: _navBarItems(),
              backgroundColor: Colors.white,
              decoration: NavBarDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              navBarStyle: NavBarStyle.style14,
              onItemSelected: (int index) {
                setState(() {
                  _currentIndex = index; // Update the current tab index
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
