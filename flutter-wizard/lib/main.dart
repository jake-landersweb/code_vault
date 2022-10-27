import 'package:flutter/material.dart';
import 'package:flutter_ui/wizard/model.dart';
import 'package:flutter_ui/wizard/wizard.dart';
import 'package:sprung/sprung.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Wizard(
        curve: Sprung.overDamped,
        duration: const Duration(milliseconds: 700),
        pages: [
          WizardItem(
            title: "Static",
            icon: Icons.star_outline,
            child: const Center(
              child: Text("static page"),
            ),
          ),
          WizardItem(
            title: "Scrollable",
            icon: Icons.scatter_plot_outlined,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.grey,
                    child: const SizedBox(
                      height: 1000,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
          WizardItem(
            title: "Page 3",
            icon: Icons.three_k,
            child: const Center(
              child: Text("Page 3"),
            ),
          ),
          WizardItem(
            title: "Page 4",
            icon: Icons.four_k,
            child: const Center(
              child: Text("Page 4"),
            ),
          ),
        ],
        onComplete: () {},
      ),
    );
  }
}
