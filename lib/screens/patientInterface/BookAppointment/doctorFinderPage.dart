import 'package:flutter/material.dart';
import '../../../services/SearchBarDelegator.dart';
import '../../../utilities/doctorSpecialization.dart';
import './makeAppointment.dart';
class DoctorFinder extends StatefulWidget {
  const DoctorFinder({Key? key});

  @override
  State<DoctorFinder> createState() => _DoctorFinderState();
}

class _DoctorFinderState extends State<DoctorFinder> {
  List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. John Doe',
      'profileImage': 'assets/images/doctor.png',
    },
    {
      'name': 'Dr. Jane Smith',
      'profileImage': 'assets/images/doctor.png',
    },
    {
      'name': 'Dr. John Doe',
      'profileImage': 'assets/images/doctor.png',
    }
    // Add more doctors if needed
  ];
  SearchDelegate<String> createSearchBarDelegate() {
    return SearchBarDelegate();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.blue.shade200],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20.0, top: 20.0, left: 20.0),
              child: Text(
                'Find your desired specialist',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                readOnly: true,
                onTap: (){
                  showSearch(
                    context: context,
                    delegate: createSearchBarDelegate(),
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Search by Doctor\'s Name',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.0, top: 20.0, left: 20.0),
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 120,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: specializations.map((category) {
                    return CategoryTile(category: category);
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10.0, top: 20.0, left: 20.0),
              child: Text(
                'Top rated Doctors',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => BookAppointmentPage(doctorID: '1')));
                    },
                    child: Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.all(20.0),
                      child: Container(
                        width: 150,
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.0),
                                image: DecorationImage(
                                  image: AssetImage(doctor['profileImage']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              doctor['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String category;

  CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 100,
      margin: EdgeInsets.all(15.0),
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        category,
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
