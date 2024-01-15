import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/BookAppointment/doctorsListPage.dart';
import 'package:flutter/material.dart';
import '../../../services/searchServices/SearchBarDelegator.dart';
import '../../../services/authServices/auth.dart';
import '../../../services/searchServices/categorySearchDelegate.dart';
import '../../../utilities/doctorSpecialization.dart';
import './makeAppointment.dart';

class DoctorFinder extends StatefulWidget {
  const DoctorFinder({Key? key});

  @override
  State<DoctorFinder> createState() => _DoctorFinderState();
}

class _DoctorFinderState extends State<DoctorFinder> {
  final AuthService _auth = AuthService();
  String selectedCategory = '';

  void onSelectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');
  CollectionReference doctorsCollection =
  FirebaseFirestore.instance.collection('doctors');

  Future<QuerySnapshot> fetchUserData() {
    return usersCollection.get();
  }

  Future<QuerySnapshot> fetchDoctorData() {
    return doctorsCollection.get();
  }

  SearchDelegate<String> createSearchBarDelegate() {
    return SearchBarDelegate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text('DocLinkr'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.blue.shade100],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Find your desired specialist',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                readOnly: true,
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: CategorySearchDelegate(specializations: specializations),
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Search by Specialization',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
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
                      return CategoryTile(
                        category: category,
                        onSelectCategory: onSelectCategory, // Step 2: Pass the callback function
                      );
                    }).toList(),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Top rated Doctors',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: Future.wait([fetchUserData(), fetchDoctorData()]),
                builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                  }

                  final userData = snapshot.data?[0].docs;
                  final doctorData = snapshot.data?[1].docs;
                  final doctorDocumentID = '';
                  final doctors = userData?.where((userDoc) {
                    final userData = userDoc.data() as Map<String, dynamic>;
                    return userData['role'] == 'doctor';
                  }).toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: doctors?.length ?? 0,
                    itemBuilder: (context, index) {
                      final user = doctors?[index].data() as Map<String, dynamic>;
                      final userDocumentID = doctors?[index].id;

                      final userDoctors = doctorData?.where((doc) {
                        final doctorDocumentID = doc.id;
                        return userDocumentID == doctorDocumentID;
                      }).toList();

                      if (userDoctors != null && userDoctors.isNotEmpty) {
                        return InkWell(
                          onTap: () {
                            final doctorDocumentID = userDocumentID; // Assign userDocumentID to doctorDocumentID
                            print(doctorDocumentID);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookAppointmentPage(doctorID: doctorDocumentID),
                              ),
                            );
                          },
                          child: Container(
                            height: 220,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    children: userDoctors.map((doctor) {
                                      String imageURL = user['profile'] as String? ?? '';
                                      return DoctorCard(
                                        name: user['name'] as String? ?? '',
                                        profileImage: imageURL,
                                        specialization: doctor['specialization'] as String? ?? '',
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox();
                      }
                    },
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


class CategoryTile extends StatefulWidget {
  final String category;
  final Function(String) onSelectCategory; // Step 1: Declare a callback function
  CategoryTile({required this.category, required this.onSelectCategory});

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
   String selectedCategory = '';

  void onSelectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:() {
        onSelectCategory(widget.category);
        print("Jalay bachina");
        print(selectedCategory);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorsListPage(selectedCategory: selectedCategory)));
      },
      child: Container(
        width: 170,
        height: 100,
        margin: EdgeInsets.all(15.0),
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          widget.category,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String profileImage;
  final String specialization;
  final defaultImage = Image.asset('assets/images/doctor.png').image;

  DoctorCard({
    required this.name,
    required this.profileImage,
    required this.specialization,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(20.0),
        child: Container(
          width: 180,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: profileImage.isEmpty
                          ? defaultImage
                          : NetworkImage(profileImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 5),
              Text(
                specialization,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
