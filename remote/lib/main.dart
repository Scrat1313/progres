import 'package:flutter/material.dart';
import 'package:remote/widget/landing.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Screen Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        primaryColor: Color.fromARGB(255, 138, 84, 53),
        secondaryHeaderColor: Color.fromARGB(255, 30, 30, 30),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LandingPage(),
    );
  }
}
