import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:fstar/model/application.dart';
import 'package:fstar/model/choose_week_header_status.dart';
import 'package:fstar/model/course_map.dart';
import 'package:fstar/model/date_today_data.dart';
import 'package:fstar/model/fstar_mode_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/time_array_data.dart';
import 'package:fstar/model/week_index_data.dart';
import 'package:fstar/page/course_table.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:fstar/widget/week_header.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tuple/tuple.dart';

class CoursePage extends StatefulWidget {
  @override
  State createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final _height = 70.0;
  final _weekListScrollController = ScrollController();

  final _pageController = PageController(initialPage: getCurrentWeek());
  final _duration = Duration(milliseconds: 500);
  final _curve = Curves.easeOutQuad;

  final _buttonWidth = 50.0;
  final _itemWidth = 70.0;
  var _isTapItem = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    _weekListScrollController.dispose();
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Log.logger.i('resumed');
        int currentWeek = getCurrentWeek();
        if (currentWeek != _pageController.page.toInt()) {
          _pageController.animateToPage(currentWeek,
              duration: _duration, curve: _curve);
        }
        break;
      case AppLifecycleState.inactive:
        Log.logger.i('inactive');
        break;
      case AppLifecycleState.paused:
        Log.logger.i('paused');
        break;
      case AppLifecycleState.detached:
        Log.logger.i('detached');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Selector3<ChooseWeekHeaderStatus, SettingsData, RefreshController,
        Tuple4<bool, int, bool, RefreshController>>(
      selector: (BuildContext context, status, settings, controller) => Tuple4(
          status.show,
          settings.semesterWeek,
          settings.tableScrollable,
          controller),
      builder: (BuildContext context, data, Widget child) {
        _animateToCurrentWeekItem(data.item1);
        return SmartRefresher(
          header: WaterDropHeader(),
          controller: data.item4,
          onRefresh: _onRefresh,
          child: Column(
            children: [
              AnimatedContainer(
                height: data.item1 ? _height : 0,
                duration: Duration(milliseconds: 475),
                curve: Curves.easeOutQuad,
                child: Row(
                  children: <Widget>[
                    _buildButton(),
                    _buildWeekList(),
                  ],
                ),
              ),
              WeekHeader(),
              Divider(
                height: 1,
                color: Colors.black26,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: data.item3 ? null : NeverScrollableScrollPhysics(),
                  itemCount: data.item2,
                  itemBuilder: (BuildContext context, int index) {
                    return Selector<SettingsData, Color>(
                      selector: (_, data) => data.tableBackgroundColor,
                      builder: (_, value, __) => Container(
                        child: CourseTable(index: index),
                        color: value,
                      ),
                    );
                  },
                  onPageChanged: (page) =>
                      _onPageChanged(page: page, show: data.item3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildButton() {
    return GestureDetector(
      child: Container(
        width: _buttonWidth,
        height: double.infinity,
        color: isDarkMode(context)
            ? Theme.of(context).primaryColor
            : Color.fromRGBO(250, 250, 250, 1),
        child: Center(
          child: Text(
            '修改起始周',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      onTap: _onTap,
    );
  }

  _buildWeekList() {
    return Expanded(
      child: Selector<SettingsData, int>(
        selector: (BuildContext context, data) => data.semesterWeek,
        builder: (BuildContext context, semesterWeek, Widget child) {
          return ListView.builder(
            controller: _weekListScrollController,
            scrollDirection: Axis.horizontal,
            cacheExtent: 20,
            itemBuilder: (context, index) {
              return Container(
                width: _itemWidth,
                // color: Color(0x339FA5B6),
                child: Consumer3(
                  builder: (BuildContext context,
                      WeekIndexData weekIndex,
                      DateTodayData dateToday,
                      TimeArrayData timeArray,
                      Widget child) {
                    return GestureDetector(
                      onTap: () {
                        _isTapItem = true;
                        _pageController.animateToPage(index,
                            duration: _duration, curve: _curve);
                        context.read<WeekIndexData>().index = index;
                        Future.delayed(_duration, () {
                          _isTapItem = false;
                        });
                      },
                      child: AnimatedContainer(
                        // width: _itemWidth,
                        decoration: BoxDecoration(
                            color: sameWeek(
                                    dateToday.now, timeArray.array[index * 7])
                                ? Theme.of(context).primaryColor
                                : ((weekIndex.index == index
                                    ? Theme.of(context).backgroundColor
                                    : Color.fromRGBO(252, 252, 252, 1))),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(1, 1),
                                  spreadRadius: .1,
                                  blurRadius: .5)
                            ]),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        duration: Duration(milliseconds: 375),
                        child: Center(
                          child: Text(
                            '第${index + 1}周',
                            style: TextStyle(
                                fontSize: 14,
                                color: sameWeek(dateToday.now,
                                        timeArray.array[index * 7])
                                    ? getReverseForegroundColor(context)
                                    : Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            itemCount: semesterWeek,
          );
        },
      ),
    );
  }

  void _onRefresh() async {
    final controller = context.read<RefreshController>();
    final settings = getSettingsData();
    if (settings.fStarMode == FStarMode.ThirdParty) {
      controller.refreshCompleted();
      return;
    }
    final user = getUserData();
    if (user.jwAccount == null || user.jwPassword == null) {
      EasyLoading.showToast('没有验证教务系统账号');
      controller.refreshFailed();
      return;
    }
    try {
      final course = await Application.getCourse();
      context.read<CourseMap>()
        ..clearCourse()
        ..addCourseByList(course)
        ..remark = Application.courseParser.remark
        ..save();
      context.read<SettingsData>()
        ..semesterList = Application.courseParser.semesters
        ..save();
      await Future.delayed(Duration(milliseconds: 200));
      if (course.isEmpty) {
        EasyLoading.showToast('没有获取到该学期课表');
      } else {
        EasyLoading.showToast('课表获取成功');
      }
      controller.refreshCompleted();
    } catch (e) {
      controller.refreshFailed();
      Log.logger.e(e.toString());
      EasyLoading.showError(e.toString());
    }
  }

//选择周数组件展开时把当前周滚动到视野当中
  void _animateToCurrentWeekItem(bool show) {
    if (show) {
      var currentWeek = getCurrentWeek();
      var width = MediaQuery.of(context).size.width;
      _weekListScrollController.animateTo(
          ((currentWeek + 1) * _itemWidth - width / 2),
          duration: _duration,
          curve: _curve);
    }
  }

  void _animateToScrollWeekItem(int scrollWeek) {
    var width = MediaQuery.of(context).size.width;
    _weekListScrollController.animateTo(
        ((scrollWeek + 1) * _itemWidth - width / 2),
        duration: _duration,
        curve: _curve);
  }

  _onPageChanged({@required int page, @required bool show}) {
    if (!_isTapItem) {
      var weekIndexData = context.read<WeekIndexData>();
      if (show) {
        _animateToScrollWeekItem(page);
      }
      weekIndexData.index = page;
    }
  }

  Future<void> _onTap() async {
    DateTime beginTime = await showRoundedDatePicker(
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
      context: context,
      initialDate: getBeginTime(),
      initialDatePickerMode: DatePickerMode.day,
      theme: Theme.of(context),
    );
    if (beginTime != null) {
      beginTime = reviseTime(beginTime); //校正时间到选择周的周一
      context.read<SettingsData>()
        ..beginTime = beginTime
        ..save();
      context.read<TimeArrayData>().array =
          generate(beginTime, context.read<SettingsData>().semesterWeek);
      if (beginTime.isBefore(DateTime.now())) {
        int week = getCurrentWeek();
        _pageController.animateToPage(week, duration: _duration, curve: _curve);
        context.read<WeekIndexData>().index = week;
        var width = MediaQuery.of(context).size.width;
        if ((week + 1) > ((width - _buttonWidth) / _itemWidth) / 2) {
          _weekListScrollController.animateTo(
              ((week + 1) * _itemWidth - width / 2),
              duration: _duration,
              curve: _curve);
        } else {
          _weekListScrollController.animateTo(0,
              duration: _duration, curve: _curve);
        }
      } else {
        _pageController.animateToPage(0, duration: _duration, curve: _curve);
        context.read<WeekIndexData>().index = 0;
        _weekListScrollController.animateTo(0,
            duration: _duration, curve: _curve);
      }
    }
  }

  @override
  bool get wantKeepAlive {
    return true;
  }
}
