import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'theme_color_data.g.dart';

@HiveType(typeId: 4)
class ThemeColorData extends HiveObject with ChangeNotifier {
  @HiveField(0)
  int _index = Colors.primaries.indexOf(Colors.blue);

  int get index => _index;

  set index(int value) {
    _index = value;
    notifyListeners();
  }
}
