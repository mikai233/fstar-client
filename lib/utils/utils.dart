import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fstar/model/application.dart';
import 'package:fstar/model/box_name.dart';
import 'package:fstar/model/changelog.dart';
import 'package:fstar/model/client_data.dart';
import 'package:fstar/model/course_data.dart';
import 'package:fstar/model/course_map.dart';
import 'package:fstar/model/f_result.dart';
import 'package:fstar/model/fstar_mode_enum.dart';
import 'package:fstar/model/identity_enum.dart';
import 'package:fstar/model/message_data.dart';
import 'package:fstar/model/score_data.dart';
import 'package:fstar/model/score_display_mode_enum.dart';
import 'package:fstar/model/score_query_mode_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/system_mode_enum.dart';
import 'package:fstar/model/user_data.dart';
import 'package:fstar/page/privacy_policy_page.dart';
import 'package:fstar/utils/FStarNet.dart';
import 'package:fstar/utils/fstar_scroll_behavior.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/parser.dart';
import 'package:fstar/utils/requester.dart';
import 'package:hive/hive.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum FPlatform {
  android,
  fuchsia,
  iOS,
  linux,
  macOS,
  windows,
  web,
}

class FStarResultError extends Error {
  final Object message;

  FStarResultError([this.message = '繁星服务器或客户端错误']);

  @override
  String toString() {
    return message.toString();
  }
}

typedef Predicate = bool Function(ScoreData scoreData);

FPlatform getCurrentPlatform() {
  if (Platform.isAndroid) {
    return FPlatform.android;
  }
  if (Platform.isIOS) {
    return FPlatform.iOS;
  }
  if (Platform.isFuchsia) {
    return FPlatform.fuchsia;
  }
  if (Platform.isMacOS) {
    return FPlatform.macOS;
  }
  if (Platform.isWindows) {
    return FPlatform.windows;
  }
  if (Platform.isLinux) {
    return FPlatform.linux;
  }
  if (kIsWeb) {
    return FPlatform.web;
  }
  throw UnimplementedError('未知平台');
}

Logger logger() {
  var logger = Logger(
    printer: PrettyPrinter(),
  );
  return logger;
}

E getBoxData<E extends HiveObject>(String boxName) {
  return Hive.box(boxName).get(0);
}

//此函数从给定的起始时间和周数生成一个以天为单位的时间数组，需要注意的是如果起始时间不是星期一，需要定位到当前周的星期一
List<DateTime> generate(DateTime beginTime, int weeks) {
  var reviseBeginTime = reviseTime(beginTime);
  List<DateTime> timeList = [];
  for (var i = 0; i < weeks * 7; ++i) {
    timeList.add(reviseBeginTime);
    reviseBeginTime = reviseBeginTime.add(Duration(days: 1));
  }
  return timeList;
}

//把时间校正到周一
DateTime reviseTime(DateTime beginTime) {
  var reviseBeginTime = beginTime;
  var weekday = beginTime.weekday;
  if (weekday != 1) {
    reviseBeginTime = beginTime.add(Duration(days: 1 - weekday));
  }
  return reviseBeginTime;
}

//计算当前周
int getCurrentWeek() {
  var beginTime = getBeginTime();
  var days = DateTime.now().difference(beginTime).inDays;
  int week = (days / 7).floor();
  if (week < 0) return 0;
  var semesterWeek = getSemesterWeek();
  if (week >= semesterWeek) {
    return semesterWeek - 1;
  }
//week从0开始
  return week;
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool sameWeek(DateTime a, DateTime b) {
  var reviseA = reviseTime(a);
  var reviseB = reviseTime(b);
  return sameDay(reviseA, reviseB);
}

Future<T> pushPage<T extends Object>(BuildContext context, Widget page,
    {RouteSettings settings}) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => page, settings: settings),
  );
}

Color getReverseForegroundColor(BuildContext context) {
  var primaryColor = Theme.of(context).primaryColor;
  var grayLevel = (0.299 * primaryColor.red +
          0.587 * primaryColor.green +
          0.114 * primaryColor.blue) /
      255;
  return grayLevel > 0.5 ? Colors.black : Colors.white;
}

bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Future<File> cropImage(BuildContext context, String imagePath) async {
  File croppedFile = await ImageCropper.cropImage(
    sourcePath: imagePath,
    aspectRatioPresets: Platform.isAndroid
        ? [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ]
        : [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio7x5,
            CropAspectRatioPreset.ratio16x9
          ],
    androidUiSettings: AndroidUiSettings(
        activeControlsWidgetColor: isDarkMode(context)
            ? Theme.of(context).accentColor
            : Theme.of(context).primaryColor,
        toolbarTitle: '裁剪',
        toolbarColor: Theme.of(context).primaryColor,
        toolbarWidgetColor: getReverseForegroundColor(context),
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false),
    iosUiSettings: IOSUiSettings(
      title: '裁剪图片',
    ),
  );
  return croppedFile;
}

String indexWeekToStringWeek(int index) {
  String result;
  switch (index) {
    case 1:
      result = '一';
      break;
    case 2:
      result = '二';
      break;
    case 3:
      result = '三';
      break;
    case 4:
      result = '四';
      break;
    case 5:
      result = '五';
      break;
    case 6:
      result = '六';
      break;
    case 7:
      result = '日';
      break;
    default:
      throw RangeError.range(index, 1, 7);
  }
  return result;
}

int stringWeekToIndexWeek(String week) {
  int result;
  switch (week) {
    case '一':
      result = 1;
      break;
    case '二':
      result = 2;
      break;
    case '三':
      result = 3;
      break;
    case '四':
      result = 4;
      break;
    case '五':
      result = 5;
      break;
    case '六':
      result = 6;
      break;
    case '日':
      result = 7;
      break;
    default:
      throw ArgumentError.value(week);
  }
  return result;
}

DateTime getBeginTime() {
  return getBoxData<SettingsData>(BoxName.settingsBox).beginTime;
}

int getSemesterWeek() {
  return getBoxData<SettingsData>(BoxName.settingsBox).semesterWeek;
}

Map<int, List<CourseData>> generateEmptyCourseMap() {
  Map<int, List<CourseData>> emptyMap = {};
  for (int i = 1; i <= 7; ++i) {
    emptyMap[i] = [];
  }
  return emptyMap;
}

Color getReverseForegroundTextColor(Color color) {
  var grayLevel =
      (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
  return grayLevel > 0.5 ? Colors.black : Colors.white;
}

String weekList2RawWeek(List<int> weekList) {
  var ordered = SplayTreeSet.of(weekList);
  var begin = -1;
  var result = <String>[];
  for (int i = ordered.first; i <= ordered.last + 1; ++i) {
    if (ordered.contains(i) && begin == -1) {
      begin = i;
    }
    if (!ordered.contains(i) && begin != -1) {
      if (begin == i - 1) {
        result.add('$begin');
      } else {
        result.add('$begin-${i - 1}');
      }
      begin = -1;
    }
  }
  return result.join(',') + '(周)';
}

List<Color> getColorList() {
  return [
    Color(0XFF00CCFF), //0
    Color(0XFF8D4BBB), //1
    Color(0XFF33CC99), //2
    Color(0XFFEF7A82), //3
    Color(0XFF789262), //4
    Color(0XFF66CCCC), //5
    Color(0XFF9999FF), //6
    Color(0XFF6699CC), //7
    Color(0XFF88ADA6), //8
    Color(0XFF9D2933), //9
    Color(0XFF758a99), //10
    Color(0XFF549688), //11
    Color(0XFF815476), //12
    Color(0XFF4b5cc4), //13
    Color(0XFFDB5A6B), //14
    Color(0XFFFF00CC), //15
    Color(0XFFC83C23), //16
    Color(0XFF44CEF6), //17
  ];
}

extension IndexedForEach<E> on List<E> {
  void forEachIndexed(void action(int index, E element)) {
    int length = this.length;
    for (int i = 0; i < length; i++) {
      action(i, this[i]);
      if (length != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
  }
}

SettingsData getSettingsData() {
  return getBoxData<SettingsData>(BoxName.settingsBox);
}

UserData getUserData() {
  return getBoxData<UserData>(BoxName.userBox);
}

Future<T> showModalBottomCourseEditSheet<T>(BuildContext context,
    {CourseData courseData}) {
  final formKey = GlobalKey<FormState>();
  final nullCourse = courseData == null ? true : false;
  var groupValue = -1;
  var selectedWeek = nullCourse ? <int>[] : courseData.week;
  var dayOfWeek = nullCourse ? 1 : courseData.column;
  final dayOfWeekController = nullCourse
      ? FixedExtentScrollController()
      : FixedExtentScrollController(initialItem: dayOfWeek - 1);
  var begin = nullCourse ? 1 : courseData.row;
  final beginController = nullCourse
      ? FixedExtentScrollController()
      : FixedExtentScrollController(initialItem: begin - 1);
  var end = nullCourse ? 2 : courseData.row + courseData.rowSpan - 1;
  final endController = nullCourse
      ? FixedExtentScrollController(initialItem: end - 1)
      : FixedExtentScrollController(initialItem: end - 1);
  final nameController = nullCourse
      ? TextEditingController()
      : TextEditingController.fromValue(
          TextEditingValue(text: courseData.name));
  final roomController = nullCourse
      ? TextEditingController()
      : TextEditingController.fromValue(
          TextEditingValue(text: courseData.classroom));
  final teacherController = nullCourse
      ? TextEditingController()
      : TextEditingController.fromValue(
          TextEditingValue(text: courseData.teacher));
  final idController = nullCourse
      ? TextEditingController()
      : TextEditingController.fromValue(TextEditingValue(text: courseData.id));
  Color retrieveColor(CourseData courseData) {
    if (courseData.customColor != null) {
      return courseData.customColor;
    } else {
      return courseData.defaultColor;
    }
  }

  Color buildContainerColor(BuildContext context, int index) {
    if (selectedWeek.contains(index)) {
      return Theme.of(context).primaryColor;
    } else {
      return Color.fromRGBO(250, 250, 250, 1);
    }
  }

  Color buildTextColor(BuildContext context, int index) {
    if (selectedWeek.contains(index)) {
      return getReverseForegroundColor(context);
    } else {
      return Colors.grey;
    }
  }

  InputDecoration getInputDecoration({String labelText, String suffixText}) {
    return InputDecoration(
      labelText: labelText,
      suffixText: suffixText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(width: 0, style: BorderStyle.none),
      ),
      fillColor: isDarkMode(context) ? null : Color.fromRGBO(250, 250, 250, 1),
      filled: true,
      focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(10)),
    );
  }

  Color pickerColor =
      nullCourse ? Theme.of(context).primaryColor : retrieveColor(courseData);
  Color currentColor = nullCourse
      ? null
      : pickerColor == courseData.defaultColor
          ? null
          : pickerColor;

  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) => Container(
            decoration: BoxDecoration(
                color: isDarkMode(context)
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            height: MediaQuery.of(context).size.height / 4 * 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      children: [
                        nullCourse
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextButton(
                                  child: Icon(FontAwesomeIcons.times),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextButton(
                                  child: Icon(FontAwesomeIcons.trash),
                                  onPressed: () {
                                    try {
                                      context.read<CourseMap>()
                                        ..removeCourse(courseData)
                                        ..save();
                                    } catch (e) {
                                      EasyLoading.showError(e.toString());
                                    }
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextButton(
                            onPressed: () async {
                              var ok = formKey.currentState.validate();
                              if (ok) {
                                if (begin > end) {
                                  EasyLoading.showToast('开始小节应小于等于结束小节');
                                  return;
                                }
                                if (nullCourse) {
                                  final colors = getColorList();
                                  final newCourse = CourseData(
                                      name: nameController.text.trim(),
                                      id: idController.text.trim(),
                                      classroom: roomController.text.trim(),
                                      week: selectedWeek,
                                      row: begin,
                                      column: dayOfWeek,
                                      teacher: teacherController.text.trim(),
                                      rowSpan: end - begin + 1,
                                      customColor: currentColor,
                                      defaultColor: colors[getSettingsData()
                                              .unusedCourseColorIndex++ %
                                          colors.length],
                                      top: 0);
                                  try {
                                    context.read<CourseMap>()
                                      ..addCourseByList([newCourse])
                                      ..save();
                                  } catch (e) {
                                    EasyLoading.showError(e.toString());
                                  }
                                } else {
                                  final editedCourse = courseData.copyWith(
                                      name: nameController.text.trim(),
                                      id: idController.text.trim(),
                                      classroom: roomController.text.trim(),
                                      week: selectedWeek,
                                      row: begin,
                                      column: dayOfWeek,
                                      teacher: teacherController.text.trim(),
                                      rowSpan: end - begin + 1,
                                      customColor: currentColor);
                                  try {
                                    context.read<CourseMap>()
                                      ..editCourse(
                                          newCourse: editedCourse,
                                          oldCourse: courseData)
                                      ..save();
                                  } catch (e) {
                                    EasyLoading.showError(e.toString());
                                  }
                                }
                                Navigator.pop(context);
                              }
                            },
                            child: Icon(FontAwesomeIcons.check),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                  ),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: FStarOverScrollBehavior(),
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 4.0),
                                    child: TextFormField(
                                      controller: nameController,
                                      validator: (String value) {
                                        if (value.trim().isEmpty) {
                                          return '请输入课程名称';
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration:
                                          getInputDecoration(labelText: '课程名称'),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 4.0),
                                    child: TextFormField(
                                      controller: idController,
                                      decoration: getInputDecoration(
                                          labelText: '课程号', suffixText: '可选'),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 4.0),
                                    child: TextFormField(
                                      controller: teacherController,
                                      decoration: getInputDecoration(
                                          labelText: '老师', suffixText: '可选'),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 4.0),
                                    child: TextFormField(
                                      controller: roomController,
                                      decoration: getInputDecoration(
                                          labelText: '教室', suffixText: '可选'),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    '星期',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                      looping: true,
                                      itemExtent: 40,
                                      scrollController: dayOfWeekController,
                                      onSelectedItemChanged: (int value) {
                                        dayOfWeek = value + 1;
                                      },
                                      children: List.generate(
                                        7,
                                        (index) => Center(
                                          child: Text(
                                            indexWeekToStringWeek(
                                              index + 1,
                                            ),
                                            style: TextStyle(
                                                color: isDarkMode(context)
                                                    ? Colors.white
                                                    : null),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Text(
                                      '第',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                      looping: true,
                                      itemExtent: 40,
                                      scrollController: beginController,
                                      onSelectedItemChanged: (int value) {
                                        begin = value + 1;
                                      },
                                      children: List.generate(
                                        getSettingsData().initSelectionNumber,
                                        (index) => Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                                color: isDarkMode(context)
                                                    ? Colors.white
                                                    : null),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '-',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                      looping: true,
                                      itemExtent: 40,
                                      scrollController: endController,
                                      onSelectedItemChanged: (int value) {
                                        end = value + 1;
                                      },
                                      children: List.generate(
                                        getBoxData<SettingsData>(
                                                BoxName.settingsBox)
                                            .initSelectionNumber,
                                        (index) => Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                                color: isDarkMode(context)
                                                    ? Colors.white
                                                    : null),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Text(
                                      '节',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.NO_HEADER,
                                        body: StatefulBuilder(
                                          builder: (BuildContext context,
                                                  StateSetter stateSetter) =>
                                              Column(
                                            children: [
                                              ColorPicker(
                                                pickerColor: pickerColor,
                                                onColorChanged: (Color c) {
                                                  pickerColor = c;
                                                },
                                                showLabel: true,
                                                pickerAreaHeightPercent: 0.8,
                                              ),
                                              Row(
                                                children: [
                                                  if (!nullCourse)
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    16.0,
                                                                vertical: 2.0),
                                                        child: ElevatedButton(
                                                          child: Text('重置'),
                                                          onPressed: () {
                                                            stateSetter
                                                                .call(() {
                                                              pickerColor =
                                                                  courseData
                                                                      .defaultColor;
                                                              currentColor =
                                                                  null;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 2.0),
                                                      child: ElevatedButton(
                                                        child: Text('确定'),
                                                        onPressed: () {
                                                          currentColor =
                                                              pickerColor;
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ).show();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Text('颜色'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('空'),
                                      onChanged: (value) {
                                        stateSetter.call(() {
                                          selectedWeek.clear();
                                          groupValue = value;
                                        });
                                      },
                                      groupValue: groupValue,
                                      value: -1,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('单周'),
                                      onChanged: (value) {
                                        stateSetter.call(() {
                                          selectedWeek = List.generate(
                                                  25, (index) => index + 1)
                                              .where(
                                                  (element) => element % 2 != 0)
                                              .toList();
                                          groupValue = value;
                                        });
                                      },
                                      groupValue: groupValue,
                                      value: 0,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('双周'),
                                      onChanged: (value) {
                                        stateSetter.call(() {
                                          selectedWeek = List.generate(
                                                  25, (index) => index + 1)
                                              .where(
                                                  (element) => element % 2 == 0)
                                              .toList();
                                          groupValue = value;
                                        });
                                      },
                                      groupValue: groupValue,
                                      value: 1,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('全部'),
                                      onChanged: (value) {
                                        stateSetter.call(() {
                                          selectedWeek = List.generate(
                                              25, (index) => index + 1);
                                          groupValue = value;
                                        });
                                      },
                                      groupValue: groupValue,
                                      value: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2),
                              child: Wrap(
                                direction: Axis.horizontal,
                                children: List.generate(
                                  getSettingsData().semesterWeek,
                                  (index) => Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        stateSetter.call(() {
                                          if (selectedWeek
                                              .contains(index + 1)) {
                                            selectedWeek.remove(index + 1);
                                          } else {
                                            selectedWeek.add(index + 1);
                                          }
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  offset: Offset(1.0, 2.0),
                                                  blurRadius: 4.0,
                                                  spreadRadius: 0.2)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: buildContainerColor(
                                                context, index + 1)),
                                        width: 50,
                                        height: 35,
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                                color: buildTextColor(
                                                    context, index + 1)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

//学年绩点的计算过度依赖于教务系统成绩的排列顺序
List<String> calculateGPA(List<ScoreData> scoreData, Predicate predicate) {
  var semesters = Map<String, List<ScoreData>>();
  for (var score in scoreData) {
    if (semesters[score.semester] == null) {
      semesters[score.semester] = [];
    }
    semesters[score.semester].add(score);
  }
  List<String> result = List<String>();
//如果是最好成绩
  final settings = getSettingsData();
  if (settings.scoreDisplayMode == ScoreDisplayMode.MAX &&
      settings.scoreQueryMode == ScoreQueryMode.DEFAULT) {
    result.add("最好成绩(绩点可作参考)");
  }
  if (settings.scoreDisplayMode != ScoreDisplayMode.MAX &&
      settings.scoreQueryMode == ScoreQueryMode.DEFAULT) {
    result.add("全部成绩(绩点不作参考)");
  }
  if (settings.scoreQueryMode != ScoreQueryMode.DEFAULT) {
    result.add("绩点不作参考");
  }
//总平均绩点
  double totalGPA = 0;
  double totalUp = 0;
  double totalDown = 0;
//学年平均绩点
  double yearGPA = 0;
  double yearUp = 0;
  double yearDown = 0;
//计算每学年绩点标志
  int toggleYear = 0;
//每学期平均绩点
  semesters.forEach((semester, scoreList) {
    double up = 0;
    double down = 0;
    double GPA = 0;
    scoreList.forEach((score) {
      if (predicate(score)) {
        if (score.score == "优") {
          up += double.parse(score.credit) * (95 / 10 - 5);
        }
        if (score.score == "良") {
          up += double.parse(score.credit) * (85 / 10 - 5);
        }
        if (score.score == "中" || score.score == "合格") {
          up += double.parse(score.credit) * (75 / 10 - 5);
        }
        if (score.score == "及格") {
          up += double.parse(score.credit) * (65 / 10 - 5);
        }
        if (score.score == "通过") {
          up += double.parse(score.credit) * (75 / 10 - 5);
        }
//          if (score.score == "不及格" || score.score == "不通过") {}
//绩点小于1时按0计
        try {
          if (double.parse(score.score) >= 60) {
            up += double.parse(score.credit) *
                (double.parse(score.score) / 10 - 5);
          }
        } catch (e) {
//            Global.logger.e(e);
        } finally {
          down += double.parse(score.credit);
        }
      }
    });
    totalUp += up;
    totalDown += down;

    if (semesters
        .containsKey(semester.substring(0, semester.length - 1) + '2')) {
      toggleYear++;
      yearUp += up;
      yearDown += down;
    }

    GPA = up / down;
    result.add("$semester学期平均绩点：${GPA.toStringAsFixed(3)}");
    if (toggleYear == 2) {
      toggleYear = 0;
      yearGPA = yearUp / yearDown;
      result.add(
          "---${semester.substring(0, semester.length - 2)}学年平均绩点: ${yearGPA.toStringAsFixed(3)}---");
      yearUp = 0;
      yearDown = 0;
    }
  });
  totalGPA = totalUp / totalDown;
  if (totalGPA.isNaN) {
    totalGPA = 0;
  }
  result.add("总平均绩点：${totalGPA.toStringAsFixed(3)}");
  return result;
}

String calculateGPA2(List<ScoreData> scoreData, Predicate predicate) {
  double up = 0;
  double down = 0;
  double GPA = 0;
  scoreData.forEach((score) {
    if (predicate(score)) {
      if (score.score == "优") {
        up += double.parse(score.credit) * (95 / 10 - 5);
      }
      if (score.score == "良") {
        up += double.parse(score.credit) * (85 / 10 - 5);
      }
      if (score.score == "中" || score.score == "合格") {
        up += double.parse(score.credit) * (75 / 10 - 5);
      }
      if (score.score == "及格") {
        up += double.parse(score.credit) * (65 / 10 - 5);
      }
      if (score.score == "通过") {
        up += double.parse(score.credit) * (75 / 10 - 5);
      }
      try {
        if (double.parse(score.score) >= 60) {
          up +=
              double.parse(score.credit) * (double.parse(score.score) / 10 - 5);
        }
      } catch (e) {
//            Global.logger.e(e);
      } finally {
        down += double.parse(score.credit);
      }
    }
  });
  GPA = up / down;
  return GPA.toStringAsFixed(3);
}

void configRequesterAndParser() {
  final settings = getSettingsData();
  switch (settings.fStarMode) {
    case FStarMode.JUST:
      {
        switch (settings.identityType) {
          case IdentityType.undergraduate:
            switch (settings.systemMode) {
              case SystemMode.JUST:
                {
                  Application.courseRequester = DefaultCourseRequester();
                  Application.courseParser = DefaultCourseParser();
                  switch (settings.scoreQueryMode) {
                    case ScoreQueryMode.DEFAULT:
                      Application.scoreRequester = DefaultScoreRequester();
                      Application.scoreParser = DefaultScoreParser();
                      break;
                    case ScoreQueryMode.ALTERNATIVE:
                      Application.scoreRequester = AlternativeScoreRequester();
                      Application.scoreParser = AlternativeScoreParser();
                      break;
                  }
                }
                break;
              case SystemMode.VPN:
                {
                  Application.courseRequester = VPNCourseRequester();
                  Application.courseParser = DefaultCourseParser();
                  switch (settings.scoreQueryMode) {
                    case ScoreQueryMode.DEFAULT:
                      Application.scoreRequester = VPNScoreRequester();
                      Application.scoreParser = DefaultScoreParser();
                      break;
                    case ScoreQueryMode.ALTERNATIVE:
                      Application.scoreRequester =
                          VPNAlternativeScoreRequester();
                      Application.scoreParser = AlternativeScoreParser();
                      break;
                  }
                }
                break;
              case SystemMode.VPN2:
                // TODO: Handle this case.
                break;
              case SystemMode.CLOUD:
                // TODO: Handle this case.
                break;
            }
            break;
          case IdentityType.graduate:
            Application.courseRequester = GraduateCourseRequester();
            Application.courseParser = GraduateCourseParser();
            break;
          // case IdentityType.teacher:
            // TODO: Handle this case.
            // break;
        }
      }
      break;
    case FStarMode.ThirdParty:
      // TODO: Handle this case.
      break;
  }
}

// void configRequester() {
//   final settings = getSettingsData();
//   final user = getUserData();
//   switch (settings.fStarMode) {
//     case FStarMode.JUST:
//       switch (settings.systemMode) {
//         case SystemMode.JUST:
//           Application.courseRequester = DefaultCourseRequester();
//           switch (settings.scoreQueryMode) {
//             case ScoreQueryMode.DEFAULT:
//               Application.scoreRequester = DefaultScoreRequester();
//               break;
//             case ScoreQueryMode.ALTERNATIVE:
//               Application.scoreRequester = AlternativeScoreRequester();
//               break;
//           }
//           break;
//         case SystemMode.VPN:
//           // TODO: Handle this case.
//           break;
//         case SystemMode.VPN2:
//           // TODO: Handle this case.
//           break;
//         case SystemMode.CLOUD:
//           // TODO: Handle this case.
//           break;
//       }
//       break;
//     case FStarMode.ThirdParty:
//       // TODO: Handle this case.
//       break;
//   }
// }

Future showScoreDetails(BuildContext context, ScoreData scoreData) {
  final size = MediaQuery.of(context).size;
  final controller = ScrollController();
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.NO_HEADER,
    onDissmissCallback: () {
      controller.dispose();
    },
    body: Container(
      height: size.height / 2,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              '详情',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(
            thickness: 1.5,
          ),
          Expanded(
            child: Scrollbar(
              isAlwaysShown: true,
              controller: controller,
              child: ListView(
                controller: controller,
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      ListTile(
                        leading: Text("课程号"),
                        title: Text(scoreData.scoreNo),
                      ),
                      ListTile(
                        leading: Text("课程名称"),
                        title: Text(scoreData.name),
                      ),
                      ListTile(
                        leading: Text("开课学期"),
                        title: Text(scoreData.semester),
                      ),
                      ListTile(
                        leading: Text("成绩"),
                        title: Text(scoreData.score),
                      ),
                      ListTile(
                        leading: Text("学分"),
                        title: Text(scoreData.credit),
                      ),
                      ListTile(
                        leading: Text("总学时"),
                        title: Text(scoreData.period),
                      ),
                      ListTile(
                        leading: Text("考核方式"),
                        title: Text(scoreData.evaluationMode),
                      ),
                      ListTile(
                        leading: Text("课程属性"),
                        title: Text(scoreData.courseProperty),
                      ),
                      ListTile(
                        leading: Text("课程性质"),
                        title: Text(scoreData.courseNature),
                      ),
                      ListTile(
                        leading: Text("替代课程号"),
                        title: Text(scoreData.alternativeCourseNumber),
                      ),
                      ListTile(
                        leading: Text("替代课程名"),
                        title: Text(scoreData.alternativeCourseName),
                      ),
                      ListTile(
                        leading: Text("成绩标志"),
                        title: Text(scoreData.scoreFlag),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    btnOk: ElevatedButton(
      // color: Theme.of(context).primaryColor,
      child: Text(
        '确定',
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ).show();
}

Future<dynamic> setCookie({@required String cookie, @required String url}) {
  final cookieManager = CookieManager.instance();
  final List<Future> waitList = [];
  List<String> lc = cookie.split(' ');
  for (final i in lc) {
    final c = i.split("=");
    waitList.add(cookieManager.setCookie(url: url, name: c[0], value: c[1]));
  }
  return Future.wait(waitList);
}

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

showPrivacyPolicy(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.NO_HEADER,
    dismissOnTouchOutside: false,
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              '服务协议和隐私政策',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text:
                        '请你务必谨慎阅读、充分理解服务协议和隐私政策， 包括但不限于：为了向你提供课表信息，导出成绩等功能， 我们需要获取网络权限，存储权限以及收集你的设备信息。 你可以在设置中查看该隐私政策。'),
                TextSpan(text: '\n\n你可阅读'),
                TextSpan(
                    text: '《服务协议和隐私政策》',
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        pushPage(context, PrivacyPolicy());
                      }),
                TextSpan(text: '了解详细信息，如你同意，请点击同意开始接受我们的服务。')
              ],
            ),
          ),
        ),
      ],
    ),
    btnCancel: OutlinedButton(
      onPressed: () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      },
      child: Text(
        '暂不使用',
        style: TextStyle(color: Colors.black),
      ),
    ),
    btnOk: OutlinedButton(
      onPressed: () {
        context.read<SettingsData>()
          ..isNewUser = false
          ..save();
        Navigator.pop(context);
      },
      child: Text(
        '同意',
        style: TextStyle(color: Colors.blue),
      ),
    ),
  ).show();
}

void checkResult(FResult result) {
  if (result.code != 200) {
    throw FStarResultError(result.message);
  }
}

Future<void> showMessage(BuildContext context) async {
  try {
    var packageInfo = await PackageInfo.fromPlatform();
    var buildNumber = int.parse(packageInfo.buildNumber);
    var result = await FStarNet().getCurrentMessage(buildNumber);
    checkResult(result);
    if (result.data == null) {
      return;
    }
    var messageData = MessageData.fromMap(result.data);
    if (messageData.minVisibleBuildNumber > buildNumber) {
      return;
    }
    final digest = calculateDigest(messageData.toString()).toString();
    final prefs = await SharedPreferences.getInstance();
    final localDigest = prefs.getString('messageDigest');
    if (digest == localDigest) {
      return;
    }
    var messages = messageData.content.split('-');
    final controller = ScrollController();
    AwesomeDialog(
        context: context,
        dialogType: DialogType.INFO,
        body: Container(
          height: MediaQuery.of(context).size.height / 3,
          child: ScrollConfiguration(
            behavior: FStarOverScrollBehavior(),
            child: Scrollbar(
              isAlwaysShown: true,
              controller: controller,
              child: ListView.separated(
                controller: controller,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(messages[index]),
                  );
                },
                itemCount: messages.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              ),
            ),
          ),
        ),
        btnOk: ElevatedButton(
          onPressed: () {
            prefs.setString('messageDigest', digest);
            Navigator.pop(context);
          },
          child: Text('确定'),
        )).show();
  } catch (e) {
    Log.logger.e(e.toString());
  }
}

Future<void> updateVitality(BuildContext context) async {
  switch (getCurrentPlatform()) {
    case FPlatform.android:
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var packageInfo = await PackageInfo.fromPlatform();
      var clientData = ClientData(
          id: null,
          appVersion: packageInfo.version,
          buildNumber: int.parse(packageInfo.buildNumber),
          androidId: androidInfo.androidId,
          adnoridVersion: androidInfo.version.release,
          brand: androidInfo.brand,
          device: androidInfo.device,
          model: androidInfo.model,
          platform: 'android');
      try {
        FStarNet().updateStatus(clientData);
      } catch (e) {
        Log.logger.e((e.toString()));
      }
      break;
    case FPlatform.fuchsia:
      // TODO: Handle this case.
      break;
    case FPlatform.iOS:
      // TODO: Handle this case.
      break;
    case FPlatform.linux:
      // TODO: Handle this case.
      break;
    case FPlatform.macOS:
      // TODO: Handle this case.
      break;
    case FPlatform.windows:
      // TODO: Handle this case.
      break;
    case FPlatform.web:
      // TODO: Handle this case.
      break;
  }
}

Digest calculateDigest(String content) {
  var digest = sha256.convert(utf8.encode(content));
  return digest;
}

Future<bool> showCheckVersion(BuildContext context) async {
  bool newVersion = false;
  var packageInfo = await PackageInfo.fromPlatform();
  var buildNumber = int.parse(packageInfo.buildNumber) ?? 0;
  try {
    var result = await FStarNet().checkVersion();
    checkResult(result);
    var changelog = Changelog.fromMap(result.data);
    if (changelog.buildNumber > buildNumber) {
      newVersion = true;
      final scrollController = ScrollController();
      var messages = changelog.description.split('-');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.NO_HEADER,
        body: Container(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            children: [
              Center(
                child: Text(
                  '新版本',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  controller: scrollController,
                  isAlwaysShown: true,
                  child: ScrollConfiguration(
                    behavior: FStarOverScrollBehavior(),
                    child: ListView.separated(
                      controller: scrollController,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: Text('${index + 1}'),
                          title: Text(messages[index]),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider();
                      },
                      itemCount: messages.length,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        btnOk: OutlinedButton(
          onPressed: () async {
            Navigator.pop(context);
            if (changelog.downloadUrl == null) {
              EasyLoading.showError('下载链接为空');
              return;
            }
            var file =
                await downloadAndroid(changelog.downloadUrl.trim(), context);
            if (file == null) return;
            if (file.path.isEmpty) {
              Log.logger.e('apk path is empty');
              return;
            }
            InstallPlugin.installApk(file.path, 'com.mdreamfever.fstar')
                .then((result) {
              Log.logger.i('install apk $result');
            }).catchError((error) {
              Log.logger.e('install apk error: $error');
            });
          },
          child: Text('应用内下载'),
        ),
        btnCancel: OutlinedButton(
          onPressed: () async {
            Navigator.pop(context);
            if (await canLaunch(changelog.downloadUrl)) {
              await launch(changelog.downloadUrl);
            } else {
              EasyLoading.showToast('打开浏览器遇到问题');
            }
          },
          child: Text('浏览器下载'),
        ),
      ).show();
    }
  } catch (e) {
    Log.logger.e(e.toString());
  }
  return newVersion;
}

Future<File> downloadAndroid(String url, BuildContext context) async {
  /// 创建存储文件
  Directory storageDir = await getExternalStorageDirectory();
  String storagePath = storageDir.path;
  File file = new File('$storagePath/fstar.apk');
  if (file.existsSync()) {
    file.deleteSync();
  }
  var cancelToken = CancelToken();
  bool isDownloading = false;
  bool isComplete = false;
  double percent = 0;
  await AwesomeDialog(
    context: context,
    dialogType: DialogType.NO_HEADER,
    dismissOnTouchOutside: false,
    body: Column(
      children: [
        Center(
          child: Text(
            '正在下载',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              if (!isDownloading) {
                isDownloading = true;
                Dio().get(url, onReceiveProgress: (count, total) {
                  setState(() {
                    percent = count / total;
                  });
                },
                    options: Options(
                      responseType: ResponseType.bytes,
                      followRedirects: false,
                    ),
                    cancelToken: cancelToken).then((response) {
                  if (!file.existsSync()) {
                    file.createSync();
                    file.writeAsBytesSync(response.data);
                    isComplete = true;
                    Navigator.pop(context);
                  }
                }).catchError(print);
              }
              return NeumorphicProgress(
                percent: percent,
              );
            },
          ),
        ),
      ],
    ),
    onDissmissCallback: () {
      if (!isComplete) {
        cancelToken.cancel();
      }
    },
    btnCancel: Container(
      height: 30,
      child: SizedBox.expand(
        child: ElevatedButton(
          child: Text(
            '取消',
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    ),
  ).show();
  return file;
}
