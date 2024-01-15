import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:design_project_1/components/virtualConsultation/callSettings.dart';
import 'package:flutter/material.dart';

class VoiceCallPage extends StatefulWidget {
  final String callID;
  final String userName;
  final String userID;
  const VoiceCallPage({Key? key,required this.callID,required this.userID,required this.userName}) : super(key: key);
  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  late RtcEngine agoraEngine;
  final _users = <int>[];
  int? _remoteUid;
  bool _isJoined = false;


  @override
  void initState() {
    super.initState();
    setupVoiceSDKEngine();
  }

// Build UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Get started with Voice Calling'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              // Status text
              SizedBox(
                  height: 40,
                  child:Center(
                      child:_status()
                  )
              ),
              // Button Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Join"),
                      onPressed: () => {join()
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Leave"),
                      onPressed: () => {leave()},
                    ),
                  ),
                ],
              ),

                Visibility(
                  visible: _isJoined,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CircleAvatar(
                      radius: 50.0,
                      // Set the avatar image or customize as needed
                      backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
                    ),
                  ),
                ),

            ],
          )),
    );
  }

  Widget _status(){
    String statusText;

    if (!_isJoined) {
      statusText = 'Join a channel';
    } else if (_remoteUid == null)
      statusText = 'Waiting for a remote user to join...';
    else
      statusText = 'Connected to remote user, uid:$_remoteUid';

    return Text(
      statusText,
    );
  }


  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
        appId: appId,
    ));

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('onJoinChannelSuccess ${connection.channelId} $elapsed');
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("DOCTOR JOINED");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("DOCTOR LEFT");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }
  void  join() async {

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: 'docklinkr',
      options: options,
      uid: Random().nextInt(1000)
    );
    setState(() {
      _isJoined = true;
    });
    print("-------------------------------JOINED----------------------");
  }
  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }
  // Clean up the resources when you leave
  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    super.dispose();
  }


}
