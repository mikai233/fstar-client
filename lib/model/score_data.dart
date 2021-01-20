import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'score_data.g.dart';

@HiveType(typeId: 3)
class ScoreData extends HiveObject {
  @HiveField(0)
  final String no; //序号
  @HiveField(1)
  final String semester; //开课学期
  @HiveField(2)
  final String scoreNo; //课程号
  @HiveField(3)
  final String name; //课程名称
  @HiveField(4)
  final String score; //成绩
  @HiveField(5)
  final String credit; //学分
  @HiveField(6)
  final String period; //总学时
  @HiveField(7)
  final String evaluationMode; //考核方式
  @HiveField(8)
  final String courseProperty; //课程属性
  @HiveField(9)
  final String courseNature; //课程性质
  @HiveField(10)
  final String alternativeCourseNumber; //替代课程号
  @HiveField(11)
  final String alternativeCourseName; //替代课程名称
  @HiveField(12)
  final String scoreFlag; //成绩标志

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  ScoreData({
    @required this.no,
    @required this.semester,
    @required this.scoreNo,
    @required this.name,
    @required this.score,
    @required this.credit,
    @required this.period,
    @required this.evaluationMode,
    @required this.courseProperty,
    @required this.courseNature,
    @required this.alternativeCourseNumber,
    @required this.alternativeCourseName,
    @required this.scoreFlag,
  });

  ScoreData copyWith({
    String no,
    String semester,
    String scoreNo,
    String name,
    String score,
    String credit,
    String period,
    String evaluationMode,
    String courseProperty,
    String courseNature,
    String alternativeCourseNumber,
    String alternativeCourseName,
    String scoreFlag,
  }) {
    if ((no == null || identical(no, this.no)) &&
        (semester == null || identical(semester, this.semester)) &&
        (scoreNo == null || identical(scoreNo, this.scoreNo)) &&
        (name == null || identical(name, this.name)) &&
        (score == null || identical(score, this.score)) &&
        (credit == null || identical(credit, this.credit)) &&
        (period == null || identical(period, this.period)) &&
        (evaluationMode == null ||
            identical(evaluationMode, this.evaluationMode)) &&
        (courseProperty == null ||
            identical(courseProperty, this.courseProperty)) &&
        (courseNature == null || identical(courseNature, this.courseNature)) &&
        (alternativeCourseNumber == null ||
            identical(alternativeCourseNumber, this.alternativeCourseNumber)) &&
        (alternativeCourseName == null ||
            identical(alternativeCourseName, this.alternativeCourseName)) &&
        (scoreFlag == null || identical(scoreFlag, this.scoreFlag))) {
      return this;
    }

    return new ScoreData(
      no: no ?? this.no,
      semester: semester ?? this.semester,
      scoreNo: scoreNo ?? this.scoreNo,
      name: name ?? this.name,
      score: score ?? this.score,
      credit: credit ?? this.credit,
      period: period ?? this.period,
      evaluationMode: evaluationMode ?? this.evaluationMode,
      courseProperty: courseProperty ?? this.courseProperty,
      courseNature: courseNature ?? this.courseNature,
      alternativeCourseNumber:
          alternativeCourseNumber ?? this.alternativeCourseNumber,
      alternativeCourseName:
          alternativeCourseName ?? this.alternativeCourseName,
      scoreFlag: scoreFlag ?? this.scoreFlag,
    );
  }

  @override
  String toString() {
    return 'ScoreData{no: $no, semester: $semester, scoreNo: $scoreNo, name: $name, score: $score, credit: $credit, period: $period, evaluationMode: $evaluationMode, courseProperty: $courseProperty, courseNature: $courseNature, alternativeCourseNumber: $alternativeCourseNumber, alternativeCourseName: $alternativeCourseName, scoreFlag: $scoreFlag}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreData &&
          runtimeType == other.runtimeType &&
          no == other.no &&
          semester == other.semester &&
          scoreNo == other.scoreNo &&
          name == other.name &&
          score == other.score &&
          credit == other.credit &&
          period == other.period &&
          evaluationMode == other.evaluationMode &&
          courseProperty == other.courseProperty &&
          courseNature == other.courseNature &&
          alternativeCourseNumber == other.alternativeCourseNumber &&
          alternativeCourseName == other.alternativeCourseName &&
          scoreFlag == other.scoreFlag);

  @override
  int get hashCode =>
      no.hashCode ^
      semester.hashCode ^
      scoreNo.hashCode ^
      name.hashCode ^
      score.hashCode ^
      credit.hashCode ^
      period.hashCode ^
      evaluationMode.hashCode ^
      courseProperty.hashCode ^
      courseNature.hashCode ^
      alternativeCourseNumber.hashCode ^
      alternativeCourseName.hashCode ^
      scoreFlag.hashCode;

  factory ScoreData.fromMap(Map<String, dynamic> map) {
    return new ScoreData(
      no: map['no'] as String,
      semester: map['semester'] as String,
      scoreNo: map['scoreNo'] as String,
      name: map['name'] as String,
      score: map['score'] as String,
      credit: map['credit'] as String,
      period: map['period'] as String,
      evaluationMode: map['evaluationMode'] as String,
      courseProperty: map['courseProperty'] as String,
      courseNature: map['courseNature'] as String,
      alternativeCourseNumber: map['alternativeCourseNumber'] as String,
      alternativeCourseName: map['alternativeCourseName'] as String,
      scoreFlag: map['scoreFlag'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'no': this.no,
      'semester': this.semester,
      'scoreNo': this.scoreNo,
      'name': this.name,
      'score': this.score,
      'credit': this.credit,
      'period': this.period,
      'evaluationMode': this.evaluationMode,
      'courseProperty': this.courseProperty,
      'courseNature': this.courseNature,
      'alternativeCourseNumber': this.alternativeCourseNumber,
      'alternativeCourseName': this.alternativeCourseName,
      'scoreFlag': this.scoreFlag,
    } as Map<String, dynamic>;
  }

//</editor-fold>

}
