import 'package:flutter/material.dart';

class SportScoreData {
  final String _semester;
  final String _special;
  final String _time;
  final String _teacher;
  final String _name;
  final String _score;
  final String _evaluate;
  final String _detail;
  final String _remark;

  String get semester => _semester;

  String get special => _special;

  String get time => _time;

  String get teacher => _teacher;

  String get name => _name;

  String get score => _score;

  String get evaluate => _evaluate;

  String get detail => _detail;

  String get remark => _remark;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const SportScoreData({
    @required String semester,
    @required String special,
    @required String time,
    @required String teacher,
    @required String name,
    @required String score,
    @required String evaluate,
    @required String detail,
    @required String remark,
  })  : _semester = semester,
        _special = special,
        _time = time,
        _teacher = teacher,
        _name = name,
        _score = score,
        _evaluate = evaluate,
        _detail = detail,
        _remark = remark;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SportScoreData &&
          runtimeType == other.runtimeType &&
          _semester == other._semester &&
          _special == other._special &&
          _time == other._time &&
          _teacher == other._teacher &&
          _name == other._name &&
          _score == other._score &&
          _evaluate == other._evaluate &&
          _detail == other._detail &&
          _remark == other._remark);

  @override
  int get hashCode =>
      _semester.hashCode ^
      _special.hashCode ^
      _time.hashCode ^
      _teacher.hashCode ^
      _name.hashCode ^
      _score.hashCode ^
      _evaluate.hashCode ^
      _detail.hashCode ^
      _remark.hashCode;

  @override
  String toString() {
    return 'SportScoreData{' +
        ' 学期: $_semester,' +
        ' 专项: $_special,' +
        ' 上课时间: $_time,' +
        ' 老师: $_teacher,' +
        ' 课程名称: $_name,' +
        ' 成绩: $_score,' +
        ' 评价: $_evaluate,' +
        ' 详情: $_detail,' +
        ' 备注: $_remark,' +
        '}';
  }

  SportScoreData copyWith({
    String semester,
    String special,
    String time,
    String teacher,
    String name,
    String score,
    String evaluate,
    String detail,
    String remark,
  }) {
    return new SportScoreData(
      semester: semester ?? this._semester,
      special: special ?? this._special,
      time: time ?? this._time,
      teacher: teacher ?? this._teacher,
      name: name ?? this._name,
      score: score ?? this._score,
      evaluate: evaluate ?? this._evaluate,
      detail: detail ?? this._detail,
      remark: remark ?? this._remark,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'semester': this._semester,
      'special': this._special,
      'time': this._time,
      'teacher': this._teacher,
      'name': this._name,
      'score': this._score,
      'evaluate': this._evaluate,
      'detail': this._detail,
      'remark': this._remark,
    };
  }

  factory SportScoreData.fromMap(Map<String, dynamic> map) {
    return new SportScoreData(
      semester: map['semester'] as String,
      special: map['special'] as String,
      time: map['time'] as String,
      teacher: map['teacher'] as String,
      name: map['name'] as String,
      score: map['score'] as String,
      evaluate: map['evaluate'] as String,
      detail: map['detail'] as String,
      remark: map['remark'] as String,
    );
  }

//</editor-fold>

}
