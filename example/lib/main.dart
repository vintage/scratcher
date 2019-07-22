import 'package:flutter/material.dart';

import 'package:scratcher/scratcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isOver = false;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Stack(
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
                height: 700,
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
                '${progress.toString()}%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
