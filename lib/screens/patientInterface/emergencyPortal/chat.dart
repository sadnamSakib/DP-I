import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/components/chatComponent/chatBubble.dart';
import 'package:design_project_1/components/chatComponent/textField.dart';
import 'package:design_project_1/services/chat/chatService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class Chat extends StatefulWidget {
  final String receiverUserID;
  final String initialMessage;
  const Chat({super.key,  required this.receiverUserID, required this.initialMessage,
  });

  @override
  State<Chat> createState() => _ChatState();
}


class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final _auth = FirebaseAuth.instance;

  void sendMessage() async{
    if(_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }
  @override
  void initState() {
    super.initState();
    _messageController.text = widget.initialMessage;
    sendMessage();
  }
  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('emergencyRequests').doc(widget.receiverUserID).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {


        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          print("ki je hoitese");
          print(snapshot.data!.data());
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue.shade900,
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text("Emergency Portal"),
              ),
            ),
            body: Column(
              children:[
                Expanded(
                  child: _buildMessageList(),
                ),
                _buildMessageInput(),
              ],
            ),
          );
        } else {
          print("data nai");
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text('Trying to connect to an emergency doctor...',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
  //build message list
  Widget _buildMessageList(){
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverUserID, _auth.currentUser!.uid),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return Text('Error: ${snapshot.error}');
          }

          if(snapshot.connectionState == ConnectionState.waiting){
            return Text('Loading...');
          }
          return ListView(
            children: snapshot.data!.docs.map<Widget>((document) => _buildMessageItem(document)).toList(),
          );
        }
    );
  }
  //build message input
  Widget _buildMessageInput(){
    return Row(
        children: [
          Expanded(
            child: ModifiedTextField(
              controller: _messageController,
              hintText: 'Type a message',
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            color: Colors.blue.shade900,
            icon: const Icon(Icons.arrow_upward,
              size: 40,
            ),
          ),
        ]
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = data['senderID'] == _auth.currentUser?.uid ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: (data['senderID'] == _auth.currentUser?.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment: (data['senderID'] == _auth.currentUser?.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(data['senderName']),
                ChatBubble(message: data['message']),
              ]
          ),
        )
    );
  }
}
