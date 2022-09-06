import 'package:flutter/material.dart';
import 'package:fogysafe/map.dart';

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