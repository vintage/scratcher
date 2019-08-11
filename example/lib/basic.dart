import 'package:flutter/material.dart';

import 'package:scratcher/scratcher.dart';

class BasicScreen extends StatefulWidget {
  @override
  _BasicScreenState createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  double progress = 0;
  final key = GlobalKey<ScratcherState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scratcher(
          key: key,
          brushSize: 30,
          threshold: 30,
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
          top: 10,
          left: 10,
          child: RaisedButton(
            child: const Text('Reset'),
            onPressed: () {
              key.currentState.reset(duration: Duration(milliseconds: 2000));
            },
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: RaisedButton(
            child: const Text('Reveal'),
            onPressed: () {
              key.currentState.reveal(duration: Duration(milliseconds: 2000));
            },
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
