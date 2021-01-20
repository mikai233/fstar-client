import 'package:flutter/material.dart';
import 'package:fstar/utils/utils.dart';

class WeekIndexData with ChangeNotifier {
  int _weekIndex = getCurrentWeek();

  int get index => _weekIndex;

  set index(int value) {
    _weekIndex = value;
    notifyListeners();
  }
}
