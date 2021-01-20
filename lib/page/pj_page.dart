import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fstar/model/system_mode_enum.dart';
import 'package:fstar/page/fstar_webview.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:just/just.dart';
import 'package:just/pj_course.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PJ extends StatefulWidget {
  PJ({Key key}) : super(key: key);

  @override
  State createState() => _PJState();
}

class _PJState extends State<PJ> {
  final _refreshController = RefreshController(initialRefresh: true);
  List<PJCourse> course = [];

  @override
  void dispose() {
    super.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("评教"),
      ),
      body: AnimationLimiter(
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () async {
            final settings = getSettingsData();
            final user = getUserData();
            try {
              switch (settings.systemMode) {
                case SystemMode.JUST:
                  course = await JUST.instance.getPjData(
                      username: user.jwAccount, password: user.jwPassword);
                  break;
                case SystemMode.VPN:
                  course = await VPN.instance.getPjData(
                      username: user.jwAccount,
                      password: user.jwPassword,
                      vpnUsername: user.vpnAccount,
                      vpnPassword: user.vpnPassword);
                  break;
                case SystemMode.VPN2:
                  course = await VPN2.instance.getPjData(
                      username: user.serviceAccount,
                      password: user.servicePassword);
                  break;
                case SystemMode.CLOUD:
                // TODO: Handle this case.
                  break;
              }
            } catch (e) {
              _refreshController.refreshFailed();
              Log.logger.e(e.toString());
            }
            setState(() {});
            _refreshController.refreshCompleted();
          },
          header: WaterDropHeader(),
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) =>
                AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    //滑动动画
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      //渐隐渐现动画
                      child: GestureDetector(
                        child: Card(
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusDirectional.circular(5),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "序号",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course[index].num,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "课程号",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course[index].id,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "课程名称",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course[index].name,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "授课教师",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course[index].teacher,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "总评分",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course[index].score,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "已评",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course[index].YP,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: course[index].YP == "是"
                                                  ? Colors.green
                                                  : Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "是否提交",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          course[index].submit,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: course[index].YP == "是"
                                                  ? Colors.green
                                                  : Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        onTap: () async {
                          var pjCourse = course[index];
                          String url;
                          String name = pjCourse.name;
                          final settings = getSettingsData();
                          final user = getUserData();
                          EasyLoading.show(status: '请稍等');
                          try {
                            switch (settings.systemMode) {
                              case SystemMode.JUST:
                              // url = "http://jwgl.just.edu.cn:8080${pjCourse.url}";
                                final result = await JUST.instance.getCookie(
                                    username: user.jwAccount,
                                    password: user.jwPassword);
                                setCookie(
                                    cookie: result['cookie'],
                                    url: result['location']);
                                final uri = Uri.parse(result['location']);
                                url = uri.scheme +
                                    '://' +
                                    uri.host +
                                    ':' +
                                    uri.port.toString() +
                                    pjCourse.url;
                                break;
                              case SystemMode.VPN:
                                url =
                                'https://vpn.just.edu.cn/jsxsd/xspj/,DanaInfo=jwgl.just.edu.cn,Port=8080+${pjCourse
                                    .url.substring(12)}';
                                final cookie = await VPN.instance.getCookie(
                                    username: user.jwAccount,
                                    password: user.jwPassword,
                                    vpnUsername: user.vpnAccount,
                                    vpnPassword: user.vpnPassword);
                                setCookie(cookie: cookie, url: url);
                                break;
                              case SystemMode.VPN2:
                                url =
                                'https://54a22a8aad6e5ffd02eb5278924100b5my.v.just.edu.cn:4443${pjCourse
                                    .url}';
                                final cookie = await VPN2.instance.getCookie(
                                    username: user.serviceAccount,
                                    password: user.servicePassword);
                                setCookie(cookie: cookie, url: url);
                                break;
                              case SystemMode.CLOUD:
                                EasyLoading.showToast('待实现');
                                // TODO: Handle this case.
                                break;
                            }
                          } catch (e) {
                            EasyLoading.showError('发生错误请重试');
                            return;
                          }
                          EasyLoading.dismiss();
                          pushPage(context, FStarWebView(url: url));
                        },
                      ),
                    ),
                  ),
                ),
            itemCount: course.length,
          ),
        ),
      ),
    );
  }
}
