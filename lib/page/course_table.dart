import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fstar/model/course_data.dart';
import 'package:fstar/model/course_map.dart';
import 'package:fstar/model/identity_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/table_mode_enum.dart';
import 'package:fstar/page/time_table.dart';
import 'package:fstar/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CourseTable extends StatelessWidget {
  final int index;

  const CourseTable({Key key, @required this.index})
      : assert(index != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Selector<SettingsData, Tuple6<bool, String, double, int, bool, bool>>(
          selector: (_, data) => Tuple6(
            data.showCourseBackground,
            data.courseBackgroundPath,
            data.initHeight,
            data.initSelectionNumber,
            data.showSaturday,
            data.showSunday,
          ),
          builder: (BuildContext context, value, Widget child) => Container(
            decoration: _buildCourseDecoration(
              value,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildEachWeek(
                context,
                index + 1, //注意index从0开始
                value.item3,
                value.item4,
                value.item5,
                value.item6,
              ),
            ),
          ),
        ),
        Container(
          child: Selector<CourseMap, String>(
            selector: (_, data) => data.remark,
            builder: (BuildContext context, remark, Widget child) => Padding(
              padding: remark.isEmpty ? EdgeInsets.zero : EdgeInsets.all(8.0),
              child: Text(
                '$remark',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          color: isDarkMode(context)
              ? Theme.of(context).primaryColor
              : Colors.white,
        )
      ],
    );
  }

  _buildColumnStyleB(
      {@required BuildContext context,
      @required int column,
      @required int currentWeek,
      @required double initHeight,
      @required int initSelectionNumber}) {
    return Selector2<
        CourseMap,
        SettingsData,
        Tuple7<Map<int, List<CourseData>>, bool, double, double, double, double,
            bool>>(
      selector: (_, courseList, settings) => Tuple7(
          courseList.dataMap,
          settings.onlyShowThisWeek,
          settings.courseCircular,
          settings.courseMargin,
          settings.coursePadding,
          settings.courseFontSize,
          settings.shadow),
      shouldRebuild: (previous, next) => true,
      builder: (BuildContext context, value, Widget child) {
        var courseData = value.item1;
        var onlyShowThisWeek = value.item2;
        var oneColumnData = courseData[column]
            .where((element) =>
                onlyShowThisWeek ? element.week.contains(currentWeek) : true)
            .toList();
        var oneColumnCourse = <Container>[];
        var courseFlagMap = List.generate(initSelectionNumber, (index) => -1);
        var sortedOneColumnData = _sortCourseData(
            courseData: oneColumnData, currentWeek: currentWeek);
        for (int i = 0; i < sortedOneColumnData.length; ++i) {
          var element = sortedOneColumnData[i];
          for (int row = element.row;
              row < element.row + element.rowSpan;
              ++row) {
            if (row <= initSelectionNumber) {
              courseFlagMap[row - 1] = i;
            }
          }
        }
        for (int i = 0; i < courseFlagMap.length; ++i) {
          var flag = courseFlagMap[i];
          if (flag == -1) {
            oneColumnCourse.add(_buildFixedBox(initHeight));
          } else {
            var trueRowSpan = 1;
            while (i < courseFlagMap.length - 1) {
              if (flag == courseFlagMap[i + 1]) {
                ++trueRowSpan;
                ++i;
              } else {
                break;
              }
            }
            var one = sortedOneColumnData[flag];
            oneColumnCourse.add(Container(
                height: trueRowSpan * initHeight,
                child: _buildCourse(
                    course: one,
                    currentWeek: currentWeek,
                    courseCircular: value.item3,
                    courseMargin: value.item4,
                    coursePadding: value.item5,
                    courseFontSize: value.item6,
                    shadow: value.item7)));
          }
        }
        return Stack(
          children: [
            Column(
              children: oneColumnCourse,
            ),
            _buildEventLayerColumn(
                context: context,
                initSelectionNumber: initSelectionNumber,
                currentWeek: currentWeek,
                column: column,
                initHeight: initHeight,
                allColumnCourses: sortedOneColumnData)
          ],
        );
      },
    );
  }

// 在每个Column的顶层覆盖一层透明的事件层，这里不是在每个课表上添加GestureDetector来展示
// 课表的详情页，而是通过点击的位置来查找一列的课表数据中对应的课程数据
  _buildEventLayerColumn(
      {@required BuildContext context,
      @required int initSelectionNumber,
      @required int currentWeek,
      @required int column,
      @required double initHeight,
      @required List<CourseData> allColumnCourses}) {
    var eventLayerColumn = List.generate(initSelectionNumber, (row) {
      final eventKey = GlobalKey();
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          var courses = _findPressedCourse(allColumnCourses, row);
          if (courses.isNotEmpty) {
            courses.length > 1
                ? _showCourseList(
                    context: context,
                    stackCourse: courses,
                    currentWeek: currentWeek)
                : _showCourseDetails(context, courses[0]);
          }
        },
        onLongPressStart: (details) {
          var courses = _findPressedCourse(allColumnCourses, row);
          if (courses.isNotEmpty) {
            HapticFeedback.heavyImpact();
            if (courses.length > 1) {
              var popUp = PopupMenuButton(
                itemBuilder: (context) => courses
                    .map(
                      (e) => PopupMenuItem(
                        child: Text(e.name),
                        value: e,
                      ),
                    )
                    .toList(),
                onSelected: (CourseData value) {
                  showModalBottomCourseEditSheet(context, courseData: value);
                },
              );
              RenderBox renderBox = eventKey.currentContext.findRenderObject();
              var offset = renderBox.localToGlobal(Offset(0.0, 0.0));
              final RelativeRect position = RelativeRect.fromLTRB(
                  details.globalPosition.dx, //取点击位置坐弹出x坐标
                  offset.dy, //取text高度做弹出y坐标（这样弹出就不会遮挡文本）
                  details.globalPosition.dx,
                  offset.dy);
              showMenu(
                context: context,
                items: popUp.itemBuilder(context),
                position: position,
              ).then((value) {
                if (value == null) {
                  if (popUp.onCanceled != null) {
                    popUp.onCanceled();
                  }
                } else {
                  if (popUp.onSelected != null) {
                    popUp.onSelected(value);
                  }
                }
              });
            } else {
              showModalBottomCourseEditSheet(context,
                  courseData: courses.first);
            }
          }
        },
        child: Container(
          key: eventKey,
          child: _buildFixedBox(initHeight),
        ),
      );
    });
    return Column(
      children: eventLayerColumn,
    );
  }

  _buildColumnStyleC(
      {@required BuildContext context,
      @required int column,
      @required int currentWeek,
      @required double initHeight,
      @required int initSelectionNumber}) {
    return Selector2<
        CourseMap,
        SettingsData,
        Tuple7<Map<int, List<CourseData>>, bool, double, double, double, double,
            bool>>(
      selector: (_, courseMap, settings) => Tuple7(
          courseMap.dataMap,
          settings.onlyShowThisWeek,
          settings.courseCircular,
          settings.courseMargin,
          settings.coursePadding,
          settings.courseFontSize,
          settings.shadow),
      shouldRebuild: (previous, next) => true,
      builder: (BuildContext context, value, Widget child) {
        var courseData = value.item1;
        var onlyShowThisWeek = value.item2;
        var oneColumnData = courseData[column]
            .where((element) =>
                onlyShowThisWeek ? element.week.contains(currentWeek) : true)
            .toList();
        var sortedOneColumnData = _sortCourseData(
            courseData: oneColumnData, currentWeek: currentWeek);
        var backgroundLayerColumn = _buildBoxBackgroundLayer(
            initSelectionNumber: initSelectionNumber,
            initHeight: initHeight,
            courseMargin: value.item4,
            coursePadding: value.item5,
            courseCircular: value.item3);
        var columnWidgetList = <Column>[
          Column(
            children: backgroundLayerColumn,
          )
        ];
        sortedOneColumnData.forEach((one) {
          var widgetList = <Widget>[];
          for (int i = 1; i <= initSelectionNumber; ++i) {
            if (one.row == i &&
                one.row + one.rowSpan - 1 <= initSelectionNumber) {
              var rowSpan = one.rowSpan > 1 ? one.rowSpan : 1;
              if (one.row + one.rowSpan - 1 > initSelectionNumber) {
                rowSpan = initSelectionNumber;
              }
              widgetList.add(
                Container(
                  height: rowSpan * initHeight,
                  child: _buildCourse(
                      course: one,
                      currentWeek: currentWeek,
                      courseCircular: value.item3,
                      courseMargin: value.item4,
                      coursePadding: value.item5,
                      courseFontSize: value.item6,
                      shadow: value.item7),
                ),
              );
              i += one.rowSpan - 1; //-1是因为for循环还要+1
            } else {
              widgetList.add(_buildFixedBox(initHeight));
            }
          }
          columnWidgetList.add(Column(
            children: widgetList,
          ));
        });
        columnWidgetList.add(_buildEventLayerColumn(
            context: context,
            initSelectionNumber: initSelectionNumber,
            currentWeek: currentWeek,
            column: column,
            initHeight: initHeight,
            allColumnCourses: sortedOneColumnData));
        return Stack(
          children: columnWidgetList,
        );
      },
    );
  }

//渲染每一周的课程信息
  _buildEachWeek(BuildContext context, int currentWeek, double initHeight,
      int initSelectionNumber, bool saturday, bool sunday) {
    return List.generate(8, (index) => index)
        .where((index) =>
            index >= 0 && index <= 5 ||
            saturday && index == 6 ||
            sunday && index == 7)
        .map<Widget>((column) {
      if (column == 0) {
        return _buildTableSidebar(
            initSelectionNumber: initSelectionNumber, initHeight: initHeight);
      } else {
        return _buildCourseColumn(
            column: column,
            currentWeek: currentWeek,
            initHeight: initHeight,
            initSelectionNumber: initSelectionNumber);
      }
    }).toList();
  }

  void _showCourseList(
      {@required BuildContext context,
      @required List<CourseData> stackCourse,
      @required int currentWeek}) {
    final size = MediaQuery.of(context).size;
    final reversed = stackCourse.reversed.toList();
    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      body: StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Container(
            height: size.height / 2,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    '多个课程',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(
                  thickness: 1.5,
                ),
                Expanded(
                  child: ReorderableListView(
                    header: Text(
                      '长按即可排序',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onReorder: (int oldIndex, int newIndex) {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      var child = reversed.removeAt(oldIndex);
                      reversed.insert(newIndex, child);
                      setState(() {});
                    },
                    children: reversed
                        .map(
                          (course) => Padding(
                            key: ValueKey(course),
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                _showCourseDetails(context, course);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _buildCourseColor(course, currentWeek),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 40,
                                child: SizedBox.expand(
                                  child: Center(
                                    child: Text(
                                      course.name,
                                      style: TextStyle(
                                        color: getReverseForegroundTextColor(
                                          _buildTextColor(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      btnOk: ElevatedButton(
        child: Text('确定'),
        onPressed: () {
          for (int i = reversed.length - 1; i >= 0; --i) {
            var oldCourse = reversed[i];
            context.read<CourseMap>()
              ..editCourse(
                  newCourse: oldCourse.copyWith(top: i), oldCourse: oldCourse)
              ..save();
          }
          Navigator.pop(context);
        },
      ),
    ).show();
  }

  void _showCourseDetails(BuildContext context, CourseData courseData) {
    final size = MediaQuery.of(context).size;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      body: Container(
        width: size.width / 4 * 3,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                courseData.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(
              thickness: 1.5,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: getSettingsData().identityType ==
                              IdentityType.undergraduate
                          ? "课程号："
                          : '班级：',
                      style: TextStyle(
                          color: _buildTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: courseData.id,
                      style: TextStyle(
                          color: _buildTextColor(context), fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            courseData.classroom.isNotEmpty
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "教室：",
                            style: TextStyle(
                                color: _buildTextColor(context),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: courseData.classroom,
                            style: TextStyle(
                                color: _buildTextColor(context), fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  )
                : SizedBox(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "周数：",
                      style: TextStyle(
                          color: _buildTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: weekList2RawWeek(courseData.week),
                      style: TextStyle(
                          color: _buildTextColor(context), fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "节数：",
                      style: TextStyle(
                          color: _buildTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          "星期${indexWeekToStringWeek(courseData.column)} 第${courseData.row}-${courseData.row + courseData.rowSpan - 1}节",
                      style: TextStyle(
                          color: _buildTextColor(context), fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "老师：",
                      style: TextStyle(
                          color: _buildTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: courseData.teacher,
                      style: TextStyle(
                          color: _buildTextColor(context), fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).show();
  }

  Color _buildTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black;
  }

  _buildColumnStyleA(
      {@required BuildContext context,
      @required int column,
      @required int currentWeek,
      @required double initHeight,
      @required int initSelectionNumber}) {
    return Selector2<
        CourseMap,
        SettingsData,
        Tuple7<Map<int, List<CourseData>>, bool, double, double, double, double,
            bool>>(
      selector: (_, courseMap, settings) => Tuple7(
          courseMap.dataMap,
          settings.onlyShowThisWeek,
          settings.courseCircular,
          settings.courseMargin,
          settings.coursePadding,
          settings.courseFontSize,
          settings.shadow),
      shouldRebuild: (previous, next) => true,
      builder: (BuildContext context, value, Widget child) {
        final courseData = value.item1;
        final onlyShowThisWeek = value.item2;
        final oneColumnData = courseData[column]
            .where((element) =>
                onlyShowThisWeek ? element.week.contains(currentWeek) : true)
            .toList();
        final sortedOneColumnData = _sortCourseData(
            courseData: oneColumnData, currentWeek: currentWeek);
        final columnWidgetList = <Column>[];
        sortedOneColumnData.forEach((one) {
          final widgetList = <Widget>[];
          for (int i = 1; i <= initSelectionNumber; ++i) {
            if (one.row == i &&
                one.row + one.rowSpan - 1 <= initSelectionNumber) {
              var rowSpan = one.rowSpan > 1 ? one.rowSpan : 1;
              if (one.row + one.rowSpan - 1 > initSelectionNumber) {
                rowSpan = initSelectionNumber;
              }
              widgetList.add(
                Container(
                  height: rowSpan * initHeight,
                  child: _buildCourse(
                      course: one,
                      currentWeek: currentWeek,
                      courseCircular: value.item3,
                      courseMargin: value.item4,
                      coursePadding: value.item5,
                      courseFontSize: value.item6,
                      shadow: value.item7),
                ),
              );
              i += one.rowSpan - 1; //-1是因为for循环还要+1
            } else {
              widgetList.add(_buildFixedBox(initHeight));
            }
          }
          columnWidgetList.add(Column(
            children: widgetList,
          ));
        });
        columnWidgetList.add(_buildEventLayerColumn(
            context: context,
            initSelectionNumber: initSelectionNumber,
            currentWeek: currentWeek,
            column: column,
            initHeight: initHeight,
            allColumnCourses: sortedOneColumnData));
        return Stack(
          children: columnWidgetList,
        );
      },
    );
  }

  _buildBoxBackgroundLayer(
      {@required int initSelectionNumber,
      @required double initHeight,
      @required double courseMargin,
      @required double coursePadding,
      @required double courseCircular}) {
    return List.generate(
      initSelectionNumber,
      (row) => Container(
        height: initHeight,
        child: SizedBox.expand(
          child: Selector<SettingsData, Color>(
            selector: (_, data) => data.boxColor,
            builder: (_, value, __) => Container(
              margin: EdgeInsets.all(courseMargin),
              padding: EdgeInsets.all(coursePadding),
              decoration: BoxDecoration(
                  color: value,
                  borderRadius: BorderRadius.circular(courseCircular),
                  border: Border.all(width: .2, color: Colors.grey)),
            ),
          ),
        ),
      ),
    );
  }

//占位用的box
  _buildFixedBox(double initHeight) => Container(
        height: initHeight,
        child: SizedBox.expand(),
      );

  Color _buildCourseColor(CourseData courseData, int currentWeek) {
    if (!courseData.week.contains(currentWeek)) {
      return Colors.grey[400];
    }
    if (courseData.customColor != null) {
      return courseData.customColor;
    } else {
      return courseData.defaultColor;
    }
  }

  _buildCourse(
          {@required CourseData course,
          @required int currentWeek,
          @required double courseCircular,
          @required double courseMargin,
          @required double coursePadding,
          @required double courseFontSize,
          @required bool shadow}) =>
      SizedBox.expand(
        child: AnimatedContainer(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(courseCircular),
            color: _buildCourseColor(course, currentWeek),
            boxShadow: shadow
                ? [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(2.0, 3.0), //阴影xy轴偏移量
                        blurRadius: 6.0, //阴影模糊程度
                        spreadRadius: 0.8 //阴影扩散程度
                        )
                  ]
                : null,
          ),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          margin: EdgeInsets.all(courseMargin),
          padding: EdgeInsets.all(coursePadding),
          child: Align(
            alignment: Alignment.center,
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: course.name,
                  style: TextStyle(
                    fontSize: courseFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: course.classroom == "" ? "" : "@${course.classroom}",
                  style: TextStyle(fontSize: courseFontSize),
                ),
              ], style: TextStyle(color: Colors.white)),
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
            ),
          ),
        ),
      );

  List<CourseData> _findPressedCourse(List<CourseData> c, int row) => c
      .where((element) =>
          element.row <= row + 1 &&
          element.row + element.rowSpan - 1 >= row + 1)
      .toList();

  _buildCourseDecoration(Tuple6<bool, String, double, int, bool, bool> value) {
    //显示课表背景
    if (value.item1) {
      return BoxDecoration(
        image: DecorationImage(
          //如果有自定背景使用自定背景，没有则使用自带背景
          image: value.item2 == null
              ? Image.asset(
                  'images/2.jpg',
                  filterQuality: FilterQuality.high,
                ).image
              : Image.file(
                  File(value.item2),
                  filterQuality: FilterQuality.high,
                ).image,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return null;
    }
  }

  _buildTableSidebar(
      {@required int initSelectionNumber, @required double initHeight}) {
    return Expanded(
      child: Selector<SettingsData, Tuple2<List<String>, Color>>(
        selector: (_, data) =>
            Tuple2(data.timeTable, data.tableBackgroundColor),
        builder: (BuildContext context, tuple, Widget child) {
          // var value = List.from(tuple.item1);
          // var len = initSelectionNumber - value.length;
          // for (int i = 0; i < len; ++i) {
          //   value.add('0:0 0:0');
          // }
          return GestureDetector(
            onTap: () {
              pushPage(context, TimeTable());
            },
            child: Container(
              color: isDarkMode(context)
                  ? Theme.of(context).primaryColor
                  : tuple.item2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  initSelectionNumber,
                  (index) {
                    final data = tuple.item1[index].split(' ');
                    final begin = data[0];
                    final end = data[1];
                    return Container(
                      height: initHeight,
                      child: SizedBox.expand(
                        child: Center(
                          child: Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: '$begin\n',
                                style: TextStyle(fontSize: 35.sp),
                              ),
                              TextSpan(
                                text: '${index + 1}\n',
                                style: TextStyle(
                                  fontSize: 55.sp,
                                ),
                              ),
                              TextSpan(
                                text: '$end',
                                style: TextStyle(fontSize: 35.sp),
                              ),
                            ]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _buildCourseColumn(
      {@required int column,
      @required int currentWeek,
      @required double initHeight,
      @required int initSelectionNumber}) {
    return Expanded(
      flex: 2,
      child: Selector<SettingsData, TableMode>(
        selector: (_, data) => data.tableMode,
        builder: (BuildContext context, value, Widget child) {
          switch (value) {
            case TableMode.A: //层叠效果
              return _buildColumnStyleA(
                  context: context,
                  column: column,
                  currentWeek: currentWeek,
                  initHeight: initHeight,
                  initSelectionNumber: initSelectionNumber);
              break;
            case TableMode.B:
              return _buildColumnStyleB(
                  context: context,
                  column: column,
                  currentWeek: currentWeek,
                  initHeight: initHeight,
                  initSelectionNumber: initSelectionNumber);
              break;
            case TableMode.C: //格子效果
              return _buildColumnStyleC(
                  context: context,
                  column: column,
                  currentWeek: currentWeek,
                  initHeight: initHeight,
                  initSelectionNumber: initSelectionNumber);
              break;
            default:
              throw UnimplementedError();
          }
        },
      ),
    );
  }

  List<CourseData> _sortCourseData(
      {@required List<CourseData> courseData, @required int currentWeek}) {
    //节数多的放前面
    return courseData
      ..sort((a, b) {
        if (a.rowSpan > b.rowSpan) {
          return -1;
        } else if (a.rowSpan == b.rowSpan) {
          return 0;
        } else {
          return 1;
        }
      })
      //不是本周的放前面
      ..sort((a, b) {
        if (a.week.contains(currentWeek) && !b.week.contains(currentWeek)) {
          return 1;
        } else if (!a.week.contains(currentWeek) &&
            b.week.contains(currentWeek)) {
          return -1;
        } else {
          return 0;
        }
      })
      //按课表层叠优先级排序
      ..sort((a, b) {
        return b.top - a.top;
      });
  }
}
