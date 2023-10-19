import 'package:flutter/material.dart';
import 'package:design_project_1/services/healthTrackerService.dart';
import 'package:firebase_auth/firebase_auth.dart';
class WaterTrackerPage extends StatefulWidget {
  @override
  _WaterTrackerPageState createState() => _WaterTrackerPageState();
}

class _WaterTrackerPageState extends State<WaterTrackerPage> {
  int totalGlasses = 0;
  int totalMl = 0;
  int mlPerGlass = 250;

  @override
  void initState() {
    super.initState();
    loadWaterData();
  }

  void loadWaterData() async {
    int waterData = await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).getWaterData();
    setState(() {
      totalMl = waterData;
      totalGlasses = (totalMl / mlPerGlass).round();
    });
  }

  void addGlass() async {
    setState(() {
      totalGlasses++;
      totalMl += mlPerGlass;
    });
    await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid)
        .updateWaterData(totalMl);
    loadWaterData();
  }

  void removeGlass() async {
    if (totalGlasses > 0) {
      setState(() {
        totalGlasses--;
        totalMl -= mlPerGlass;
      });
      await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid)
          .updateWaterData(totalMl);
      loadWaterData();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Water Tracker'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur
          Image.asset(
            'assets/images/waterBackground.jpg', // Replace with your image path
            fit: BoxFit.cover,
          ),
          // Blurred overlay
          Container(
            color: Colors.white.withOpacity(0.5),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: Text(
                    'Note: 1 glass = 250 ml',
                    style: TextStyle(fontSize: 30, color: Colors.red),
                  ),
                ),
                SizedBox(height: 20), // Added padding
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Total Glasses Consumed:',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 10), // Added padding
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          key: ValueKey<int>(totalGlasses),
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade600,
                          ),
                          child: Center(
                            child: Text(
                              totalGlasses.toString(),
                              style: TextStyle(fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20), // Added padding
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: removeGlass,
                      child: Icon(Icons.remove),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // Set background color to red
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: addGlass,
                      child: Icon(Icons.add),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, // Set background color to green
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(height: 20),
                ), // Added top margin
                Text(
                  'Total Water Consumed: $totalMl ml',
                  style: TextStyle(fontSize: 25,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

