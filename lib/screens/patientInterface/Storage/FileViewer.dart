import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FileViewer extends StatefulWidget {
 final String URL;
  const FileViewer({super.key, required this.URL});

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {

  PDFDocument? document;

  void initializePDF() async{
    document = await PDFDocument.fromURL(widget.URL);
    setState(() {

    });
  }

  @override
  void initState(){
    super.initState();
    initializePDF();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: document!=null ?
      PDFViewer(
        document: document!,
      ):
      Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
