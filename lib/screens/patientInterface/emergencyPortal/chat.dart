import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/components/chatComponent/chatBubble.dart';
import 'package:design_project_1/components/chatComponent/textField.dart';
import 'package:design_project_1/services/chat/chatService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class Chat extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const Chat({super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<Chat> createState() => _ChatState();
}


class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    _chatService.requestEmergency();
  }
  void sendMessage() async{
    if(_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('chatrooms').doc(widget.receiverUserID).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   print(widget.receiverUserID);
        //   print(currentUserId);
        //   print("waiting hoitese");
        //   return Scaffold(
        //     body: Center(
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: <Widget>[
        //           CircularProgressIndicator(),
        //           Text('More jao'),
        //         ],
        //       ),
        //     ),
        //   );
        // }

        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          print("ki je hoitese");
          print(snapshot.data!.data());
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue.shade900,
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.receiverUserEmail),
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
                Text(data['senderEmail']),
                ChatBubble(message: data['message']),
              ]
          ),
        )
    );
  }
}
