import 'package:flutter/material.dart';

import 'package:scratcher/scratcher.dart';

class BasicScreen extends StatefulWidget {
  @override
  _BasicScreenState createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  double progress = 0;
  bool isOver = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scratcher(
          brushSize: 30,
          threshold: 50,
          color: Colors.red,
          onChange: (value) {
            setState(() {
              progress = value;
            });
          },
          onThreshold: () {
            setState(() {
              isOver = true;
            });
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    isOver
                        ? 'Congratulations, you won!'
                        : 'Scratch the screen!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Colors.amber),
                  ),
                ],
              ),
            ),
            color: Colors.grey,
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Text(
            '${progress.round().toString()}%',
          ),
        )
      ],
    );
  }
}
