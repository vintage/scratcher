import 'package:flutter_web/material.dart';

import 'package:scratcher/scratcher.dart';

class BasicScreen extends StatefulWidget {
  @override
  _BasicScreenState createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scratcher(
          brushSize: 30,
          threshold: 30,
          revealDuration: Duration(milliseconds: 800),
          color: Colors.red,
          onChange: (value) {
            setState(() {
              progress = value;
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
                    'Scratch the screen to win',
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
