// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:design_project_1/screens/patientInterface/Storage/Upload.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../Storage/FileViewer.dart';
// import '../Storage/Folder.dart';
//
// class ShareDocuments extends StatefulWidget {
//   const ShareDocuments({super.key});
//
//   @override
//   State<ShareDocuments> createState() => _ShareDocumentsState();
// }
//
// class _ShareDocumentsState extends State<ShareDocuments> {
//
//   String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';
//   bool doesCollectionExist = false;
//   late Future<QuerySnapshot> collectionSnapshot;
//
//   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
//   List<Map<String,dynamic>> fileData =[];
//
//   void getFiles() async {
//     String userID = userUID;
//
//     final files = await _firebaseFirestore.collection("Documents")
//         .where('name', isGreaterThanOrEqualTo: '$userID')
//         .where('name', isLessThan: '$userID' + 'z')
//         .get();
//
//
//     fileData= files.docs.map((e) => e.data()).toList();
//
//     setState(() {
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//       super.initState();
//       print('SharedDocuments initState called');
//       // Your initialization code here
//
//
//     // initializeData();
//     // getFiles();
//   }
//
//   Future<void> initializeData() async {
//
//
//     QuerySnapshot collectionSnapshot = await _firebaseFirestore
//         .collection('Documents')
//         .doc('Shared Documents')
//         .collection(userUID)
//         .get();
//
//     doesCollectionExist = collectionSnapshot.docs.isNotEmpty;
//
//     if(doesCollectionExist){
//       for (QueryDocumentSnapshot doc in collectionSnapshot.docs) {
//         print('Document ID: ${doc.id}');
//       }
//     }
//
//     print('Does collection exist? $doesCollectionExist');
//
//   }
//
//
//   Future<void> _createSharedDocuments(fileName,fileURL)async{
//
//     print('bcuiwfbiwfbgiwubgfwfi8' + fileName);
//     print(fileURL);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Share Documents'),
//         backgroundColor: Colors.blue.shade900,
//       ),
//
//         body: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.white70, Colors.blue.shade100],
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               FutureBuilder<QuerySnapshot>(
//                 future: _firebaseFirestore
//                     .collection('Documents')
//                     .doc('Shared Documents')
//                     .collection(userUID)
//                     .get(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return CircularProgressIndicator();
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   } else if ((!snapshot.hasData || snapshot.data!.docs.isEmpty) && fileData.isEmpty) {
//                     return Expanded(
//                       child: Container(
//                         padding: EdgeInsets.all(16.0),
//                         alignment: Alignment.center,
//                         child: Center(
//                           child: Column(
//                             children: [
//                               SizedBox(height: 20),
//                               Center(
//                                 child: Text(
//                                   'Share your reports and Prescriptions',
//                                   style: TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey.shade700,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//
//
//                   else {
//                     var collectionSnapshot = snapshot.data!;
//                     return Expanded(
//                       child: PageView.builder(
//                         itemCount: 2, // Two pages, one for folders and one for files
//                         controller: PageController(viewportFraction: 1),
//                         itemBuilder: (context, pageIndex) {
//                           if (pageIndex == 0) {
//                             if (collectionSnapshot.docs.isEmpty) {
//                               // Show a text when there are no folders
//                               return Center(
//                                 child:  Text(
//                                   'Create your folders',
//                                   style: TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey.shade700,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               );
//                             } else {
//                               /// Show the ListView.builder for folders
//                               return ListView.builder(
//                                 itemCount: collectionSnapshot.docs.length,
//                                 itemBuilder: (context, index) {
//                                   int folderIndex = index;
//                                   return Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: InkWell(
//                                       onTap: () {
//                                         String collectionName = collectionSnapshot.docs[folderIndex].id;
//                                         print('Tapped on collection: $collectionName');
//                                         Navigator.pushReplacement(
//                                           context,
//                                           MaterialPageRoute(builder: (context) => NewFolder(folderName: collectionName)),
//                                         );
//                                       },
//
//                                       child: Card(
//                                         color: Colors.white,
//                                         child: ListTile(
//                                           leading: Icon(Icons.folder),
//                                           title: Text(collectionSnapshot.docs[folderIndex].id),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             }
//
//
//                           } else {
//
//                             if (fileData.isEmpty) {
//                               return Center(
//                                 child: Text(
//                                   'Create your files',
//                                   style: TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey.shade700,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               );
//                             }
//
//                             else
//                             {
//                               return ListView.builder(
//                                 ///Show files
//                                 itemCount: fileData.length,
//                                 itemBuilder: (context, index) {
//                                   int fileIndex = index;
//                                   return Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: InkWell(
//                                       onDoubleTap: () {
//                                         String fileName = fileData[fileIndex]['name'];
//                                         String fileURL = fileData[fileIndex]['URL'];
//                                         String originalFileName = fileName.split('_').skip(1).join('_');
//                                         print('Tapped on file: $originalFileName, URL: $fileURL');
//                                         Navigator.pushReplacement(
//                                           context,
//                                           MaterialPageRoute(builder: (context) => FileViewer(URL: fileURL)),
//                                         );
//                                       },
//
//                                       child: Card(
//                                         color: Colors.white,
//                                         child: ListTile(
//                                           leading: Icon(Icons.file_copy_outlined),
//                                           title: Text(fileData[fileIndex]['name'].split('_').skip(1).join('_')),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             }
//                             // Display file data
//
//
//                           }
//                         },
//                       ),
//                     );
//                   }
//
//                 },
//               ),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           child: Icon(Icons.add),
//           onPressed: () {
//             showModalBottomSheet(
//               context: context,
//               builder: (BuildContext context) {
//                 return Container(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//
//                       ListTile(
//                         leading: Icon(Icons.file_upload),
//                         title: Text('Upload a File From your reports and Prescriptions'),
//
//                           onTap: () async {
//                             // Navigate to the 2nd screen
//                             await Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (context) => UploadFile()),
//                             );
//
//                             print('saffw');
//                             // Handle the data directly in the 1st screen
//                             Map<String, String>? result = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
//                             if (result != null) {
//                               String fileName = result['fileName'] ?? '';
//                               String fileURL = result['fileURL'] ?? '';
//
//                               // Do something with fileName and fileURL
//                               print('Received data from 3rd screen - fileName: $fileName, fileURL: $fileURL');
//                             } else {
//                               print('No data received from 3rd screen');
//                             }
//                           },
//
//
//                       ),
//                           SizedBox(height: 10),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         )
//
//     );
//   }
// }
