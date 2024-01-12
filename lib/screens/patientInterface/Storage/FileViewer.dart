import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';

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
    initializePDF();
  }

  PDFDocument? document;

  void initializePDF() async{
    document = await PDFDocument.fromURL(widget.URL);
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    bool isImage = widget.URL.contains('.JPG') || widget.URL.endsWith('.png') || widget.URL.endsWith('.img');

    return Scaffold(
      body: isImage
          ? Image.network(
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
