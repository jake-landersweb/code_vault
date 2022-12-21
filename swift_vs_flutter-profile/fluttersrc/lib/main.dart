import 'package:flutter/material.dart';
import 'package:fluttersrc/profile.dart';

void main() {
  runApp(const MyApp());
}

const mainColor = Color.fromRGBO(137, 107, 255, 1);
const bgColor = Color.fromRGBO(14, 18, 25, 1);
const bgColorAccent = Color.fromRGBO(20, 25, 32, 1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const Index(),
    );
  }
}

class Index extends StatelessWidget {
  const Index({super.key});

  @override
  Widget build(BuildContext context) {
    return const Profile();
  }
}
