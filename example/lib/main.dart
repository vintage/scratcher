import 'package:flutter/material.dart';

import 'scratch_box.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isOver = false;
  double progress = 0;

  Widget buildRow(IconData iconLeft, IconData iconRight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScratchBox(icon: iconLeft),
        ScratchBox(icon: Icons.stars),
        ScratchBox(icon: iconRight),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.green[500],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Scratcher',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green[100],
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              buildRow(Icons.android, Icons.lightbulb_outline),
              buildRow(Icons.audiotrack, Icons.monetization_on),
              buildRow(Icons.android, Icons.monetization_on),
            ],
          ),
        ),
      ),
    );
  }
}
