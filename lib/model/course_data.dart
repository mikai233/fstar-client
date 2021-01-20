import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'course_data.g.dart';

@HiveType(typeId: 2)
class CourseData extends HiveObject {
  @HiveField(0)
  final String id; //课程号
  @HiveField(1)
  final String name; //课程名称
  @HiveField(2)
  final String classroom; //教室
  @HiveField(3)
  final List<int> week; //周数
  @HiveField(4)
  final int row; //第几节
  @HiveField(5)
  final int rowSpan; //跨行
  @HiveField(6)
  final int column; //星期几
  @HiveField(7)
  final String teacher; //老师
  @HiveField(8)
  final Color defaultColor; //课表颜色
  @HiveField(9)
  final Color customColor; //自定义颜色
  @HiveField(10)
  final int top; //课表层叠优先级

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  CourseData({
    @required this.id,
    @required this.name,
    @required this.classroom,
    @required this.week,
    @required this.row,
    @required this.rowSpan,
    @required this.column,
    @required this.teacher,
    @required this.defaultColor,
    @required this.customColor,
    @required this.top,
  });

  CourseData copyWith({
    String id,
    String name,
    String classroom,
    List<int> week,
    int row,
    int rowSpan,
    int column,
    String teacher,
    Color defaultColor,
    Color customColor,
    int top,
  }) {
    if ((id == null || identical(id, this.id)) &&
        (name == null || identical(name, this.name)) &&
        (classroom == null || identical(classroom, this.classroom)) &&
        (week == null || identical(week, this.week)) &&
        (row == null || identical(row, this.row)) &&
        (rowSpan == null || identical(rowSpan, this.rowSpan)) &&
        (column == null || identical(column, this.column)) &&
        (teacher == null || identical(teacher, this.teacher)) &&
        (defaultColor == null || identical(defaultColor, this.defaultColor)) &&
        (customColor == null || identical(customColor, this.customColor)) &&
        (top == null || identical(top, this.top))) {
      return this;
    }

    return new CourseData(
      id: id ?? this.id,
      name: name ?? this.name,
      classroom: classroom ?? this.classroom,
      week: week ?? this.week,
      row: row ?? this.row,
      rowSpan: rowSpan ?? this.rowSpan,
      column: column ?? this.column,
      teacher: teacher ?? this.teacher,
      defaultColor: defaultColor ?? this.defaultColor,
      customColor: customColor ?? this.customColor,
      top: top ?? this.top,
    );
  }

  @override
  String toString() {
    return 'CourseData{id: $id, name: $name, classroom: $classroom, week: $week, row: $row, rowSpan: $rowSpan, column: $column, teacher: $teacher, defaultColor: $defaultColor, customColor: $customColor, top: $top}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          classroom == other.classroom &&
          week == other.week &&
          row == other.row &&
          rowSpan == other.rowSpan &&
          column == other.column &&
          teacher == other.teacher &&
          defaultColor == other.defaultColor &&
          customColor == other.customColor &&
          top == other.top);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      classroom.hashCode ^
      week.hashCode ^
      row.hashCode ^
      rowSpan.hashCode ^
      column.hashCode ^
      teacher.hashCode ^
      defaultColor.hashCode ^
      customColor.hashCode ^
      top.hashCode;

  factory CourseData.fromMap(Map<String, dynamic> map) {
    return new CourseData(
      id: map['id'] as String,
      name: map['name'] as String,
      classroom: map['classroom'] as String,
      week: map['week'] as List<int>,
      row: map['row'] as int,
      rowSpan: map['rowSpan'] as int,
      column: map['column'] as int,
      teacher: map['teacher'] as String,
      defaultColor: map['defaultColor'] as Color,
      customColor: map['customColor'] as Color,
      top: map['top'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': this.id,
      'name': this.name,
      'classroom': this.classroom,
      'week': this.week,
      'row': this.row,
      'rowSpan': this.rowSpan,
      'column': this.column,
      'teacher': this.teacher,
      'defaultColor': this.defaultColor,
      'customColor': this.customColor,
      'top': this.top,
    } as Map<String, dynamic>;
  }

//</editor-fold>

}
