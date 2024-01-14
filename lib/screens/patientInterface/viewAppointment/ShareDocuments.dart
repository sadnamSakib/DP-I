import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Storage/FileViewer.dart';

class SharedDocuments extends StatefulWidget {
  final String doctorID;

  const SharedDocuments({Key? key, required this.doctorID}) : super(key: key);


  @override
  State<SharedDocuments> createState() => _SharedDocumentsState();
}

class _SharedDocumentsState extends State<SharedDocuments> {

  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<Map<String, dynamic>> allFilesData=[];

  Future<void> getFiles() async {
    try {

      QuerySnapshot filesSnapshot = await FirebaseFirestore.instance
          .collection('Documents')
          .doc('Shared Documents')
          .collection(userUID)
          .doc(widget.doctorID)
          .collection('Files')
          .get();

      if (filesSnapshot.docs.isNotEmpty) {
        allFilesData = filesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        setState(() {

        });

        for (var data in allFilesData) {
          print('File Data: $data');
        }

        print('All Files Data: $allFilesData');
      } else {
        print('No documents found in the Files subcollection.');
      }
    } catch (e) {
      print('Error retrieving files data: $e');
    }
  }

  @override
  void initState()
  {
    super.initState();
    getFiles();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      appBar: AppBar(
        title: Text('Shared Documents'),
        backgroundColor: Colors.blue.shade900,
      ),
        body:  Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white70, Colors.blue.shade100],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              allFilesData.isEmpty
                  ? Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Share Reports and Prescriptions from yor account',
                            style: TextStyle(fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,),
                            textAlign: TextAlign.center,),
                        ),
                      ],),
                  ),
                ),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: allFilesData.length,
                  itemBuilder: (context, index) {
                    if (index < allFilesData.length) {
                      // Display file data
                      String fileName = allFilesData[index]['name'];
                      String fileURL = allFilesData[index]['URL'];
                      return

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onDoubleTap: () {
                              print('Tapped on file: $fileName, URL: $fileURL');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FileViewer(URL: fileURL),
                                ),
                              );
                            },

      
                            onLongPress: () {
                              _showDeleteConfirmationDialog(allFilesData[index]['name']);
                            },
                            child: Card(
                              color: Colors.white,
                              child: ListTile(
                                leading: Icon(Icons.file_copy),
                                title: Text(
                                  allFilesData[index]['name'],
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        );



                    }
                  },
                ),
              ),
            ],
          ),
        )
    );
  }



  Future<void> _showDeleteConfirmationDialog(String fileName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove File'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to remove this file?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Remove'),
              onPressed: () {
                // Perform delete operation
                deleteFile(fileName);
                Navigator.of(context).pop();
                initState();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteFile(String fileName) async {
    try {
      await FirebaseFirestore.instance
          .collection("Documents")
          .doc('Shared Documents')
          .collection(userUID)
          .doc(widget.doctorID)
          .collection('Files')
          .where("name", isEqualTo: fileName)
          .limit(1)  // Limit to one document
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.delete();
        });
      });



      print("File deletedddddd successfully");
      Fluttertoast.showToast(
        msg: 'File Removed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );

    Navigator.pop(context);
    } catch (error) {
      print("Error deleting file: $error");
    }
  }

}
