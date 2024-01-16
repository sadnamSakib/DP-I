import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FileViewer extends StatefulWidget {
  final String URL;

  const FileViewer({Key? key, required this.URL}) : super(key: key);

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  bool isPDF = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }




  PDFDocument? document;

  void initialize() async{

    document = await PDFDocument.fromURL(widget.URL);

    setState(() {

    });
  }



  @override
  Widget build(BuildContext context) {
    bool isImage = widget.URL.toLowerCase().contains('.jpg') ||
        widget.URL.toLowerCase().contains('.png') ||
        widget.URL.toLowerCase().contains('.img');

    return Scaffold(
      body: isImage
          ?

            Image.network(
        widget.URL.toString(),
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {

            return child;
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      )
          : (document != null
          ? PDFViewer(document: document!)
          : Center(child: CircularProgressIndicator())),
    );
  }



}
