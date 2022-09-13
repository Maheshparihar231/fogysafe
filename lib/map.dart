// ignore_for_file: use_key_in_widget_constructors, prefer_final_fields, prefer_const_constructors, duplicate_ignore, camel_case_types, unnecessary_new, unnecessary_this, unnecessary_null_comparison, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fogysafe/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class map extends StatefulWidget {
  @override
  State<map> createState() => mapState();
}

class mapState extends State<map> {
  late GoogleMapController _controller;
  LatLng? latlng;
  StreamSubscription? _locationSubscription;
  Location _locationTracker = Location();
  final Set<Marker> _markers = {};
  final Set<Circle> _circle = {};
  bool condition = false;
  // ignore: prefer_const_constructors

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    sendlocation(newLocalData.latitude!, newLocalData.longitude!);
    //print("latilongi xdlemon = ${latlng.latitude} , ${latlng.longitude} ");
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
    main();
    //time = Timer.periodic(duration, callback) Duration(seconds: 1);
    print("latilongi xdlemon = $lat , $long ,${time.toString()}");
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
            condition = false;
          } else {
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
