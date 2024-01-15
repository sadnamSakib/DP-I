import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/appointments.dart';
import 'package:design_project_1/screens/doctorInterface/emergencyPortal/emergencyEnroll.dart';
import 'package:design_project_1/screens/doctorInterface/emergencyPortal/emergencyRequests.dart';
import 'package:design_project_1/screens/doctorInterface/profile/profile.dart';
import 'package:design_project_1/screens/doctorInterface/schedule/schedule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:design_project_1/services/authServices/auth.dart';
import '../../../services/notificationServices/notification_services.dart';
import '../emergencyPortal/chat.dart';
import 'Feed.dart';

void main() {
  runApp(Home());
}



class Home extends StatefulWidget {

  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  NotificationServices notificationServices = NotificationServices();
  final AuthService _auth = AuthService();
  var emergencyDoctor = false;
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
      await FirebaseFirestore.instance.collection('doctors').doc(FirebaseAuth.instance.currentUser?.uid).update({
        'deviceToken': value,
      });
    });
  }

  Stream<DocumentSnapshot> getUserData() {
    String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FirebaseFirestore.instance.collection('users').doc(userUID).snapshots();
  }
  Stream<DocumentSnapshot> getDoctorData() {
    String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FirebaseFirestore.instance.collection('doctors').doc(userUID).snapshots();

  }



  List<Widget> _buildScreens() {
    return [
      ScheduleScreen(),
      AppointmentScreen(),
      Container(
        color: Colors.transparent,
        child: Feed(),

      ),
      Container(
        color: Colors.transparent,
        child:
        StreamBuilder<DocumentSnapshot>(
          stream: getDoctorData(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }
            else if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            else{
              Map<String, dynamic> data = snapshot.data?.data() as Map<String, dynamic>;
              if(data['emergency']== null || data['emergency'] == false){
                return EnrollAsEmergencyDoctor();
              }
              else{
                return EmergencyRequestList();
              }

            }

          },
        ),
      ),
      Container(
        color: Colors.transparent,
        child: ProfileScreen(),
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.schedule_outlined, color: Colors.pink.shade900),
        inactiveIcon: Icon(Icons.schedule_outlined, color: Colors.grey),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.calendar_month, color: Colors.pink.shade900),
        inactiveIcon: Icon(Icons.calendar_month, color: Colors.grey),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home, color: Colors.pink.shade900),
        inactiveIcon: Icon(Icons.home, color: Colors.grey),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.emergency_outlined, color: Colors.pink.shade900),
        inactiveIcon: Icon(Icons.emergency_outlined, color: Colors.grey),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person, color: Colors.pink.shade900),
        inactiveIcon: Icon(Icons.person, color: Colors.grey),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return 


         SafeArea(
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
                _currentIndex = index;
              });
            },
        ),
         );
    
  }
}
