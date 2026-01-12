import 'package:flutter/material.dart';
import 'package:hrportal/views/locationMap.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parivartan',
      theme: ThemeData.light(),
      home: AttendanceMapScreen(),
    );
  }
}
