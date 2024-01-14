import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShareDocuments extends StatefulWidget {
  const ShareDocuments({super.key});

  @override
  State<ShareDocuments> createState() => _ShareDocumentsState();
}

class _ShareDocumentsState extends State<ShareDocuments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Documents'),
        backgroundColor: Colors.blue.shade900,
      ),
    );
  }
}
