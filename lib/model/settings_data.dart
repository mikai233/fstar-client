import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fstar/model/fstar_mode_enum.dart';
import 'package:fstar/model/identity_enum.dart';
import 'package:fstar/model/score_display_mode_enum.dart';
import 'package:fstar/model/score_query_mode_enum.dart';
import 'package:fstar/model/system_mode_enum.dart';
import 'package:fstar/model/table_mode_enum.dart';
import 'package:fstar/utils/utils.dart';
import 'package:hive/hive.dart';

part 'settings_data.g.dart';

@HiveType(typeId: 1)
class SettingsData extends HiveObject with ChangeNotifier {
  SettingsData() {
    _initSelectionNumber = _timeTable.length;
  }

  @HiveField(0)
  bool _onlyShowThisWeek = true; //只显示本周课程
  @HiveField(1)
  bool _showCourseBackground = true; //课表背景
  @HiveField(2)
  String _courseBackgroundPath; //课表背景图片路径
  @HiveField(3)
  bool _showScoreBackground = true; //成绩背景
  @HiveField(4)
  String _scoreBackgroundPath; //成绩背景图片路径
  @HiveField(5)
  bool _showToolBackground = true; //工具背景
  @HiveField(6)
  String _toolBackgroundPath; //工具背景图片路径
  @HiveField(7)
  bool _reverseScore = true; //最新成绩靠前
  @HiveField(8)
  bool _autoCheckUpdate = true; //自动检查更新
  @HiveField(9)
  bool _tableScrollable = true; //课表可滑动
  @HiveField(10)
  List<String> _semesterList = []; //学期列表
  @HiveField(11)
  String _currentSemester = (DateTime.now().month >= 8
      ? "${DateTime.now().year}-${DateTime.now().year + 1}-1"
      : "${DateTime.now().year - 1}-${DateTime.now().year}-2"); //当前学期
  @HiveField(12)
  bool _refreshTablePerDay = false; //每天更新一次课表
  @HiveField(13)
  int _semesterWeek = 25; //学期周数
  List<Color> _courseColor; //课表颜色列表 未使用
  @HiveField(14)
  String _avatarPath; //头像
  @HiveField(15)
  DateTime _lastRefreshAt; //课表上次刷新时间
  @HiveField(16)
  ScoreDisplayMode _scoreDisplayMode = ScoreDisplayMode.ALL; //成绩显示方式
  @HiveField(17)
  bool _saveScoreCloud = false; //成绩云端保存
  @HiveField(18)
  SystemMode _systemMode = SystemMode.JUST; //系统访问模式
  @HiveField(19)
  String _campus; //校区
  @HiveField(20)
  List<String> _timeTable = [
    '8:30 9:15',
    '9:20 10:05',
    '10:25 11:10',
    '11:15 12:00',
    '13:30 14:15',
    '14:20 15:05',
    '15:25 16:10',
    '16:15 17:00',
    '18:30 19:15',
    '19:20 20:05'
  ]; //作息时间表
  @HiveField(21)
  double _initHeight = 70.0; //格子高度
  @HiveField(22)
  int _initSelectionNumber; //小节数
  @HiveField(23)
  bool _showSaturday = true; //开启周六
  @HiveField(24)
  bool _showSunday = true; //开启周日
  @HiveField(25)
  double _courseCircular = 5.0; //课表圆角
  @HiveField(26)
  int _appWidgetOpacity = 200; //微件透明度
  @HiveField(27)
  double _courseMargin = 1.5; //课表Margin
  @HiveField(28)
  double _coursePadding = 1.5; //课表Padding
  @HiveField(29)
  double _courseFontSize = 12.0; //课表字体大小
  @HiveField(30)
  FStarMode _fStarMode = FStarMode.ThirdParty; //课表模式
  @HiveField(31)
  int _unusedCourseColorIndex = 0; //默认课表颜色第一个没有被使用的索引
  @HiveField(32)
  Color _boxColor = Color.fromRGBO(168, 231, 255, 0.4); //格子颜色
  @HiveField(33)
  Color _tableBackgroundColor = Colors.white; //背景颜色
  @HiveField(34)
  bool _shadow = true; //课表卡片阴影效果
  @HiveField(35)
  IdentityType _identityType = IdentityType.undergraduate; //用户身份
  @HiveField(36)
  TableMode _tableMode = TableMode.A; //课表风格
  @HiveField(37)
  DateTime _beginTime = (DateTime.now().month >= 8
      ? reviseTime(DateTime(DateTime.now().year, 9, 1))
      : reviseTime(DateTime(DateTime.now().year, 2, 17))); //学期开始时间
  @HiveField(38)
  ScoreQueryMode _scoreQueryMode = ScoreQueryMode.DEFAULT; //成绩查询方式
  @HiveField(39)
  String _scoreQuerySemester = ''; //成绩查询学期
  @HiveField(40)
  bool _isNewUser = true;
  @HiveField(41)
  DateTime _dayFlag; //更新消息一天只显示一次

  //vpn2跳转url，不需要更新状态
  @HiveField(42)
  String serviceHallLoginUrl =
      'https://client.v.just.edu.cn/http/webvpndfaddd2f321275de563c2a6cf21be58aacc9653cdb86077d69472aa37e64e57c/cas/login?service=https://client.v.just.edu.cn/enlink/api/client/auth/cas';
  @HiveField(43)
  String serviceHomeUrl =
      'https://client.v.just.edu.cn/http/webvpn764a2e4853ae5e537560ba711c0f46bd/_s2/students_sy/main.psp';
  @HiveField(44)
  String jwHomeUrl =
      'https://client.v.just.edu.cn/http/webvpneb26120c0b61d26f61ce45ea5ef07bf864a455884ca2133c138748630669de2c/jsxsd/framework/xsMain.jsp';
  @HiveField(45)
  String jwScoreUrl =
      'https://client.v.just.edu.cn/http/webvpneb26120c0b61d26f61ce45ea5ef07bf864a455884ca2133c138748630669de2c/jsxsd/kscj/cjcx_list';
  @HiveField(46)
  String jwScore2Url =
      'https://client.v.just.edu.cn/http/webvpneb26120c0b61d26f61ce45ea5ef07bf864a455884ca2133c138748630669de2c/jsxsd/kscj/cjtd_add_left';
  @HiveField(47)
  String jwCourseUrl =
      'https://client.v.just.edu.cn/http/webvpneb26120c0b61d26f61ce45ea5ef07bf864a455884ca2133c138748630669de2c/jsxsd/xskb/xskb_list.do';
  @HiveField(48)
  String jwPjUrl =
      'https://client.v.just.edu.cn/http/webvpneb26120c0b61d26f61ce45ea5ef07bf864a455884ca2133c138748630669de2c/jsxsd/xspj/xspj_find.do?Ves632DSdyV=NEW_XSD_JXPJ';
  @HiveField(49)
  String syLoginUrl =
      'https://client.v.just.edu.cn/http/webvpne73681c95b0d384ea01cc5f6576497e6/sy/';
  @HiveField(50)
  String syHomeUrl =
      'https://client.v.just.edu.cn/http/webvpne73681c95b0d384ea01cc5f6576497e6/sy/student/xsDefault.aspx';
  @HiveField(51)
  String jwClickUrl = 'https://client.v.just.edu.cn/http/webvpneb26120c0b61d26f61ce45ea5ef07bf864a455884ca2133c138748630669de2c/sso.jsp';
  @HiveField(52)
  String syClickUrl = 'https://client.v.just.edu.cn/http/webvpne73681c95b0d384ea01cc5f6576497e6/sy/';

  DateTime get dayFlag => _dayFlag;

  set dayFlag(DateTime value) {
    _dayFlag = value;
    notifyListeners();
  }

  bool get isNewUser => _isNewUser;

  set isNewUser(bool value) {
    _isNewUser = value;
    notifyListeners();
  }

  String get scoreQuerySemester => _scoreQuerySemester;

  set scoreQuerySemester(String value) {
    _scoreQuerySemester = value;
    notifyListeners();
  }

  ScoreQueryMode get scoreQueryMode => _scoreQueryMode;

  set scoreQueryMode(ScoreQueryMode value) {
    _scoreQueryMode = value;
    notifyListeners();
  }

  DateTime get beginTime => _beginTime;

  set beginTime(DateTime value) {
    _beginTime = value;
    notifyListeners();
  }

  TableMode get tableMode => _tableMode;

  set tableMode(TableMode value) {
    _tableMode = value;
    notifyListeners();
  }

  bool get onlyShowThisWeek => _onlyShowThisWeek;

  set onlyShowThisWeek(bool value) {
    _onlyShowThisWeek = value;
    notifyListeners();
  }

  bool get showCourseBackground => _showCourseBackground;

  set showCourseBackground(bool value) {
    _showCourseBackground = value;
    notifyListeners();
  }

  String get courseBackgroundPath => _courseBackgroundPath;

  set courseBackgroundPath(String value) {
    _courseBackgroundPath = value;
    notifyListeners();
  }

  bool get showScoreBackground => _showScoreBackground;

  set showScoreBackground(bool value) {
    _showScoreBackground = value;
    notifyListeners();
  }

  String get scoreBackgroundPath => _scoreBackgroundPath;

  set scoreBackgroundPath(String value) {
    _scoreBackgroundPath = value;
    notifyListeners();
  }

  bool get showToolBackground => _showToolBackground;

  set showToolBackground(bool value) {
    _showToolBackground = value;
    notifyListeners();
  }

  String get toolBackgroundPath => _toolBackgroundPath;

  set toolBackgroundPath(String value) {
    _toolBackgroundPath = value;
    notifyListeners();
  }

  bool get reverseScore => _reverseScore;

  set reverseScore(bool value) {
    _reverseScore = value;
    notifyListeners();
  }

  bool get autoCheckUpdate => _autoCheckUpdate;

  set autoCheckUpdate(bool value) {
    _autoCheckUpdate = value;
    notifyListeners();
  }

  bool get tableScrollable => _tableScrollable;

  set tableScrollable(bool value) {
    _tableScrollable = value;
    notifyListeners();
  }

  List<String> get semesterList => _semesterList;

  set semesterList(List<String> value) {
    _semesterList = value;
    notifyListeners();
  }

  String get currentSemester => _currentSemester;

  set currentSemester(String value) {
    _currentSemester = value;
    notifyListeners();
  }

  bool get refreshTablePerDay => _refreshTablePerDay;

  set refreshTablePerDay(bool value) {
    _refreshTablePerDay = value;
    notifyListeners();
  }

  int get semesterWeek => _semesterWeek;

  set semesterWeek(int value) {
    _semesterWeek = value;
    notifyListeners();
  }

  List<Color> get courseColor => _courseColor;

  set courseColor(List<Color> value) {
    _courseColor = value;
    notifyListeners();
  }

  String get avatarPath => _avatarPath;

  set avatarPath(String value) {
    _avatarPath = value;
    notifyListeners();
  }

  DateTime get lastRefreshAt => _lastRefreshAt;

  set lastRefreshAt(DateTime value) {
    _lastRefreshAt = value;
    notifyListeners();
  }

  ScoreDisplayMode get scoreDisplayMode => _scoreDisplayMode;

  set scoreDisplayMode(ScoreDisplayMode value) {
    _scoreDisplayMode = value;
    notifyListeners();
  }

  bool get saveScoreCloud => _saveScoreCloud;

  set saveScoreCloud(bool value) {
    _saveScoreCloud = value;
    notifyListeners();
  }

  SystemMode get systemMode => _systemMode;

  set systemMode(SystemMode value) {
    _systemMode = value;
    notifyListeners();
  }

  String get campus => _campus;

  set campus(String value) {
    _campus = value;
    notifyListeners();
  }

  List<String> get timeTable => _timeTable;

  set timeTable(List<String> value) {
    _timeTable = value;
    notifyListeners();
  }

  double get initHeight => _initHeight;

  set initHeight(double value) {
    _initHeight = value;
    notifyListeners();
  }

  int get initSelectionNumber => _initSelectionNumber;

  set initSelectionNumber(int value) {
    _initSelectionNumber = value;
    notifyListeners();
  }

  bool get showSaturday => _showSaturday;

  set showSaturday(bool value) {
    _showSaturday = value;
    notifyListeners();
  }

  bool get showSunday => _showSunday;

  set showSunday(bool value) {
    _showSunday = value;
    notifyListeners();
  }

  double get courseCircular => _courseCircular;

  set courseCircular(double value) {
    _courseCircular = value;
    notifyListeners();
  }

  int get appWidgetOpacity => _appWidgetOpacity;

  set appWidgetOpacity(int value) {
    _appWidgetOpacity = value;
    notifyListeners();
  }

  double get courseMargin => _courseMargin;

  set courseMargin(double value) {
    _courseMargin = value;
    notifyListeners();
  }

  double get coursePadding => _coursePadding;

  set coursePadding(double value) {
    _coursePadding = value;
    notifyListeners();
  }

  double get courseFontSize => _courseFontSize;

  set courseFontSize(double value) {
    _courseFontSize = value;
    notifyListeners();
  }

  FStarMode get fStarMode => _fStarMode;

  set fStarMode(FStarMode value) {
    _fStarMode = value;
    notifyListeners();
  }

  int get unusedCourseColorIndex => _unusedCourseColorIndex;

  set unusedCourseColorIndex(int value) {
    _unusedCourseColorIndex = value;
    notifyListeners();
  }

  Color get boxColor => _boxColor;

  set boxColor(Color value) {
    _boxColor = value;
    notifyListeners();
  }

  Color get tableBackgroundColor => _tableBackgroundColor;

  set tableBackgroundColor(Color value) {
    _tableBackgroundColor = value;
    notifyListeners();
  }

  bool get shadow => _shadow;

  set shadow(bool value) {
    _shadow = value;
    notifyListeners();
  }

  IdentityType get identityType => _identityType;

  set identityType(IdentityType value) {
    _identityType = value;
    notifyListeners();
  }
}
