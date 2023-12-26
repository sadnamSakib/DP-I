import 'package:flutter/material.dart';
class ChatBubble extends StatelessWidget {
  final String message;
  const ChatBubble({super.key,
    required this.message,});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
        ),
      )
    );
  }
}
