import 'package:design_project_1/screens/patientInterface/healthTracker/tracker.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:design_project_1/services/auth.dart';

import '../../../services/SearchBarDelegator.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  int _currentIndex = 2; // Track the current tab index

  List<Widget> _buildScreens() {
    return [
      Tracker(),
      Text('Reports'),
      Text('Home'),
      Text('Appointment'),
      Text('Profile'),

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
      appBar: AppBar(
        title: Text('DocLinkr'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Open the search bar
              showSearch(context: context, delegate: createSearchBarDelegate());
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0)),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                leading: const Icon(Icons.search),
              );
            },
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              final List<String> items = ['Neurologist','Pediatrician','Dermatologist',
                'Oncologist','Psychiatrist'];

              return items.map((String item) {
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      controller.closeView(item);
                    });
                  },
                );
              }).toList();
            },

          ),

          if (_currentIndex == 2) // Only show this content for the "Home" tab (index 2)
            Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 100,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome to Chikitshoker home',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Pawfect Health Care for you.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      await _auth.signOut();
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
          Divider(),
          Expanded(
            child: PersistentTabView(
              context,
              controller: PersistentTabController(initialIndex: 0),
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
