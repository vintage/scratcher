import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';

class ScratchBox extends StatefulWidget {
  ScratchBox({
    this.icon,
    this.onScratch,
    this.animation,
  });

  final IconData icon;
  final VoidCallback onScratch;
  final Animation<double> animation;

  @override
  _ScratchBoxState createState() => _ScratchBoxState();
}

class _ScratchBoxState extends State<ScratchBox>
    with SingleTickerProviderStateMixin {
  bool isScratched = false;
  AnimationController _animationController;
  Animation<Color> _colorTween;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _colorTween = ColorTween(begin: Colors.blueGrey, end: Colors.blue[700])
        .animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(10),
      child: Scratcher(
        accuracy: ScratchAccuracy.low,
        color: Colors.blueGrey,
        brushSize: 15,
        threshold: 60,
        onThreshold: () {
          _animationController.forward();
          setState(() {
            isScratched = true;
          });
          widget.onScratch?.call();
        },
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              var icon = Icon(
                widget.icon,
                color: _colorTween.value,
                size: 70,
              );

              if (widget.animation == null) {
                return icon;
              }

              return ScaleTransition(
                scale: widget.animation,
                child: icon,
              );
            },
          ),
        ),
      ),
    );
  }
}
