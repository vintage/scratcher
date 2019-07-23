import 'package:flutter/material.dart';

import 'scratch_box.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  double validScratches = 0;
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400))
          ..addStatusListener((listener) {
            if (listener == AnimationStatus.completed) {
              _animationController.reverse();
            }
          });
    _animation = Tween(begin: 1.0, end: 1.25).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.elasticIn));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget buildRow(IconData iconLeft, IconData iconRight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScratchBox(icon: iconLeft),
        ScratchBox(
          icon: Icons.stars,
          animation: _animation,
          onScratch: () {
            setState(() {
              validScratches++;
              if (validScratches == 3) {
                _animationController.forward();
              }
            });
          },
        ),
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
