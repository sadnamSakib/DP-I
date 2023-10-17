import 'package:design_project_1/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  List<Widget> _buildScreens() {
    return [
      Text('Profile'),
      Text('Reports'),
      Text('Home'),
      Text('Appointment'),
      Text('Tracker'),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(icon: Icon(Icons.person,color:Colors.indigo),
          inactiveIcon:  Icon(Icons.person , color: Colors.grey)),
      PersistentBottomNavBarItem(icon: Icon(Icons.report,color:Colors.indigo),
          inactiveIcon:  Icon(Icons.report , color: Colors.grey)),
      PersistentBottomNavBarItem(icon: Icon(Icons.home,color:Colors.indigo),
          inactiveIcon:  Icon(Icons.home , color: Colors.white)),

      PersistentBottomNavBarItem(icon: Icon(Icons.calendar_month,color:Colors.indigo),
          inactiveIcon:  Icon(Icons.calendar_month , color: Colors.grey)),
      PersistentBottomNavBarItem(icon: Icon(Icons.track_changes,color:Colors.indigo),
          inactiveIcon:  Icon(Icons.track_changes , color: Colors.grey)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.medical_services,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to Chikitshoker home',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pawfect Health Care for you.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    await _auth.signOut();
                    // Add your navigation logic here
                  },
                  child: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Divider(), // You can add a divider here if needed
          Expanded(
            child: PersistentTabView(
              context,
              controller: PersistentTabController(initialIndex: 0),
              screens: _buildScreens(),
              items: _navBarItems(),
              backgroundColor: Colors.lightBlue,
              decoration: NavBarDecoration(
                  borderRadius: BorderRadius.circular(5)
              ),
              navBarStyle: NavBarStyle.style15,
            ),
          ),
        ],
      ),
    );
  }
}
