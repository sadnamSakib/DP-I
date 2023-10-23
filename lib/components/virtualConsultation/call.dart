
import 'package:design_project_1/components/virtualConsultation/callSettings.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

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
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: appId, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign: appSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: widget.userID,
      userName: widget.userName,
      callID: widget.callID,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}