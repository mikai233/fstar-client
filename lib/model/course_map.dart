import 'package:flutter/material.dart';
import 'package:fstar/model/course_data.dart';
import 'package:fstar/utils/utils.dart';
import 'package:hive/hive.dart';

part 'course_map.g.dart';

@HiveType(typeId: 10)
class CourseMap extends HiveObject with ChangeNotifier {
  @HiveField(0)
  Map<int, List<CourseData>> _dataMap = generateEmptyCourseMap();
  @HiveField(1)
  String _remark = '';

  String get remark => _remark;

  set remark(String value) {
    _remark = value;
    notifyListeners();
  }

  Map<int, List<CourseData>> get dataMap => _dataMap;

  set dataMap(Map<int, List<CourseData>> value) {
    _dataMap = value;
    notifyListeners();
  }

  void addCourseByMap(Map<int, List<CourseData>> value) {
    value.forEach((key, value) {
      _dataMap[key].addAll(value);
    });
    notifyListeners();
  }

  void addCourseByList(List<CourseData> value, [bool clear = false]) {
    if (clear) {
      _dataMap = generateEmptyCourseMap();
    }
    value.forEach((element) {
      _dataMap[element.column] = _dataMap[element.column].toList()
        ..add(element);
    });
    notifyListeners();
  }

  void removeCourse(CourseData value) {
    _dataMap[value.column].remove(value);
    notifyListeners();
  }

  void editCourse(
      {@required CourseData newCourse, @required CourseData oldCourse}) {
    var oldColumn = oldCourse.column;
    var newColumn = newCourse.column;
    _dataMap[oldColumn].remove(oldCourse);
    _dataMap[newColumn].add(newCourse);
    notifyListeners();
  }

  void clearCourse() {
    _dataMap = generateEmptyCourseMap();
    notifyListeners();
  }
}
