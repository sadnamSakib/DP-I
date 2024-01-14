import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/components/chatComponent/chatBubble.dart';
import 'package:design_project_1/components/chatComponent/textField.dart';
import 'package:design_project_1/screens/patientInterface/emergencyPortal/requestEmergencyScreen.dart';
import 'package:design_project_1/screens/patientInterface/home/home.dart';
import 'package:design_project_1/services/chatServices/chatService.dart';
import 'package:design_project_1/services/notificationServices/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
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
  NotificationServices  notificationServices = NotificationServices();
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
    if(widget.initialMessage.isNotEmpty){
      _messageController.text = widget.initialMessage;
      sendMessage();
    }
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
              actions: [
                ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => confirmDeleteDialog(context),
                      );
                    },
                    child:
                    const Text('End chat',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    )
                ),
              ],

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

  Widget confirmDeleteDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Confirm Delete"),
      content: Text("Are you sure you want to delete this message?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: ()  {
            _chatService.dismissEmergencyChat();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  Home()),
            );
          },
          child: Text("Delete"),
        ),
      ],
    );
  }
}

