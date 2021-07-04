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
import 'package:fstar/model/user_data.dart';
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
                                        switch (settings.systemMode) {
                                          case SystemMode.JUST:
                                          case SystemMode.VPN:
                                            if (user.jwAccount == null ||
                                                user.jwPassword == null) {
                                              EasyLoading.showToast(
                                                  '没有验证教务系统账号');
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
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      child: Text.rich(
                                                        TextSpan(
                                                          text:
                                                              "该入口仅在评教系统未开放的时候使用，"
                                                              "为不影响学校的评教秩序，"
                                                              "请在评教系统开放之后及时评教（工具页）并换回默认入口！",
                                                          children: [
                                                            TextSpan(
                                                              text: "注意：",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            TextSpan(
                                                                text:
                                                                    "此入口计算的绩点可能不准确（有挂科的情况）"
                                                                    "请以"),
                                                            TextSpan(
                                                              text: "默认入口",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            TextSpan(
                                                                text:
                                                                    "计算的绩点为准！")
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  btnOk: TimerCountDownButton(
                                                    onPressed: () {
                                                      print(
                                                          'dddddddddddddddddddddd');
                                                      _handleScoreQuery(
                                                          context);
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ).show();
                                                break;
                                            }
                                            break;
                                          case SystemMode.VPN2:
                                            if (user.serviceAccount == null ||
                                                user.servicePassword == null) {
                                              EasyLoading.showToast(
                                                  '没有验证服务大厅账号');
                                              return;
                                            }
                                            if (settings.scoreQueryMode ==
                                                ScoreQueryMode.ALTERNATIVE) {
                                              AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType.INFO,
                                                body: Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(15),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        text:
                                                            "该入口仅在评教系统未开放的时候使用，"
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
                                                    Navigator.pop(context);
                                                    handleWebviewScoreQuery(
                                                        context,
                                                        user,
                                                        settings);
                                                  },
                                                ),
                                              ).show();
                                            } else {
                                              handleWebviewScoreQuery(
                                                  context, user, settings);
                                            }

                                            break;
                                          case SystemMode.CLOUD:
                                            EasyLoading.showToast('未实现');
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

  void handleWebviewScoreQuery(
      BuildContext context, UserData userData, SettingsData settingsData) {
    final webview = FStarWebView(
      url: 'https://vpn2.just.edu.cn',
      onLoadComplete: (controller, uri) async {
        Log.logger.i(uri.toString());
        switch (uri.toString()) {
          //服务大厅登录页
          case 'https://cas.v.just.edu.cn/cas/login?service=http%3A%2F%2Fmy.just.edu.cn%2F':
            controller.evaluateJavascript(source: '''
                      document.querySelector("#username").value="${userData.serviceAccount}";
                      document.querySelector("#password").value="${userData.servicePassword}";
                      document.querySelector("#passbutton").click()
                      ''');
            break;
          //服务大厅主页
          case 'https://ids.v.just.edu.cn/_s2/students_sy/main.psp':
            controller.evaluateJavascript(source: '''
                          window.location.href="https://54a22a8aad6e5ffd02eb5278924100b5ids.v.just.edu.cn/sso.jsp";
                          ''');
            break;
          //教务系统主页
          case 'https://54a22a8aad6e5ffd02eb5278924100b5cas.v.just.edu.cn/jsxsd/framework/xsMain.jsp':
            var queryFunction = '';
            if (settingsData.scoreQueryMode == ScoreQueryMode.DEFAULT) {
              queryFunction = '''
           httpPost("https://54a22a8aad6e5ffd02eb5278924100b5cas.v.just.edu.cn/jsxsd/kscj/cjcx_list",{"kksj":"${settingsData.scoreQuerySemester}","xsfs":"${settingsData.scoreDisplayMode.property()}"});
           ''';
            } else {
              queryFunction = '''
              httpPost("https://54a22a8aad6e5ffd02eb5278924100b5cas.v.just.edu.cn/jsxsd/kscj/cjtd_add_left",{"xnxq01id":"${settingsData.scoreQuerySemester}"});
              ''';
            }
            controller.evaluateJavascript(source: '''
            $postFunction
            $queryFunction
            ''');
            break;
          case 'https://54a22a8aad6e5ffd02eb5278924100b5cas.v.just.edu.cn/jsxsd/kscj/cjcx_list':
          case 'https://54a22a8aad6e5ffd02eb5278924100b5cas.v.just.edu.cn/jsxsd/kscj/cjtd_add_left':
            try {
              final html = await controller.getHtml();
              Application.scoreParser.action(html);
              var score = Application.scoreParser.scoreList;
              if (score.isEmpty) {
                EasyLoading.showToast('该学期没有成绩或者未评教');
                Navigator.pop(context);
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
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => ScorePage(score)));
              context.read<ScoreList>()
                ..list = score
                ..save();
            } catch (e) {
              Log.logger.e(e.toString());
              EasyLoading.showError(e.toString());
            }
            break;
        }
      },
    );
    pushPage(context, webview);
  }

  @override
  bool get wantKeepAlive {
    return true;
  }
}
