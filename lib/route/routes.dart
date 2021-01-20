import 'package:fluro/fluro.dart';
import 'package:fstar/route/route_handlers.dart';

class Routes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String timeTable = '/time_table';
  static const String tool = '/tool';
  static const String score = '/score';
  static const String scoreRanking = score + '/ranking';
  static const String sportScore = '/sport_score';
  static const String privacyPolicy = '/privacy_policy';

  static void configureRoutes(FluroRouter router) {
    router
      ..define(home, handler: homeHandler)
      ..define(timeTable, handler: timeTableHandler)
      ..define(tool, handler: toolHandler)
      ..define(settings, handler: settingsHandler)
      ..notFoundHandler = errorHandler;
  }
}
