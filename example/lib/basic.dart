import 'package:flutter/material.dart';

import 'package:scratcher/scratcher.dart';

class BasicScreen extends StatefulWidget {
  @override
  _BasicScreenState createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  double brushSize = 30;
  double progress = 0;
  bool thresholdReached = false;
  final key = GlobalKey<ScratcherState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                child: const Text('Reset'),
                onPressed: () {
                  key.currentState.reset(
                    duration: const Duration(milliseconds: 2000),
                  );
                  setState(() => thresholdReached = false);
                },
              ),
              Column(
                children: [
                  Text('Brush size (${brushSize.round()})'),
                  Slider(
                    value: brushSize,
                    onChanged: (v) => setState(() => brushSize = v),
                    min: 5,
                    max: 100,
                  ),
                ],
              ),
              RaisedButton(
                child: const Text('Reveal'),
                onPressed: () {
                  key.currentState.reveal(
                    duration: const Duration(milliseconds: 2000),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                Scratcher(
                  key: key,
                  brushSize: brushSize,
                  threshold: 30,
                  color: Colors.red,
                  onThreshold: () => setState(() => thresholdReached = true),
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
                          const Text(
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
                ),
                Positioned(
                  bottom: 30,
                  right: 10,
                  child: Text(
                    'Threshold reached: $thresholdReached',
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
