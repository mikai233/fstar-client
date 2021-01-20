import 'package:flutter/material.dart';

class ChooseWeekHeaderStatus extends ChangeNotifier {
  bool _show = false;

  bool get show => _show;

  set show(bool value) {
    _show = value;
    notifyListeners();
  }
}
