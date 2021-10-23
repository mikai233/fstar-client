import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fstar/model/course_data.dart';
import 'package:fstar/model/score_data.dart';
import 'package:fstar/model/sport_score_data.dart';
import 'package:fstar/utils/utils.dart';
import 'package:html/parser.dart';
import 'package:collection/collection.dart' show ListEquality;

abstract class Parser {}

//江苏科技大学本科生课程解析类
class DefaultCourseParser implements Parser {
  List<CourseData> _courseList = []; //课程
  String _remark; //备注
  String _studentName; //学生姓名
  String _studentNumber; //学号
  List<String> _semesters = []; //学期列表
  List<String> _weeks = []; //每学期周数
  int _colorIndex = 0; //课表颜色索引
  final _idColorMap = Map<String, Color>(); // key=>课程号 value=>颜色

  DefaultCourseParser();

//执行解析
  void action(String content) {
    final document = parse(content);
    _clear();
    //学期
    _semesters = document
        .getElementById('xnxq01id')
        .children
        .map((e) => e.text.trim())
        .toList();
    //学期周数
    _weeks = document
        .getElementById('zc')
        .children
        .map((e) => e.text.trim())
        .toList();
    //姓名 学号
    final info = document.getElementById('Top1_divLoginName').text ?? '';
    final regExp = RegExp(r'(.*)\((.*)\)');
    final match = regExp.firstMatch(info);
    _studentName = match.group(1) ?? '';
    _studentNumber = match.group(2) ?? '';
    //课表
    final trs = document.querySelectorAll('#kbtable tr');
    _remark = trs.last.text?.trim()?.replaceAll('\n', '') ?? '';
    for (int i = 1; i < trs.length - 1; ++i) {
      final contents = trs[i].querySelectorAll('td .kbcontent');
      contents.forEachIndexed((index, element) {
        final courses = _parseTable(
            innerHtml: element.innerHtml, row: i, column: index + 1);
        _courseList.addAll(courses);
      });
    }
    getSettingsData().unusedCourseColorIndex = _colorIndex;
  }

  List<String> get weeks => _weeks;

  List<String> get semesters => _semesters;

  String get studentNumber => _studentNumber;

  String get studentName => _studentName;

  String get remark => _remark;

  List<CourseData> get courseList => _courseList;

//解析课表
  List<CourseData> _parseTable(
      {@required String innerHtml, @required int row, @required int column}) {
    final eachContent = innerHtml.split('<br>---------------------<br>');
    final courses = <CourseData>[];
    int top = 0;
    eachContent.forEach((element) {
      final regex =
          RegExp(r'(.*?)<br>(.*?)<br><.*?>(.*?)</font>.*?">(.*?)\(周\)');
      final result = regex.firstMatch(element);
      if (result != null) {
        final id = result[1];
        final name = result[2];
        final teacher = result[3];
        final week = _parseRawWeek(result[4]);
        final roomRegExp = RegExp(r'<font title="教室">(.*?)</font>');
        final room = roomRegExp.firstMatch(element)?.group(1) ?? "";
        _idColorMap.putIfAbsent(id, () {
          final colors = getColorList();
          return colors[_colorIndex++ % colors.length];
        });
        final course = CourseData(
            id: id,
            name: name,
            classroom: room,
            week: week,
            row: row * 2 - 1,
            rowSpan: 2,
            column: column,
            teacher: teacher,
            defaultColor: _idColorMap[id],
            customColor: null,
            top: top++);
        courses.add(course);
      }
    });
    return courses;
  }

//解析 3,4-7,12 类型的周数
  List<int> _parseRawWeek(String rawWeek) {
    final eachPart = rawWeek.split(',');
    final result = <int>[];
    eachPart.forEach((element) {
      if (element.indexOf('-') != -1) {
        final beginEnd =
            element.split('-').map((e) => int.parse(e) ?? 0).toList();
        for (int i = beginEnd[0]; i < beginEnd[1] + 1; ++i) {
          result.add(i);
        }
      } else {
        result.add(int.parse(element));
      }
    });
    return result.toSet().toList();
  }

//执行action之前清除原有的数据
  void _clear() {
    _colorIndex = 0;
    _idColorMap.clear();
    _courseList.clear();
    _remark = '';
    _studentName = '';
    _weeks.clear();
    _semesters.clear();
  }
}

//江苏科技大学研究生课表解析类
class GraduateCourseParser extends DefaultCourseParser {
  @override
  void action(String content) {
    super._clear();
    var regex = RegExp(r'(.*?)\[(.*?)周\](.*?)\[(.*?)\]');
    List<CourseData> courses = [];
    (JsonDecoder().convert(parse(content).body.text)['rows'] as List<dynamic>)
        .forEach((courseInfo) {
      String mc = courseInfo['mc'];
      var row = int.parse(mc.substring(2));
      if (mc.contains('下午')) {
        row += 4;
      } else if (mc.contains('晚上')) {
        row += 8;
      }
      String z1 = courseInfo['z1'];
      String z2 = courseInfo['z2'];
      String z3 = courseInfo['z3'];
      String z4 = courseInfo['z4'];
      String z5 = courseInfo['z5'];
      String z6 = courseInfo['z6'];
      String z7 = courseInfo['z7'];
      var columns = [z1, z2, z3, z4, z5, z6, z7];
      for (int i = 0; i < columns.length; i++) {
        if (columns[i] == null) {
          continue;
        }
        var result = regex.firstMatch(columns[i]);
        if (result == null) {
          continue;
        }
        var name = result.group(1);
        var weeks = _parseRawWeek(result.group(2));
        var teacher = result.group(3);
        var room = result.group(4);
        _idColorMap.putIfAbsent(name, () {
          final colors = getColorList();
          return colors[_colorIndex++ % colors.length];
        });
        final c = CourseData(
            id: '',
            name: name,
            classroom: room,
            week: weeks,
            row: row,
            rowSpan: 1,
            column: i + 1,
            teacher: teacher,
            defaultColor: _idColorMap[name],
            customColor: null,
            top: 0);
        courses.add(c);
      }
    });
    _remark = '';
    _courseList = _mergeCourse(courses);
    getSettingsData().unusedCourseColorIndex = _colorIndex;
  }

  List<CourseData> _mergeCourse(List<CourseData> courses) {
    List<CourseData> mergedCourses = [];
    var temp = courses;
    var lq = ListEquality();
    while (temp.isNotEmpty) {
      var toMerge = temp.removeAt(0);
      var removeList = [];
      temp.forEach((c) {
        if (c.column == toMerge.column &&
            c.name == toMerge.name &&
            c.classroom == toMerge.classroom &&
            c.teacher == toMerge.teacher &&
            lq.equals(c.week, toMerge.week)) {
          if (c.row == toMerge.row - 1) {
            toMerge = toMerge.copyWith(
                row: toMerge.row - 1, rowSpan: toMerge.rowSpan + 1);
            removeList.add(c);
          }
          if (c.row == toMerge.row + toMerge.rowSpan) {
            toMerge = toMerge.copyWith(rowSpan: toMerge.rowSpan + 1);
            removeList.add(c);
          }
        }
      });
      removeList.forEach((element) {
        temp.remove(element);
      });
      mergedCourses.add(toMerge);
    }
    return mergedCourses;
  }
}

class DefaultScoreParser implements Parser {
  final List<ScoreData> scoreList = [];

  void _clear() {
    scoreList.clear();
  }

  void action(String content) {
    _clear();
    final scores = parse(content).querySelectorAll('#dataList tr');
    if (scores.length > 1) {
      scores.removeAt(0);
    }
    for (var score in scores) {
      final one = score.querySelectorAll("td");
      final oneScoreList = <String>[];
      for (final o in one) {
        oneScoreList.add(o.text);
      }
      if (oneScoreList.isEmpty) {
        continue;
      }
      scoreList.add(scoreDataHelper(oneScoreList));
    }
  }

  static ScoreData scoreDataHelper(List<String> scoreList) {
    return ScoreData(
      no: scoreList[0],
      semester: scoreList[1],
      scoreNo: scoreList[2],
      name: scoreList[3],
      score: scoreList[4],
      credit: scoreList[5],
      period: scoreList[6],
      evaluationMode: scoreList[7],
      courseProperty: scoreList[8],
      courseNature: scoreList[9],
      alternativeCourseNumber: scoreList[10],
      alternativeCourseName: scoreList[11],
      scoreFlag: scoreList[12],
    );
  }
}

class AlternativeScoreParser extends DefaultScoreParser {
  @override
  void action(String content) {
    _clear();
    final scores = parse(content).querySelectorAll('#dataList tr');
    if (scores.length > 1) {
      scores.removeAt(0);
    }
    for (final score in scores) {
      final one = score.querySelectorAll("td");
      if (one.isNotEmpty) {
        one.removeAt(0);
      }
      final oneScoreList = <String>[];
      for (final o in one) {
        oneScoreList.add(o.text);
      }
      if (oneScoreList.isEmpty) {
        continue;
      }
      scoreList.add(scoreDataHelper(oneScoreList));
    }
    scoreList.sort((a, b) {
      var semester1 = a.semester.split("-");
      var semester2 = b.semester.split("-");
      var sum1 = 0;
      var sum2 = 0;
      for (var value in semester1) {
        sum1 += int.parse(value);
      }
      for (var value1 in semester2) {
        sum2 += int.parse(value1);
      }
      if (sum1 < sum2) {
        return -1;
      } else if (sum1 == sum2) {
        return 0;
      } else {
        return 1;
      }
    });
  }

  static ScoreData scoreDataHelper(List<String> scoreList) {
    return ScoreData(
      no: scoreList[0],
      semester: scoreList[1],
      scoreNo: scoreList[2],
      name: scoreList[3],
      score: scoreList[4],
      credit: scoreList[5],
      period: "",
      evaluationMode: scoreList[6],
      courseProperty: scoreList[7],
      courseNature: "",
      alternativeCourseNumber: "",
      alternativeCourseName: "",
      scoreFlag: "",
    );
  }
}

class SportScoreParser implements Parser {
  final List<SportScoreData> _score = [];

  List<SportScoreData> get score => _score;

  void _clear() {
    _score.clear();
  }

  void action(String content) {
    _clear();
    final eachScores = parse(content)
        .querySelectorAll("#autonumber1")[1]
        .querySelectorAll("tr");
    eachScores.removeAt(0); //去除表头
    for (final score in eachScores) {
      final info = score.querySelectorAll("td");
      List<String> oneScore = [];
      for (int i = 0; i < info.length; ++i) {
        if (i != 7) {
          oneScore.add(info[i].text.trim().replaceAll('\u3000', ''));
        } else {
          final remark = info[i].querySelector("input").attributes["onclick"];
          oneScore.add(remark);
        }
      }
      String detail = "";
      var detailInfo = oneScore[7].split("\\n");
      detailInfo[0] = detailInfo[0].substring(10);
      detailInfo.removeLast();
      for (var info in detailInfo) {
        detail += info.trim() + '\n';
      }
      Map<String, String> scoreMap = {
        "semester": oneScore[0],
        "special": oneScore[1],
        "time": oneScore[2],
        "teacher": oneScore[3],
        "name": oneScore[4],
        "score": oneScore[5],
        "evaluate": oneScore[6],
        "detail": detail,
        "remark": oneScore[8],
      };
      _score.add(SportScoreData.fromMap(scoreMap));
    }
  }
}

//TODO
class GraduateScoreParser implements DefaultScoreParser {
  @override
  void _clear() {}

  @override
  void action(String content) {
    final tbody = parse(content).querySelectorAll('.GridBackColor');
    final degree = tbody.first;
    final elective = tbody.last;
    final degreeTrs = degree.querySelectorAll('tr');
    final degreeScore = [];
    final electiveScore = [];
    final otherInfo = Map<String, String>();
    //remove header
    degreeTrs.removeAt(0);
    degreeTrs.forEach((element) {
      final oneScoreInfo =
          element.querySelectorAll('td').map((e) => e.text).toList();
      degreeScore.add(oneScoreInfo);
    });
    final electiveTrs = elective.querySelectorAll('tr');
    //remove header
    electiveTrs.removeAt(0);
    electiveTrs.forEach((element) {
      final oneScoreInfo =
          element.querySelectorAll('td').map((e) => e.text).toList();
      electiveScore.add(oneScoreInfo);
    });
    final box = parse(content)
        .querySelectorAll('.box')
        .last
        .querySelectorAll('tbody')
        .first
        .querySelectorAll('td');
    debugPrint(box.length.toString());
  }

  @override
  final List<ScoreData> scoreList = null;
}

class SportClubParser extends Parser {
  String remark = '';
  List<String> item = [];

  void action(String content) {
    final trs = parse(content).querySelectorAll('table tr');
    trs.removeAt(0);
    remark = trs.removeLast().text;
    trs.forEach((element) {
      final regex =
          RegExp('<td>1</td><td>(.*?)</td><td>(.*?)</td><td>(.*?)</td>');
      if (regex.hasMatch(element.innerHtml)) {
        var matchResult = regex.firstMatch(element.innerHtml);
        var date = matchResult.group(1).replaceAll(' ', '');
        var time = matchResult.group(2).trim();
        var remark = matchResult.group(3).trim();
        item.add('$date $time $remark');
      }
    });
  }
}
