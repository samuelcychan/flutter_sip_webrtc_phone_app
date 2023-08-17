import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:smart_home/controllers/state_controller.dart';

class RegisterWidget extends StatefulWidget {
  final SIPUAHelper? _helper;
  const RegisterWidget(this._helper, {super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget>
    implements SipUaHelperListener {
  final controller = Get.find<StateController>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _wsUriController = TextEditingController();
  final TextEditingController _sipUriController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _authUserController = TextEditingController();
  final Map<String, String> _wsExtraHeaders = {};

  late RegistrationState _registerState;
  SIPUAHelper? get helper => widget._helper;

  @override
  void initState() {
    super.initState();
    _registerState = helper!.registerState;
    helper!.addSipUaHelperListener(this);
    loadFromStorage();
  }

  void loadFromStorage() {
    setState(() {
      _wsUriController.text =
          GetStorage().read('ws_uri') ?? 'ws://192.168.8.5:5066/ws';
      _sipUriController.text =
          GetStorage().read('sip_uri') ?? 'sip:1000@172.27.81.194';
      _displayNameController.text = GetStorage().read('display_name') ?? '1000';
      _passwordController.text = GetStorage().read('password') ?? '5678';
      _authUserController.text = GetStorage().read('auth_user') ?? '1000';
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    helper!.removeSipUaHelperListener(this);
    saveToStorage();
  }

  void saveToStorage() {
    GetStorage().write('ws_uri', _wsUriController.text);
    GetStorage().write('sip_uri', _sipUriController.text);
    GetStorage().write('display_name', _displayNameController.text);
    GetStorage().write('password', _passwordController.text);
    GetStorage().write('auth_user', _authUserController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(child: Text(controller.token)),
          Padding(
            padding: const EdgeInsets.fromLTRB(48.0, 18.0, 48.0, 18.0),
            child: Center(
                child: Text(
              'Register Status: ${EnumHelper.getName(_registerState.state)}',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            )),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(48.0, 18.0, 48.0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('WebSocket:'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
            child: TextFormField(
              controller: _wsUriController,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('SIP URI:'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
            child: TextFormField(
              controller: _sipUriController,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Authorization User:'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
            child: TextFormField(
              controller: _authUserController,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
                hintText: _authUserController.text.isEmpty ? '[Empty]' : null,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
            child: Align(
              child: Text('Password:'),
              alignment: Alignment.centerLeft,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
            child: TextFormField(
              controller: _passwordController,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
                hintText: _passwordController.text.isEmpty ? '[Empty]' : null,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Display Name:'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
            child: TextFormField(
              controller: _displayNameController,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 18.0, 0.0, 0.0),
            child: SizedBox(
              height: 48.0,
              width: 160.0,
              child: MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () => handleSave(context),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void handleSave(BuildContext context) {
    UaSettings settings = UaSettings();

    settings.webSocketUrl = _wsUriController.text;
    settings.webSocketSettings.extraHeaders = _wsExtraHeaders;
    settings.webSocketSettings.allowBadCertificate = true;

    settings.registerParams.extraContactUriParams = <String, String>{
      'pn-platform': 'iOS',
      'app-id': 'com.carusto.mobile.app',
      'pn-voip-tok': controller.token,
    };
    settings.uri = _sipUriController.text;
    settings.authorizationUser = _authUserController.text;
    settings.password = _passwordController.text;
    settings.displayName = _displayNameController.text;
    settings.userAgent = 'Dart SIP Client v1.0.0';
    settings.dtmfMode = DtmfMode.RFC2833;

    helper!.start(settings);
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    setState(() {
      _registerState = state;
    });
  }

  @override
  void callStateChanged(Call call, CallState state) {}

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void onNewNotify(Notify ntf) {}

  @override
  void transportStateChanged(TransportState state) {}
}
