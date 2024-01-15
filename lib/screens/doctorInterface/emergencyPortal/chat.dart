import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/components/chatComponent/chatBubble.dart';
import 'package:design_project_1/components/chatComponent/textField.dart';
import 'package:design_project_1/components/emergencyCall/call.dart';
import 'package:design_project_1/services/chatServices/chatService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Chat extends StatefulWidget {
  final String receiverUserID;
  const Chat({super.key,  required this.receiverUserID,
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
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('patients').doc(widget.receiverUserID).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        else if(!snapshot.hasData){
          return CircularProgressIndicator();
        }
        else{
          Map<String, dynamic> data = snapshot.data?.data() as Map<String, dynamic>;
          String receiverName = data['name'];
          String receiverPhoneNumber = data['phone'];
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.pink.shade900,
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(receiverName),
              ),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () {
                      showCallModal(receiverPhoneNumber);
                    },
                  ),
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
            return const Text('Loading...');
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
    String messageId = document.id;
    var alignment = data['senderID'] == _auth.currentUser?.uid ? Alignment.centerRight : Alignment.centerLeft;
    if(data['message']=='Patient is requesting a call'){
      return Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: (data['senderID'] == _auth.currentUser?.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment: (data['senderID'] == _auth.currentUser?.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(data['senderName']),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade900,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => VoiceCallPage(callID: widget.receiverUserID, userID: _auth.currentUser!.uid, userName: _auth.currentUser!.displayName.toString())));
                      await FirebaseFirestore.instance.collection('chatrooms').doc(widget.receiverUserID).collection('messages').doc(messageId).update(
                          {
                            'message': 'Call accepted'
                          }
                      );
                  },
                  child: const Text(
                    'Accept call',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ]
          ),
        ),
      );
    }
    else if(data['message']=='Call accepted'){
      return Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: (data['senderID'] == _auth.currentUser?.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment: (data['senderID'] == _auth.currentUser?.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text("Call accepted at ${data['timestamp'].toDate().hour}:${data['timestamp'].toDate().minute}"),
              ]
          ),
        ),
      );
    }
    else
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
  void showCallModal(String receiverPhoneNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue.shade800,
          content: ListTile(
            tileColor: Colors.blue.shade800,
            leading: Icon(Icons.call, color: Colors.white),
            title: Text(receiverPhoneNumber, style: TextStyle(color: Colors.white)),
            onTap: () async {
              final Uri url = Uri(
                scheme: 'tel',
                path: receiverPhoneNumber,
              );
              print(receiverPhoneNumber);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
                print('Launched $url');
              } else {
                print('Could not launch $url');
              }
            },
          ),
        );
      },
    );
  }
}
