import 'package:flutter/material.dart';
import 'package:fstar/model/box_name.dart';
import 'package:fstar/model/fstar_mode_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';

class TimeArrayData with ChangeNotifier {
  List<DateTime> _array;
  final _settings = getBoxData<SettingsData>(BoxName.settingsBox);

  TimeArrayData() {
    _array = generate(_settings.beginTime, _settings.semesterWeek);
  }

  List<DateTime> get array {
    if (_array.length < _settings.semesterWeek * 7) {
      _array = _array = generate(_settings.beginTime, _settings.semesterWeek);
      Log.logger.i('重新生成时间序列');
    }
    return _array;
  }

  set array(List<DateTime> value) {
    _array = value;
    notifyListeners();
  }
}
