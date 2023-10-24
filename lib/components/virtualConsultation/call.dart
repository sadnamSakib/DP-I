
import 'package:design_project_1/components/virtualConsultation/callSettings.dart';
import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';

class CallPage extends StatefulWidget {
  final String callID;
  final String userName;
  final String userID;
  const CallPage({Key? key, required this.callID , required this.userID , required this.userName}) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {

  @override
  void initState() {
    super.initState();
    print(widget.callID);
    print(widget.userID);
    print(widget.userName);
    initAgora();
  }


  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: appId,
      channelName: "doclinkr",
      tempToken: token,
    ),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );


  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(client: client),
              AgoraVideoButtons(client: client)
            ],
          ),
        ),
      ),
    );
  }
}