import 'package:flutter/material.dart';

import 'scratch_box.dart';

void main() => runApp(MyApp());

const googleIcon = 'assets/google.png';
const dartIcon = 'assets/dart.png';
const flutterIcon = 'assets/flutter.png';

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
        AnimationController(vsync: this, duration: Duration(milliseconds: 1200))
          ..addStatusListener(
            (listener) {
              if (listener == AnimationStatus.completed) {
                _animationController.reverse();
              }
            },
          );
    _animation = Tween(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticIn,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget buildRow(String left, String center, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScratchBox(image: left),
        ScratchBox(
          image: center,
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
        ScratchBox(image: right),
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
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Scratcher',
                    style: TextStyle(
                      fontFamily: 'The unseen',
                      color: Colors.blueAccent,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'scratch to win!',
                    style: TextStyle(
                      fontFamily: 'The unseen',
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: 1,
                    width: 300,
                    color: Colors.black12,
                  )
                ],
              ),
              buildRow(googleIcon, flutterIcon, googleIcon),
              buildRow(
                dartIcon,
                flutterIcon,
                googleIcon,
              ),
              buildRow(dartIcon, flutterIcon, dartIcon),
            ],
          ),
        ),
      ),
    );
  }
}
