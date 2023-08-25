import 'dart:io';

import 'package:callkeep/callkeep.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:smart_home/controllers/state_controller.dart';
import 'package:smart_home/pages/register_page.dart';
import 'package:smart_home/pages/settings_page.dart';
import 'package:smart_home/pages/call_screen.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'dart:developer';

const MethodChannel methodChannel =
    MethodChannel("com.intellex.hometek.smart_home/isGmsAvailable");

final FlutterCallkeep callKeepInst = FlutterCallkeep();
bool callKeepInitialized = false;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("_firebaseMessagingBackgroundHandler");
  var callerId = message.data['caller_id'];
  var callerName = message.data['caller_name'];
  var hasVideo = message.data['has_video'] == "true";
  var uuid = message.data['uuid'] ?? const Uuid().v4();
  callKeepInst.on(CallKeepPerformAnswerCallAction(),
      (CallKeepPerformAnswerCallAction e) {
    callKeepInst.setCurrentCallActive(uuid);
  });
  Map<String, dynamic> setupJson = {
    "ios": {
      "appName": "Smart Home",
    },
    "android": {
      "alertTitle": "Permissions required",
      "alertDescription":
          "This application needs to access your phone accounts",
      "cancelButton": "Cancel",
      "okButton": "ok",
      "foregroundService": {
        "channelId": "com.intellex.hometek",
        "channelName": "Smart Home Service",
        "notificationTitle": "Call Service is running in background",
        "notificationIcon": "",
      },
    },
  };
  if (!callKeepInitialized) {
    callKeepInst.setup(null, setupJson, backgroundMode: true);
  }
  callKeepInitialized = true;
  callKeepInst.displayIncomingCall(uuid, "sip:1000@172.24.245.50",
      localizedCallerName: "test", hasVideo: hasVideo);
  callKeepInst.backToForeground();
}

Future<bool> isGMSAvailable() async {
  bool status = false;
  try {
    status = await methodChannel.invokeMethod("isGmsAvailable");
    // ignore: empty_catches
  } on PlatformException {}
  if (status) {
    debugPrint("GMS is available");
  } else {
    debugPrint("GMS is not available");
  }
  return status;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await isGMSAvailable();
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("_firebaseMessagingBackgroundHandler");
    var callerId = message.data['caller_id'];
    var callerName = message.data['caller_name'];
    var hasVideo = message.data['has_video'] == "true";
    var uuid = message.data['uuid'] ?? const Uuid().v4();
    callKeepInst.on(CallKeepPerformAnswerCallAction(),
        (CallKeepPerformAnswerCallAction e) {
      callKeepInst.setCurrentCallActive(uuid);
    });
    Map<String, dynamic> setupJson = {
      "ios": {
        "appName": "Smart Home",
      },
      "android": {
        "alertTitle": "Permissions required",
        "alertDescription":
            "This application needs to access your phone accounts",
        "cancelButton": "Cancel",
        "okButton": "ok",
        "foregroundService": {
          "channelId": "com.intellex.hometek",
          "channelName": "Smart Home Service",
          "notificationTitle": "Call Service is running in background",
          "notificationIcon": "",
        },
      },
    };
    if (!callKeepInitialized) {
      callKeepInst.setup(null, setupJson, backgroundMode: false);
    }
    callKeepInitialized = true;
    callKeepInst.displayIncomingCall(uuid, callerId,
        localizedCallerName: callerName, hasVideo: hasVideo);
  });
  await GetStorage.init();
  final fcmToken = await FirebaseMessaging.instance.getToken();

  GetStorage().write('token', fcmToken);
  debugPrint(fcmToken);
  // add profiling trace
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final controller = Get.put(StateController());
  final SIPUAHelper helper = SIPUAHelper();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    controller.token = GetStorage().read('token').toString();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh', 'TW')],
      title: 'Smart Home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: ''),
      routes: {
        'callscreen': (context) => CallScreenWidget(helper),
        'settings': (context) => const SettingsWidget(),
        'register': (context) => RegisterWidget(helper),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '',
            ),
            Text(
              '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_menu),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: false)
                    .pushNamed('settings');
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.register_menu),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: false)
                    .pushNamed('register');
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.callscreen_menu),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: false)
                    .pushNamed('callscreen');
              },
            )
          ],
        ),
      ),
    );
  }
}
