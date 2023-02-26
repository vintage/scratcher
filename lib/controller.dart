import 'package:flutter/widgets.dart';
import 'package:scratcher/utils.dart';

class ScratcherController extends ChangeNotifier {
  List<ScratchPoint?> points = [];
  bool? revealed;
  Duration? duration;

  void clearPoints({Duration? duration}) {
    points = [];
    revealed = false;
    this.duration = duration;
    notifyListeners();
    revealed = false;
    this.duration = null;
  }

  void reveal({Duration? duration}) {
    revealed = true;
    this.duration = duration;
    notifyListeners();
    revealed = false;
    this.duration = null;
  }

}