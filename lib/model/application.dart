import 'package:fstar/model/course_data.dart';
import 'package:fstar/model/score_data.dart';
import 'package:fstar/utils/parser.dart';
import 'package:fstar/utils/requester.dart';

class Application {
  static DefaultCourseParser courseParser;
  static DefaultScoreParser scoreParser;
  static DefaultCourseRequester courseRequester;
  static DefaultScoreRequester scoreRequester;

  static Future<List<ScoreData>> getScore() async {
    final content = await scoreRequester.action();
    scoreParser.action(content);
    return scoreParser.scoreList;
  }

  static Future<List<CourseData>> getCourse() async {
    final content = await courseRequester.action();
    courseParser.action(content);
    return courseParser.courseList;
  }
}
