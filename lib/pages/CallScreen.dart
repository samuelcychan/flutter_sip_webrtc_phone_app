import "package:flutter/material.dart";
import "package:sip_ua/sip_ua.dart";

class CallScreenWidget extends StatefulWidget {
  const CallScreenWidget(this._helper, {super.key});
  final SIPUAHelper? _helper;

  @override
  State<CallScreenWidget> createState() => _CallScreenWidgetState();
}

class _CallScreenWidgetState extends State<CallScreenWidget>
    implements SipUaHelperListener {
  bool _audioMuted = false;
  bool _videoMuted = false;
  bool _hold = false;
  String? _holdOriginator;
  CallStateEnum _state = CallStateEnum.NONE;

  SIPUAHelper? get helper => widget._helper;

  @override
  void initState() {
    super.initState();
    helper!.addSipUaHelperListener(this);
  }

  @override
  void deactivate() {
    super.deactivate();
    helper!.removeSipUaHelperListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
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
