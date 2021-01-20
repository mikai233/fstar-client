import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fstar/model/application.dart';
import 'package:fstar/model/choose_week_header_status.dart';
import 'package:fstar/model/course_map.dart';
import 'package:fstar/model/fstar_mode_enum.dart';
import 'package:fstar/model/navigation_index_data.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/time_array_data.dart';
import 'package:fstar/model/week_index_data.dart';
import 'package:fstar/page/course_page.dart';
import 'package:fstar/page/query_page.dart';
import 'package:fstar/page/tool_page.dart';
import 'package:fstar/page/user_drawer.dart';
import 'package:fstar/utils/fstar_scroll_behavior.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum ActionType {
  ADD,
  REFRESH,
  CHOOSE,
}

extension actionName on ActionType {
  String name() {
    var actionName = '';
    switch (this.index) {
      case 0:
        actionName = '添加课程';
        break;
      case 1:
        actionName = '刷新课表';
        break;
      case 2:
        actionName = '选择学期';
        break;
      default:
        throw UnimplementedError();
    }
    return actionName;
  }
}

class FStarHomePage extends StatefulWidget {
  FStarHomePage({Key key}) : super(key: key);

  @override
  State createState() => _FStarHomePageState();
}

class _FStarHomePageState extends State<FStarHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _lastPressedAt; //上次点击时间
  TabController _tabController;
  AnimationController _rotateController;
  final _smartRefreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _rotateController = AnimationController(
        duration: Duration(
          milliseconds: 300,
        ),
        vsync: this);
    CurvedAnimation(parent: _rotateController, curve: Curves.easeOutQuad);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        updateVitality(context);
        final settings = context.read<SettingsData>();
        if (settings.isNewUser) {
          showPrivacyPolicy(context);
        } else {
          if (settings.autoCheckUpdate) {
            if (settings.dayFlag == null ||
                DateTime.now().difference(settings.dayFlag) >
                    Duration(days: 1)) {
              showCheckVersion(context);
              settings
                ..dayFlag = DateTime.now()
                ..save();
            }
          }
          showMessage(context);
        }
        if (!settings.refreshTablePerDay) {
          return;
        }
        final user = getUserData();
        if (user.jwAccount == null || user.jwPassword == null) {
          return;
        }
        if (settings.lastRefreshAt == null ||
            DateTime.now().difference(settings.lastRefreshAt) >
                Duration(days: 1)) {
          await Future.delayed(Duration(seconds: 2));
          final course = await Application.getCourse();
          context.read<CourseMap>()..addCourseByList(course, true);
          Log.logger.i('课表自动更新完成');
          settings
            ..lastRefreshAt = DateTime.now()
            ..save();
        }
      } catch (e) {
        Log.logger.e(e.toString());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _rotateController.dispose();
    _smartRefreshController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Log.logger.i('resumed');
        final settings = getSettingsData();
        if (settings.autoCheckUpdate) {
          if (settings.dayFlag == null ||
              DateTime.now().difference(settings.dayFlag) > Duration(days: 1)) {
            showCheckVersion(context);
            settings
              ..dayFlag = DateTime.now()
              ..save();
          }
        }
        showMessage(context);
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeekIndexData()),
        ChangeNotifierProvider(create: (_) => NavigationIndexData()),
        ChangeNotifierProvider(create: (_) => TimeArrayData()),
        ChangeNotifierProvider(create: (_) => ChooseWeekHeaderStatus()),
        Provider.value(value: _smartRefreshController),
      ],
      builder: (BuildContext context, Widget child) => WillPopScope(
        onWillPop: _onWillPop,
        child: Selector<SettingsData, FStarMode>(
          selector: (_, data) => data.fStarMode,
          builder: (BuildContext context, value, Widget child) {
            return Scaffold(
              key: _scaffoldKey,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(45.0),
                child: AppBar(
                  centerTitle: true,
                  title: _buildTitle(),
                  actions: _buildActions(),
                ),
              ),
              drawer: UserDrawer(),
              bottomNavigationBar: _buildBottomNavigationBar(value),
              body: _buildBody(value),
            );
          },
        ),
      ),
    );
  }

  _buildBody(FStarMode fStarMode) {
    switch (fStarMode) {
      case FStarMode.JUST:
        return TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [QueryPage(), CoursePage(), ToolPage()],
        );
        break;
      case FStarMode.ThirdParty:
        return CoursePage();
        break;
    }
  }

  Future<bool> _onWillPop() async {
    if (_scaffoldKey.currentState.isDrawerOpen) {
      Navigator.pop(context);
      return false;
    }
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
      //两次点击间隔超过1秒则重新计时
      EasyLoading.showToast(
        '再按一次退出',
      );
      _lastPressedAt = DateTime.now();
      return false;
    }
    return true;
  }

  List<PopupMenuItem<ActionType>> _buildPopupItem() {
    return List.generate(
      ActionType.values.length,
      (index) => PopupMenuItem(
        value: ActionType.values[index],
        child: Text(ActionType.values[index].name()),
      ),
    );
  }

  _buildBottomNavigationBar(FStarMode fStarMode) {
    switch (fStarMode) {
      case FStarMode.JUST:
        return Consumer<NavigationIndexData>(
          builder: (BuildContext context, value, Widget child) {
            return BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: '查询',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.calendar_today,
                  ),
                  label: '课表',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.build),
                  label: '工具',
                )
              ],
              currentIndex: value.index,
              onTap: (index) {
                value.index = index;
                _tabController.index = index;
              },
            );
          },
        );
        break;
      case FStarMode.ThirdParty:
        // TODO: Handle this case.
        break;
    }
  }

  _buildTitle() {
    return Consumer3<NavigationIndexData, WeekIndexData, TimeArrayData>(
      builder:
          (BuildContext context, navigation, week, timeArray, Widget child) {
        if (navigation.index == 1) {
          return Row(
            children: [
              GestureDetector(
                child: Text(
                  sameWeek(timeArray.array[week.index * 7], DateTime.now())
                      ? '第${week.index + 1}周'
                      : '第${week.index + 1}周(非本周)',
                ),
                onTap: () {
                  var status = context.read<ChooseWeekHeaderStatus>();
                  status.show = !status.show;
                  if (status.show) {
                    _rotateController.forward();
                  } else {
                    _rotateController.reverse();
                  }
                },
              ),
              AnimatedBuilder(
                animation: _rotateController,
                builder: (BuildContext context, Widget child) {
                  return Transform.rotate(
                    angle: _rotateController.value * pi,
                    child: child,
                  );
                },
                child: Icon(Icons.arrow_drop_down_outlined),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          );
        } else {
          return Text('繁星');
        }
      },
    );
  }

  _buildActions() {
    return [
      Consumer<NavigationIndexData>(
        builder: (BuildContext context, value, Widget child) => Offstage(
          offstage: value.index != 1,
          child: PopupMenuButton<ActionType>(
            onSelected: (value) async {
              switch (value) {
                case ActionType.ADD:
                  showModalBottomCourseEditSheet(context);
                  break;
                case ActionType.REFRESH:
                  _smartRefreshController.requestRefresh();
                  break;
                case ActionType.CHOOSE:
                  final settings = getSettingsData();
                  final controller = ScrollController();
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.NO_HEADER,
                    onDissmissCallback: () {
                      controller.dispose();
                    },
                    body: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Center(
                              child: Text(
                                '选择学期',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1.5,
                          ),
                          Expanded(
                            child: Scrollbar(
                              isAlwaysShown: true,
                              controller: controller,
                              child: ScrollConfiguration(
                                behavior: FStarOverScrollBehavior(),
                                child: ListView.builder(
                                  controller: controller,
                                  itemCount: settings.semesterList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      child: ListTile(
                                        title: Center(
                                          child: Text(
                                            settings.semesterList[index],
                                            style: TextStyle(
                                              color: (settings
                                                          .currentSemester ==
                                                      settings
                                                          .semesterList[index]
                                                  ? (isDarkMode(context)
                                                      ? Theme.of(context)
                                                          .accentColor
                                                      : Theme.of(context)
                                                          .primaryColor)
                                                  : (isDarkMode(context)
                                                      ? Colors.white
                                                      : Colors.black)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        final settings =
                                            context.read<SettingsData>();
                                        settings
                                          ..currentSemester =
                                              settings.semesterList[index];
                                        _smartRefreshController
                                            .requestRefresh();
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    btnCancel: ElevatedButton(
                      // color: Theme.of(context).primaryColor,
                      child: Text(
                        '取消',
                        // style: TextStyle(
                        //   color: Utils.getReverseForegroundColor(context),
                        // ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ).show();
                  break;
              }
            },
            icon: const Icon(Icons.more_horiz),
            itemBuilder: (context) {
              return _buildPopupItem();
            },
            tooltip: '选项',
          ),
        ),
      )
    ];
  }
}
