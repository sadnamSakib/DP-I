import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Upload.dart';

class DoctorswithAppointments extends StatefulWidget {
  final List<String> doctorIds;
  final String fileName;
  final String fileURL;
  const DoctorswithAppointments({Key? key,required this.doctorIds, required this.fileName, required this.fileURL}):super(key: key);

  @override
  State<DoctorswithAppointments> createState() => _DoctorswithAppointmentsState();
}

class _DoctorswithAppointmentsState extends State<DoctorswithAppointments> {

    String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

    List<Map<String, dynamic>> doctorsInfo = [];

      List<Map<String, dynamic>> filteredDoctors = [];

      Future<List<Map<String, dynamic>>> getDoctorsInfo() async {

    try {
      CollectionReference doctorsCollection = FirebaseFirestore.instance.collection('doctors');


      for (String doctorId in widget.doctorIds) {
        DocumentSnapshot doctorSnapshot = await doctorsCollection.doc(doctorId).get();
        print(doctorId);

        if (doctorSnapshot.exists) {

          Map<String, dynamic> doctorData = doctorSnapshot.data() as Map<String, dynamic>;
          doctorData['doctorId'] = doctorSnapshot.id;
         setState(() {

          doctorsInfo.add(doctorData);
          filteredDoctors = doctorsInfo;
         });
        }
      }

      return doctorsInfo;
    } catch (e) {
      print('Error fetching doctors information: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    getDoctorsInfo();

  }

      void searchDoctors(String query) {
        setState(() {
          filteredDoctors = doctorsInfo
              .where((doctor) => doctor['name'].toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text('Share Documents'),
        ),
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
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) => searchDoctors(value),
                    decoration: InputDecoration(
                      labelText: 'Search for Doctors',
                      // border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredDoctors.isEmpty
                      ? Center(
                    child: Text('Search for Doctors you have appointment with',
                      style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                      textAlign: TextAlign.center,),
                  )
                      :
                  ListView.builder(
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {

                            print(filteredDoctors[index]['doctorId']);
                            shareFileWithDoctor(filteredDoctors[index]['doctorId']);
                          },
                          child:

                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueGrey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          filteredDoctors[index]['name']?? '',
                                          style: TextStyle(color: Colors.black,  fontSize: 18),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          filteredDoctors[index]['specialization']?? '',
                                          style: TextStyle(color: Colors.black,  fontSize: 18),
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ),
                      );
                    },
                  )
                  ,

                ),
              ],
            ),
          ),


      );
  }

    Future<void> shareFileWithDoctor(String doctorID) async {
      try {

        await FirebaseFirestore.instance
            .collection("Documents")
            .doc('Shared Documents')
            .collection(userUID)
            .doc(doctorID)
            .collection('Files')
            .add({
          "name": widget.fileName,
          "URL": widget.fileURL,
        });


        print("File shared successfully!");

        Fluttertoast.showToast(
          msg: 'File Shared Successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.white,
          textColor: Colors.black,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadFile()),
        );

      } catch (e) {
        print("Error sharing file: $e");
      }
    }

}
