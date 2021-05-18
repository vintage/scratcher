import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';

class ScratchBox extends StatefulWidget {
  ScratchBox({
    required this.image,
    this.onScratch,
    this.animation,
  });

  final String image;
  final VoidCallback? onScratch;
  final Animation<double>? animation;

  @override
  _ScratchBoxState createState() => _ScratchBoxState();
}

class _ScratchBoxState extends State<ScratchBox> {
  bool isScratched = false;
  double opacity = 0.5;

  @override
  Widget build(BuildContext context) {
    var icon = AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 750),
      child: Image.asset(
        widget.image,
        width: 70,
        height: 70,
        fit: BoxFit.contain,
      ),
    );

    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(10),
      child: Scratcher(
        accuracy: ScratchAccuracy.low,
        color: Colors.blueGrey,
        image: Image.asset('assets/scratch.png'),
        brushSize: 15,
        threshold: 60,
        onThreshold: () {
          setState(() {
            opacity = 1;
            isScratched = true;
          });
          widget.onScratch?.call();
        },
        child: Container(
          child: widget.animation == null
              ? icon
              : ScaleTransition(
                  scale: widget.animation!,
                  child: icon,
                ),
        ),
      ),
    );
  }
}
