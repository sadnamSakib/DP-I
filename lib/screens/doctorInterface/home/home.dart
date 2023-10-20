import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/profile/profile.dart';
import 'package:design_project_1/screens/doctorInterface/schedule/schedule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:design_project_1/services/auth.dart';

// import '../schedule/weekly_calender.dart';
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

  int _currentIndex = 2; // Track the current tab index

  Stream<DocumentSnapshot> getUserData() {
    String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FirebaseFirestore.instance.collection('users').doc(userUID).snapshots();
  }


  List<Widget> _buildScreens() {
    return [
      ScheduleScreen(),
      Container(
        color: Colors.transparent,
        child: Text('Appointments'),
      ),
      Container(
        color: Colors.transparent,
        child: Feed(),

      ),
      Container(
        color: Colors.transparent,
        child: Text('Emergency'),
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
        icon: Icon(Icons.schedule_outlined, color: Colors.indigo),
        inactiveIcon: Icon(Icons.schedule_outlined, color: Colors.grey),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.calendar_month, color: Colors.indigo),
        inactiveIcon: Icon(Icons.calendar_month, color: Colors.grey),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home, color: Colors.indigo),
        inactiveIcon: Icon(Icons.home, color: Colors.grey),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.emergency_outlined, color: Colors.indigo),
        inactiveIcon: Icon(Icons.emergency_outlined, color: Colors.grey),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person, color: Colors.indigo),
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
