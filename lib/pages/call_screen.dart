import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_webrtc/flutter_webrtc.dart";
import "package:get/get.dart" as getx;
import "package:get_storage/get_storage.dart";
import "package:permission_handler/permission_handler.dart";
import "package:sip_ua/sip_ua.dart";
import "package:smart_home/controllers/state_controller.dart";

class CallScreenWidget extends StatefulWidget {
  const CallScreenWidget(this._helper, {super.key});
  final SIPUAHelper? _helper;

  @override
  State<CallScreenWidget> createState() => _CallScreenWidgetState();
}

class _CallScreenWidgetState extends State<CallScreenWidget>
    implements SipUaHelperListener {
  final controller = getx.Get.find<StateController>();
  String displayName = "";
  String wsUri = "";
  String sipUri = "";
  String authUser = "";
  String password = "";
  bool _audioMuted = false;
  bool _videoMuted = false;
  bool _hold = false;
  String? _holdOriginator;
  TextEditingController? calleeUriController = TextEditingController();
  CallStateEnum _state = CallStateEnum.NONE;

  SIPUAHelper? get helper => widget._helper;
  String? receiveMessage;

  @override
  void initState() {
    super.initState();
    helper!.addSipUaHelperListener(this);
    loadFromStorage();
  }

  void loadFromStorage() {
    setState(() {
      displayName = '1000';
      wsUri = GetStorage().read('ws_uri') ?? 'ws://192.168.8.5:5066/ws';
      sipUri = 'sip:$displayName@172.24.245.50';
      password = GetStorage().read('password') ?? '5678';
      authUser = GetStorage().read('auth_user') ?? '1000';
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    helper!.removeSipUaHelperListener(this);
    saveToStorage();
  }

  void saveToStorage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dial Screen')),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: digitButtons()),
    );
  }

  List<Widget> digitButtons() {
    var digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];
    return [
      SizedBox(
        width: 350,
        child: Row(
          children: [
            SizedBox(
              width: 350,
              child: TextField(
                controller: calleeUriController,
              ),
            )
          ],
        ),
      ),
      SizedBox(
          width: 350,
          child: Column(
              children: digits
                  .map((row) => Row(
                      children: row
                          .map((digit) => TextButton(
                              child: Text(digit.toString()),
                              onPressed: () => tapDigit(digit)))
                          .toList()))
                  .toList())),
      SizedBox(
          width: 300,
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () => actionCall(context, true),
                  ),
                ],
              )))
    ];
  }

  Future<Widget?> actionCall(BuildContext context,
      [bool voiceOnly = false]) async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await Permission.microphone.request();
      await Permission.camera.request();
    }

    final mediaConstraints = <String, dynamic>{'audio': true, 'video': true};

    MediaStream mediaStream;

    if (kIsWeb && !voiceOnly) {
      mediaStream =
          await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      mediaConstraints['video'] = false;
      MediaStream userStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      mediaStream.addTrack(userStream.getAudioTracks()[0], addToNative: true);
    } else {
      mediaConstraints['video'] = !voiceOnly;
      mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    }

    helper!.call(
        "${calleeUriController?.text.isEmpty ?? true ? displayName : calleeUriController?.text}@${controller.registeredDomain}",
        voiceonly: voiceOnly,
        mediaStream: mediaStream);
    return null;
  }

  void tapDigit(String digit) {
    setState(() {
      calleeUriController!.text += digit;
    });
  }

  @override
  void callStateChanged(Call call, CallState state) {
    if (state.state == CallStateEnum.HOLD ||
        state.state == CallStateEnum.UNHOLD) {
      _hold = state.state == CallStateEnum.HOLD;
      _holdOriginator = state.originator;
      setState(() {});
      return;
    }
    if (state.state == CallStateEnum.MUTED ||
        state.state == CallStateEnum.UNMUTED) {
      if (state.audio!) _audioMuted = state.state == CallStateEnum.MUTED;
      if (state.video!) _videoMuted = state.state == CallStateEnum.MUTED;
      setState(() {});
      return;
    }
    if (state.state != CallStateEnum.STREAM) {
      _state = state.state;
    }

    switch (state.state) {
      case CallStateEnum.STREAM:
        handelRTP(state);
        break;
      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        exitAndTryPop();
        break;
      case CallStateEnum.UNMUTED:
      case CallStateEnum.MUTED:
      case CallStateEnum.CONNECTING:
      case CallStateEnum.PROGRESS:
      case CallStateEnum.ACCEPTED:
      case CallStateEnum.CONFIRMED:
      case CallStateEnum.HOLD:
      case CallStateEnum.UNHOLD:
      case CallStateEnum.NONE:
      case CallStateEnum.CALL_INITIATION:
      case CallStateEnum.REFER:
        break;
    }
  }

  void handelRTP(CallState state) async {
    // TODO: implement onNewMessage
  }

  void exitAndTryPop() {
    Navigator.of(context).pop();
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    // TODO: implement onNewMessage
  }

  @override
  void onNewNotify(Notify ntf) {
    // TODO: implement onNewNotify
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    // TODO: implement registrationStateChanged
  }

  @override
  void transportStateChanged(TransportState state) {
    // TODO: implement transportStateChanged
  }
}
