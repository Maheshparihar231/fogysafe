import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fogysafe/map.dart';
import 'dart:async';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fogysafe/main.dart';
import 'package:fogysafe/mapdata.dart';
import 'package:fogysafe/sender.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

//https://script.google.com/macros/s/AKfycbzNmTNRryD4q0Bo666_lufNk2CEA97L9qgOVwX95Y0RBkFMmqQjqrJuC0O9eEcbSyoS2A/exec

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'high_importance_notifications',
    importance: Importance.high, playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundhandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A big message just show up: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundhandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fogysafe',
      theme: ThemeData(primarySwatch: Colors.red, brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: map(),
    );
  }
}

class map extends StatefulWidget {
  @override
  State<map> createState() => mapState();
}

class mapState extends State<map> {
  final FlutterTts flutterTts = FlutterTts();
  late GoogleMapController _controller;
  LatLng? latlng;
  StreamSubscription? _locationSubscription;
  Location _locationTracker = Location();
  final Set<Marker> _markers = {};
  final Set<Circle> _circle = {};
  bool condition = false;
  double lons = 0, lats = 0;
  // ignore: prefer_const_constructors

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              //channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            )
          )
        );
      }
    });
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    sendlocation(newLocalData.latitude!, newLocalData.longitude!);
    //showalert(newLocalData.latitude!, newLocalData.longitude!);
    //print("latilongi xdlemon = ${latlng.latitude} , ${latlng.longitude} ");
    // ignore: unnecessary_this
    this.setState(() {
      _markers.add(Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading!,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData)));

      _circle.add(Circle(
          circleId: CircleId('car'),
          radius: newLocalData.accuracy!,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70)));
    });
  }

  void sendlocation(double lat, double long) {
    DateTime time = DateTime.now();
    if (condition) {
      //print("latilongi xdlemon = $lat , $long ,${time.toString()}");
      FeedbackForm feedbackForm = FeedbackForm(
        lat.toString(),
        long.toString(),
        time.toString(),
      );

      FormController formController = FormController((String response) {
        print("Response : $response");
      });

      formController.submitForm(feedbackForm);
    }
    //time = Timer.periodic(duration, callback) Duration(seconds: 1);
  }

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(
      37.42796133580664,
      -122.085749655962,
    ),
    zoom: 15,
  );
  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();
      updateMarkerAndCircle(location, imageData);
      if (_locationSubscription != null) {
        _locationSubscription?.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target:
                      LatLng(newLocalData.latitude!, newLocalData.longitude!),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription?.cancel();
    }
    super.dispose();
  }

/*
  void appstate(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }
*/
/*  void showalert(double latc, double longc) {
    double distance = 0;
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lats - latc) * p) / 2 +
        cos(latc * p) * cos(lats * p) * (1 - cos((lons - longc) * p)) / 2;
    distance = 12742 * asin(sqrt(a));
    if (condition && distance < 1) {
      AwesomeDialog(
              context: context,
              title: "title",
              desc: "des",
              btnOkOnPress: () {})
          .show();
    }
  }
*/
  void speak() async {
    await flutterTts.setLanguage("en-");
    await flutterTts.setPitch(1); //0   to 0.5
    await flutterTts.speak("Warning ahead");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: _kGooglePlex,
        markers: _markers, //Set.of((marker != null) ? [marker] : []),
        circles: _circle, //Set.of((circle != null) ? [circle] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          getCurrentLocation();
          if (condition) {
            AwesomeDialog(
              context: context,
              title: "Stopped",
              //desc: "des",
              dialogType: DialogType.warning,
              animType: AnimType.topSlide,
              btnOkColor: Colors.red,
              btnOkOnPress: () {},
            ).show();
            condition = false;
          } else {
            AwesomeDialog(
              context: context,
              title: "Sending...",
              //desc: "des",
              dialogType: DialogType.success,
              animType: AnimType.topSlide,
              btnOkOnPress: () {},
            ).show();
            condition = true;
          }
          //if (!condition) condition = true;
        },
        label: condition ? Text('Stop') : Text('Send!'),
        icon: condition
            ? Icon(Icons.stop_circle_rounded)
            : Icon(Icons.play_arrow),
        backgroundColor: condition ? Colors.red : Colors.green,
      ),
    );
  }
}
