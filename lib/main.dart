import 'package:flutter/material.dart';
import 'package:fogysafe/map.dart';


//https://script.google.com/macros/s/AKfycbzNmTNRryD4q0Bo666_lufNk2CEA97L9qgOVwX95Y0RBkFMmqQjqrJuC0O9eEcbSyoS2A/exec


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fogysafe',
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark
      ),
      debugShowCheckedModeBanner: false,
      home: map(),
    );
  }
}