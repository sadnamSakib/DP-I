import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'makeAppointment.dart';

class DoctorsListPage extends StatefulWidget {
  final String selectedCategory;
  const DoctorsListPage({super.key, required this.selectedCategory});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  CollectionReference doctorsCollection = FirebaseFirestore.instance.collection('doctors');
  late List<QueryDocumentSnapshot> doctors;
  late List<QueryDocumentSnapshot> searchedDoctors;
  TextEditingController searchController = TextEditingController(); // Step 1

  @override
  void initState() {
    super.initState();
    doctors = [];
    searchedDoctors = [];
    fetchDoctorData();
  }

  void fetchDoctorData() async {
    QuerySnapshot querySnapshot = await doctorsCollection
        .where('specialization', isEqualTo: widget.selectedCategory)
        .get();

    setState(() {
      doctors = querySnapshot.docs;
      searchedDoctors = doctors;
    });
  }

  void searchDoctors(String query) {
    List<QueryDocumentSnapshot> filteredDoctors = doctors
        .where((doctor) =>
        doctor['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      searchedDoctors = filteredDoctors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Doctors in ${widget.selectedCategory}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController, // Step 1
              decoration: InputDecoration(
                hintText: 'Search for a doctor by name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                searchDoctors(value);
                // Step 2
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchedDoctors.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    final doctorDocumentID = doctors[index].id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookAppointmentPage(doctorID: doctorDocumentID),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(searchedDoctors[index]['name']),
                      subtitle: Text(searchedDoctors[index]['specialization']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

