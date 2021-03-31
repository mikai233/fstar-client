import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fstar/model/application.dart';
import 'package:fstar/model/box_name.dart';
import 'package:fstar/model/course_map.dart';
import 'package:fstar/model/identity_enum.dart';
import 'package:fstar/model/score_display_mode_enum.dart';
import 'package:fstar/model/score_list.dart';
import 'package:fstar/model/score_query_mode_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/system_mode_enum.dart';
import 'package:fstar/page/fstar_webview.dart';
import 'package:fstar/page/score_page.dart';
import 'package:fstar/page/sport_score_page.dart';
import 'package:fstar/utils/FStarNet.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/parser.dart';
import 'package:fstar/utils/requester.dart';
import 'package:fstar/utils/utils.dart';
import 'package:fstar/widget/timer_count_down_button.dart';
import 'package:just/just.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QueryPage extends StatefulWidget {
  @override
  State createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _scoreList = getBoxData<ScoreList>(BoxName.scoreBox);
  final _scoreScrollController = ScrollController();
  final _scrollController = ScrollController();
  TabController _tabController;
  final _morningController = RefreshController(initialRefresh: true);
  final _clubController = RefreshController(initialRefresh: true);
  List<String> _morningItem = [];
  String _morningRemark = '';
  List<String> _clubItem = [];
  String _clubRemark = '';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Selector<SettingsData, IdentityType>(
      selector: (BuildContext context, settings) => settings.identityType,
      builder: (BuildContext context, data, Widget child) {
        switch (data) {
          case IdentityType.undergraduate:
            return MultiProvider(
              providers: [ChangeNotifierProvider.value(value: _scoreList)],
              builder: (BuildContext context, Widget child) {
                return Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(
                          text: '成绩',
                        ),
                        Tab(
                          text: '早操',
                        ),
                        Tab(
                          text: '俱乐部',
                        )
                      ],
                      controller: _tabController,
                      labelColor:
                          isDarkMode(context) ? Colors.white : Colors.black,
                    ),
                    Expanded(
                      child: TabBarView(controller: _tabController, children: [
                        Consumer<ScoreList>(builder:
                            (BuildContext context, score, Widget child) {
                          return Column(
                            children: [
                              Expanded(
                                child: Scrollbar(
                                  child: ListView.separated(
                                    itemCount: score.list.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final item = score.list[index];
                                      return ListTile(
                                        leading: Text(
                                          '${index + 1}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        onTap: () {
                                          showScoreDetails(context, item);
                                        },
                                        subtitle: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              child: Text(
                                                item.name,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: isDarkMode(context)
                                                        ? Colors.white
                                                        : Colors.black),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              child: Text(
                                                item.score,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: isDarkMode(context)
                                                        ? Colors.white
                                                        : Colors.black),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Divider();
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        final settings = getSettingsData();
                                        final user = getUserData();
                                        if (user.jwAccount == null ||
                                            user.jwPassword == null) {
                                          EasyLoading.showToast('没有验证教务系统账号');
                                          return;
                                        }
                                        switch (settings.scoreQueryMode) {
                                          case ScoreQueryMode.DEFAULT:
                                            _handleScoreQuery(context);
                                            break;
                                          case ScoreQueryMode.ALTERNATIVE:
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.INFO,
                                              body: Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(15),
                                                  child: Text.rich(
                                                    TextSpan(
                                                      text: "该入口仅在评教系统未开放的时候使用，"
                                                          "为不影响学校的评教秩序，"
                                                          "请在评教系统开放之后及时评教（工具页）并换回默认入口！",
                                                      children: [
                                                        TextSpan(
                                                          text: "注意：",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                "此入口计算的绩点可能不准确（有挂科的情况）"
                                                                "请以"),
                                                        TextSpan(
                                                          text: "默认入口",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        TextSpan(
                                                            text: "计算的绩点为准！")
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              btnOk: TimerCountDownButton(
                                                onPressed: () {
                                                  _handleScoreQuery(context);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ).show();
                                            break;
                                        }
                                      },
                                      child: Text('学业成绩'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final settings = getSettingsData();
                                        final user = getUserData();
                                        if (user.tyAccount == null ||
                                            user.tyPassword == null) {
                                          EasyLoading.showToast('没有验证体育账号');
                                          return;
                                        }
                                        switch (settings.systemMode) {
                                          case SystemMode.JUST:
                                            try {
                                              EasyLoading.show(
                                                  status: '正在请求成绩');
                                              await Future.delayed(
                                                  Duration(milliseconds: 375));
                                              final sportScoreRequester =
                                                  SportScoreRequester();
                                              final sportScoreParser =
                                                  SportScoreParser();
                                              final content =
                                                  await sportScoreRequester
                                                      .action();
                                              sportScoreParser.action(content);
                                              EasyLoading.dismiss();
                                              pushPage(
                                                  context,
                                                  SportScore(
                                                      scoreData:
                                                          sportScoreParser
                                                              .score));
                                            } catch (e) {
                                              Log.logger.e(e.toString());
                                              EasyLoading.showError(
                                                  e.toString());
                                            }
                                            break;
                                          case SystemMode.VPN:
                                            try {
                                              EasyLoading.show(
                                                  status: '正在请求成绩');
                                              await Future.delayed(
                                                  Duration(milliseconds: 375));
                                              final sportScoreRequester =
                                                  VPNSportScoreRequester();
                                              final sportScoreParser =
                                                  SportScoreParser();
                                              final content =
                                                  await sportScoreRequester
                                                      .action();
                                              sportScoreParser.action(content);
                                              EasyLoading.dismiss();
                                              pushPage(
                                                  context,
                                                  SportScore(
                                                      scoreData:
                                                          sportScoreParser
                                                              .score));
                                            } catch (e) {
                                              Log.logger.e(e.toString());
                                              EasyLoading.showError(
                                                  e.toString());
                                            }
                                            break;
                                          case SystemMode.VPN2:
                                            EasyLoading.showToast('待实现');
                                            // TODO: Handle this case.
                                            break;
                                          case SystemMode.CLOUD:
                                            EasyLoading.showToast('待实现');
                                            // TODO: Handle this case.
                                            break;
                                        }
                                      },
                                      child: Text('体育成绩'),
                                    ),
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                ),
                              )
                            ],
                          );
                        }),
                        SmartRefresher(
                          controller: _morningController,
                          header: WaterDropHeader(),
                          onRefresh: () async {
                            final settings = getSettingsData();
                            final user = getUserData();
                            if (user.tyAccount == null ||
                                user.tyPassword == null) {
                              EasyLoading.showToast('请先验证体育账号');
                              _morningController.refreshCompleted();
                              return;
                            }
                            try {
                              switch (settings.systemMode) {
                                case SystemMode.JUST:
                                  var content = await JUST.instance
                                      .getSportMorning(
                                          username: user.tyAccount,
                                          password: user.tyPassword);
                                  final parser = SportClubParser();
                                  parser.action(content);
                                  setState(() {
                                    _morningItem = parser.item;
                                    _morningRemark = parser.remark;
                                  });
                                  break;
                                case SystemMode.VPN:
                                  var content = await VPN.instance
                                      .getSportMorning(
                                          vpnUsername: user.vpnAccount,
                                          vpnPassword: user.vpnPassword,
                                          username: user.tyAccount,
                                          password: user.tyPassword);
                                  final parser = SportClubParser();
                                  parser.action(content);
                                  setState(() {
                                    _morningItem = parser.item;
                                    _morningRemark = parser.remark;
                                  });
                                  break;
                                case SystemMode.VPN2:
                                  // TODO: Handle this case.
                                  EasyLoading.showToast('未实现');
                                  break;
                                case SystemMode.CLOUD:
                                  // TODO: Handle this case.
                                  EasyLoading.showToast('未实现');
                                  break;
                              }
                              _morningController.refreshCompleted();
                            } catch (e) {
                              EasyLoading.showError(e.toString());
                              Log.logger.e(e.toString());
                              _morningController.refreshFailed();
                            }
                          },
                          child: CustomScrollView(
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  final items = _morningItem[index].split(' ');
                                  return Row(
                                    children: items.map((e) => Text(e)).toList()
                                      ..insert(0, Text('${index + 1}')),
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                  );
                                }, childCount: _morningItem.length),
                              ),
                              SliverPadding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 12.0)),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(_morningRemark),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: TextButton(
                                  onPressed: () async {
                                    try {
                                      final settings = getSettingsData();
                                      final user = getUserData();
                                      if (user.tyAccount == null ||
                                          user.tyPassword == null) {
                                        EasyLoading.showToast('请先验证体育账号');
                                        return;
                                      }
                                      switch (settings.systemMode) {
                                        case SystemMode.JUST:
                                          EasyLoading.show(status: '请稍等');
                                          var info = await JUST.instance
                                              .getSportMorningCookie(
                                                  username: user.tyAccount,
                                                  password: user.tyPassword);
                                          setCookie(
                                              cookie: info['cookie'],
                                              url: info['location']);
                                          pushPage(
                                              context,
                                              FStarWebView(
                                                  url: info['location']));
                                          break;
                                        case SystemMode.VPN:
                                          EasyLoading.show(status: '请稍等');
                                          var info = await VPN.instance
                                              .getSportMorningCookie(
                                                  vpnUsername: user.vpnAccount,
                                                  vpnPassword: user.vpnPassword,
                                                  username: user.tyAccount,
                                                  password: user.tyPassword);
                                          setCookie(
                                              cookie: info['cookie'],
                                              url: info['location']);
                                          pushPage(
                                              context,
                                              FStarWebView(
                                                  url: info['location']));
                                          break;
                                        case SystemMode.VPN2:
                                          // TODO: Handle this case.
                                          EasyLoading.showToast('未实现');
                                          return;
                                          break;
                                        case SystemMode.CLOUD:
                                          // TODO: Handle this case.
                                          EasyLoading.showToast('未实现');
                                          return;
                                          break;
                                      }
                                      EasyLoading.dismiss();
                                    } catch (e) {
                                      EasyLoading.showError(e.toString());
                                      Log.logger.e(e.toString());
                                    }
                                  },
                                  child: Text('访问原始网页'),
                                ),
                              )
                            ],
                          ),
                        ),
                        SmartRefresher(
                          controller: _clubController,
                          header: WaterDropHeader(),
                          onRefresh: () async {
                            final settings = getSettingsData();
                            final user = getUserData();
                            if (user.tyAccount == null ||
                                user.tyPassword == null) {
                              EasyLoading.showToast('请先验证体育账号');
                              _clubController.refreshCompleted();
                              return;
                            }
                            try {
                              switch (settings.systemMode) {
                                case SystemMode.JUST:
                                  var content = await JUST.instance
                                      .getSportClub(
                                          username: user.tyAccount,
                                          password: user.tyPassword);
                                  final parser = SportClubParser();
                                  parser.action(content);
                                  setState(() {
                                    _clubItem = parser.item;
                                    _clubRemark = parser.remark;
                                  });
                                  break;
                                case SystemMode.VPN:
                                  var content = await VPN.instance.getSportClub(
                                      vpnUsername: user.vpnAccount,
                                      vpnPassword: user.vpnPassword,
                                      username: user.tyAccount,
                                      password: user.tyPassword);
                                  final parser = SportClubParser();
                                  parser.action(content);
                                  setState(() {
                                    _clubItem = parser.item;
                                    _clubRemark = parser.remark;
                                  });
                                  break;
                                case SystemMode.VPN2:
                                  // TODO: Handle this case.
                                  EasyLoading.showToast('未实现');
                                  break;
                                case SystemMode.CLOUD:
                                  // TODO: Handle this case.
                                  EasyLoading.showToast('未实现');
                                  break;
                              }
                              _clubController.refreshCompleted();
                            } catch (e) {
                              EasyLoading.showError(e.toString());
                              Log.logger.e(e.toString());
                              _clubController.refreshFailed();
                            }
                          },
                          child: CustomScrollView(
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                  final items = _clubItem[index].split(' ');
                                  return Row(
                                    children: items.map((e) => Text(e)).toList()
                                      ..insert(0, Text('${index + 1}')),
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                  );
                                }, childCount: _clubItem.length),
                              ),
                              SliverPadding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 12.0)),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(_clubRemark),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: TextButton(
                                  onPressed: () async {
                                    try {
                                      final settings = getSettingsData();
                                      final user = getUserData();
                                      if (user.tyAccount == null ||
                                          user.tyPassword == null) {
                                        EasyLoading.showToast('请先验证体育账号');
                                        return;
                                      }
                                      switch (settings.systemMode) {
                                        case SystemMode.JUST:
                                          EasyLoading.show(status: '请稍等');
                                          var info = await JUST.instance
                                              .getSportClubCookie(
                                                  username: user.tyAccount,
                                                  password: user.tyPassword);
                                          setCookie(
                                              cookie: info['cookie'],
                                              url: info['location']);
                                          pushPage(
                                              context,
                                              FStarWebView(
                                                  url: info['location']));
                                          break;
                                        case SystemMode.VPN:
                                          EasyLoading.show(status: '请稍等');
                                          var info = await VPN.instance
                                              .getSportClubCookie(
                                                  vpnUsername: user.vpnAccount,
                                                  vpnPassword: user.vpnPassword,
                                                  username: user.tyAccount,
                                                  password: user.tyPassword);
                                          setCookie(
                                              cookie: info['cookie'],
                                              url: info['location']);
                                          pushPage(
                                              context,
                                              FStarWebView(
                                                  url: info['location']));
                                          break;
                                        case SystemMode.VPN2:
                                          // TODO: Handle this case.
                                          EasyLoading.showToast('未实现');
                                          return;
                                          break;
                                        case SystemMode.CLOUD:
                                          // TODO: Handle this case.
                                          EasyLoading.showToast('未实现');
                                          return;
                                          break;
                                      }
                                      EasyLoading.dismiss();
                                    } catch (e) {
                                      EasyLoading.showError(e.toString());
                                      Log.logger.e(e.toString());
                                    }
                                  },
                                  child: Text('访问原始网页'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],
                );
              },
            );
            break;
          case IdentityType.graduate:
            return Column(
              children: [],
            );
            break;
          default:
            throw UnimplementedError();
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scoreScrollController.dispose();
  }

  _buildCourseToday(CourseMap courseMap) {
    final currentWeek = getCurrentWeek() + 1;
    final today = DateTime.now().weekday;
    return courseMap.dataMap[today]
        .where((element) => element.week.contains(currentWeek))
        .map(
          (course) => Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                        '${course.row}-${course.row + course.rowSpan - 1}'),
                  ),
                ),
                Expanded(flex: 3, child: Center(child: Text(course.name))),
                Expanded(flex: 3, child: Center(child: Text(course.classroom)))
              ],
            ),
          ),
        )
        .toList();
  }

  void _handleScoreQuery(BuildContext context) async {
    EasyLoading.show(status: '正在请求最新成绩');
    await Future.delayed(Duration(milliseconds: 375));
    try {
      var score = await Application.getScore();
      if (score.isEmpty) {
        EasyLoading.showToast('该学期没有成绩或者未评教');
        return;
      }
      final settings = getSettingsData();
      if (settings.reverseScore) {
        score = score.reversed.toList();
      }
      if (settings.saveScoreCloud &&
          settings.scoreDisplayMode == ScoreDisplayMode.MAX &&
          settings.scoreQueryMode == ScoreQueryMode.DEFAULT) {
        compute(calculateDigest, score.toString()).then((digest) async {
          var prefs = await SharedPreferences.getInstance();
          var next = digest.toString();
          var pre = prefs.getString('scoreDigest');
          if (pre != next) {
            prefs.setString('scoreDigest', digest.toString());
            FStarNet().uploadScore(score);
          }
        });
      }
      pushPage(context, ScorePage(score));
      EasyLoading.dismiss();
      context.read<ScoreList>()
        ..list = score
        ..save();
    } catch (e) {
      Log.logger.e(e.toString());
      EasyLoading.showError(e.toString());
    }
  }

  _buildScoreButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              final settings = getSettingsData();
              final user = getUserData();
              if (user.jwAccount == null || user.jwPassword == null) {
                EasyLoading.showToast('没有验证教务系统账号');
                return;
              }
              switch (settings.scoreQueryMode) {
                case ScoreQueryMode.DEFAULT:
                  _handleScoreQuery(context);
                  break;
                case ScoreQueryMode.ALTERNATIVE:
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.INFO,
                    body: Center(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Text.rich(
                          TextSpan(
                            text: "该入口仅在评教系统未开放的时候使用，"
                                "为不影响学校的评教秩序，"
                                "请在评教系统开放之后及时评教（工具页）并换回默认入口！",
                            children: [
                              TextSpan(
                                text: "注意：",
                                style: TextStyle(color: Colors.red),
                              ),
                              TextSpan(
                                  text: "此入口计算的绩点可能不准确（有挂科的情况）"
                                      "请以"),
                              TextSpan(
                                text: "默认入口",
                                style: TextStyle(color: Colors.red),
                              ),
                              TextSpan(text: "计算的绩点为准！")
                            ],
                          ),
                        ),
                      ),
                    ),
                    btnOk: TimerCountDownButton(
                      onPressed: () {
                        _handleScoreQuery(context);
                        Navigator.pop(context);
                      },
                    ),
                  ).show();
                  break;
              }
              // switch (settings.systemMode) {
              //   case SystemMode.JUST:
              //     break;
              //   case SystemMode.VPN:
              //     _handleScoreQuery(context);
              //     break;
              //   case SystemMode.VPN2:
              //     EasyLoading.showToast('待实现');
              //     // TODO: Handle this case.
              //     break;
              //   case SystemMode.CLOUD:
              //     EasyLoading.showToast('待实现');
              //     // TODO: Handle this case.
              //     break;
              // }
            },
            child: Text('学业成绩'),
          ),
          TextButton(
            onPressed: () async {
              final settings = getSettingsData();
              final user = getUserData();
              if (user.tyAccount == null || user.tyPassword == null) {
                EasyLoading.showToast('没有验证体育账号');
                return;
              }
              switch (settings.systemMode) {
                case SystemMode.JUST:
                  try {
                    EasyLoading.show(status: '正在请求成绩');
                    await Future.delayed(Duration(milliseconds: 375));
                    final sportScoreRequester = SportScoreRequester();
                    final sportScoreParser = SportScoreParser();
                    final content = await sportScoreRequester.action();
                    sportScoreParser.action(content);
                    EasyLoading.dismiss();
                    pushPage(
                        context, SportScore(scoreData: sportScoreParser.score));
                  } catch (e) {
                    Log.logger.e(e.toString());
                    EasyLoading.showError(e.toString());
                  }
                  break;
                case SystemMode.VPN:
                  EasyLoading.showToast('待实现');
                  // TODO: Handle this case.
                  break;
                case SystemMode.VPN2:
                  EasyLoading.showToast('待实现');
                  // TODO: Handle this case.
                  break;
                case SystemMode.CLOUD:
                  EasyLoading.showToast('待实现');
                  // TODO: Handle this case.
                  break;
              }
            },
            child: Text('体育成绩'),
          ),
          TextButton(
            child: Text('实验成绩'),
            onPressed: () {
              EasyLoading.showToast('待实现');
            },
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ),
    );
  }

  _buildScore(BuildContext context) {
    return Consumer<ScoreList>(
        builder: (BuildContext context, value, Widget child) {
      final score = value.list;
      return Container(
        height: MediaQuery.of(context).size.height / 2,
        child: NotificationListener<OverscrollNotification>(
          onNotification: _handleOverscrollNotification,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            controller: _scoreScrollController,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: InkWell(
                  onTap: () {
                    showScoreDetails(context, score[index]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              score[index].name,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              score[index].score,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: score.length,
          ),
        ),
      );
    });
  }

  bool _handleOverscrollNotification(OverscrollNotification notification) {
    bool onTop = notification.overscroll < 0 ? true : false;
    if ((onTop &&
            _scrollController.position.minScrollExtent !=
                _scrollController.offset) ||
        (!onTop &&
            _scrollController.position.maxScrollExtent !=
                _scrollController.offset)) {
      if (onTop &&
          _scrollController.offset + notification.overscroll <
              _scrollController.position.minScrollExtent) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      } else if (!onTop &&
          _scrollController.offset + notification.overscroll >
              _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        _scrollController
            .jumpTo(_scrollController.offset + notification.overscroll);
      }
    }
    return true;
  }

  @override
  bool get wantKeepAlive {
    return true;
  }
}
