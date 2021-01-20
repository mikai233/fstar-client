import 'package:flutter/material.dart';
import 'package:fstar/utils/utils.dart';

class DateTodayData extends ChangeNotifier {
  DateTime _now = DateTime.now();

  DateTime get now => _now;

  void today() {
    if (!sameDay(_now, DateTime.now())) {
      _now = DateTime.now();
      notifyListeners();
    }
  }
}
