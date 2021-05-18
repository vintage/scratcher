import 'package:flutter/material.dart';

import 'scratch_box.dart';

const _googleIcon = 'assets/google.png';
const _dartIcon = 'assets/dart.png';
const _flutterIcon = 'assets/flutter.png';

class AdvancedScreen extends StatefulWidget {
  @override
  _AdvancedScreenState createState() => _AdvancedScreenState();
}

class _AdvancedScreenState extends State<AdvancedScreen>
    with SingleTickerProviderStateMixin {
  double validScratches = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addStatusListener(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Scratcher',
                  style: TextStyle(
                    fontFamily: 'The unseen',
                    color: Colors.blueAccent,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
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
            buildRow(_googleIcon, _flutterIcon, _googleIcon),
            buildRow(_dartIcon, _flutterIcon, _googleIcon),
            buildRow(_dartIcon, _flutterIcon, _dartIcon),
          ],
        ),
      ),
    );
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
}
