import 'package:fstar/model/score_data.dart';
import 'package:fstar/utils/utils.dart';

class RankData {
  RankData(this._studentNumber, this.scoreData);

  final String _studentNumber;
  final List<ScoreData> scoreData;

  get studentNumber => _studentNumber;

//计算某学期或者某学年的GPA
  String getGPA(String semester, predicate) {
    return calculateGPA2(getScore(semester), predicate);
  }

  String getTotalGPA(predicate) {
    return calculateGPA2(scoreData, predicate);
  }

//获取某学期或者某学年的课程
  List<ScoreData> getScore(String semester) {
    var len = semester.split('-').length;
    return scoreData.where((value) {
      if (len == 2) {
        return value.semester.contains(semester);
      } else {
        return value.semester == semester;
      }
    }).toList();
  }

//获取全部的学期
  List<String> getSemesters() {
    var semesters = Set<String>();
    scoreData.forEach((element) {
      semesters.add(element.semester);
    });
    var set = Set<String>();
    semesters.forEach((element) {
      set.add(element.substring(0, element.length - 2));
    });
    semesters.addAll(set);
    return semesters.toList();
  }
}
