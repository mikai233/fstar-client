import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fstar/model/identity_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/system_mode_enum.dart';
import 'package:fstar/model/user_data.dart';
import 'package:fstar/page/fstar_webview.dart';
import 'package:fstar/page/img_page.dart';
import 'package:fstar/page/pj_page.dart';
import 'package:fstar/utils/FStarNet.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:just/just.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

enum ToolItem {
  jwSystem, //教务系统
  sySystem, //实验系统
  vpn, //vpn
  library, //图书馆
  serviceHall, //服务大厅
  graduation, //毕业设计
  schoolBus, //校车
  evaluation, //评教
  calendar, //校历
}
enum YJSToolItem {
  jwSystem, //研究生系统
  vpn, //vpn
  library, //图书馆
  serviceHall, //服务大厅
  schoolBus, //校车
  calendar, //校历
}

extension yjsItemName on YJSToolItem {
  String name() {
    var name = '';
    switch (this.index) {
      case 0:
        name = '研究生系统';
        break;
      case 1:
        name = 'VPN';
        break;
      case 2:
        name = '图书馆';
        break;
      case 3:
        name = '服务大厅';
        break;
      case 4:
        name = '校车';
        break;
      case 5:
        name = '校历';
        break;
      default:
        throw UnimplementedError();
    }
    return name;
  }

  IconData icon() {
    var icon;
    switch (this.index) {
      case 0:
        icon = FontAwesomeIcons.battleNet;
        break;
      case 1:
        icon = Icons.vpn_key;
        break;
      case 2:
        icon = FontAwesomeIcons.book;
        break;
      case 3:
        icon = Icons.contact_mail;
        break;
      case 4:
        icon = FontAwesomeIcons.busAlt;
        break;
      case 5:
        icon = Icons.description;
        break;
      default:
        throw UnimplementedError();
    }
    return icon;
  }
}

extension itemName on ToolItem {
  String name() {
    var name = '';
    switch (this.index) {
      case 0:
        name = '教务系统';
        break;
      case 1:
        name = '实验系统';
        break;
      case 2:
        name = 'VPN';
        break;
      case 3:
        name = '图书馆';
        break;
      case 4:
        name = '服务大厅';
        break;
      case 5:
        name = '毕业设计';
        break;
      case 6:
        name = '校车';
        break;
      case 7:
        name = '评教';
        break;
      case 8:
        name = '校历';
        break;
      default:
        throw UnimplementedError();
    }
    return name;
  }

  IconData icon() {
    var icon;
    switch (this.index) {
      case 0:
        icon = FontAwesomeIcons.battleNet;
        break;
      case 1:
        icon = FontAwesomeIcons.flask;
        break;
      case 2:
        icon = Icons.vpn_key;
        break;
      case 3:
        icon = FontAwesomeIcons.book;
        break;
      case 4:
        icon = Icons.contact_mail;
        break;
      case 5:
        icon = FontAwesomeIcons.graduationCap;
        break;
      case 6:
        icon = FontAwesomeIcons.busAlt;
        break;
      case 7:
        icon = Icons.receipt;
        break;
      case 8:
        icon = Icons.description;
        break;
      default:
        throw UnimplementedError();
    }
    return icon;
  }
}

class ToolPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: false,
          pinned: false,
          expandedHeight: 250.0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('工具'),
            background: Selector<SettingsData, Tuple2<bool, String>>(
              selector: (_, data) =>
                  Tuple2(data.showToolBackground, data.toolBackgroundPath),
              builder: (_, data, __) {
                return data.item1
                    ? data.item2 != null
                        ? Image.file(
                            File(data.item2),
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'images/3.jpg',
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
                          )
                    : SizedBox();
              },
            ),
          ),
        ),
        Selector<SettingsData, IdentityType>(
            builder: (BuildContext context, data, Widget child) {
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
                sliver: SliverGrid(
                  //Grid
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, //Grid按两列显示
                    mainAxisSpacing: 40.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      switch (data) {
                        case IdentityType.undergraduate:
                          {
                            final item = ToolItem.values[index];
                            return TextButton(
                              onPressed: () async {
                                final user = getUserData();
                                final settings = getSettingsData();
                                switch (item) {
                                  case ToolItem.jwSystem:
                                    _handleJwSystem(context, user, settings);
                                    break;
                                  case ToolItem.sySystem:
                                    _handleSySystem(context, user, settings);
                                    break;
                                  case ToolItem.vpn:
                                    _handleVpn(context, user, settings);
                                    break;
                                  case ToolItem.library:
                                    _handleLibrary(context, user, settings);
                                    break;
                                  case ToolItem.serviceHall:
                                    _handleServiceHall(context, user, settings);
                                    break;
                                  case ToolItem.graduation:
                                    _handleGraduation(context, user, settings);
                                    break;
                                  case ToolItem.schoolBus:
                                    _handleSchoolBus(context);
                                    break;
                                  case ToolItem.evaluation:
                                    _handleEvaluation(context, user, settings);
                                    break;
                                  case ToolItem.calendar:
                                    _handleCalendar(context);
                                    break;
                                }
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    item.icon(),
                                    color: isDarkMode(context)
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  Text(
                                    item.name(),
                                    style: TextStyle(
                                        color: isDarkMode(context)
                                            ? Colors.white
                                            : Colors.black),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                              ),
                            );
                          }
                          break;
                        case IdentityType.graduate:
                          {
                            final item = YJSToolItem.values[index];
                            return TextButton(
                              onPressed: () {
                                final user = getUserData();
                                final settings = getSettingsData();
                                switch (item) {
                                  case YJSToolItem.jwSystem:
                                    _handleYjsSystem(context, user, settings);
                                    break;
                                  case YJSToolItem.vpn:
                                    _handleVpn(context, user, settings);
                                    break;
                                  case YJSToolItem.library:
                                    _handleLibrary(context, user, settings);
                                    break;
                                  case YJSToolItem.serviceHall:
                                    _handleServiceHall(context, user, settings);
                                    break;
                                  case YJSToolItem.schoolBus:
                                    _handleSchoolBus(context);
                                    break;
                                  case YJSToolItem.calendar:
                                    _handleCalendar(context);
                                    break;
                                }
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    item.icon(),
                                    color: isDarkMode(context)
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  Text(
                                    item.name(),
                                    style: TextStyle(
                                        color: isDarkMode(context)
                                            ? Colors.white
                                            : Colors.black),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                              ),
                            );
                          }
                          break;
                        default:
                          throw UnimplementedError();
                      }
                    },
                    childCount: _getItemCount(data),
                  ),
                ),
              );
            },
            selector: (BuildContext context, settings) => settings.identityType)
      ],
    );
  }

  void _handleJwSystem(
      BuildContext context, UserData user, SettingsData settings) async {
    try {
      EasyLoading.show(status: '正在启动');
      await Future.delayed(Duration(milliseconds: 200));
      switch (settings.systemMode) {
        case SystemMode.JUST:
          if (user.jwAccount == null || user.jwPassword == null) {
            EasyLoading.showToast('没有验证教务系统账号');
            return;
          }
          final result = await JUST.instance
              .getCookie(username: user.jwAccount, password: user.jwPassword);
          await setCookie(cookie: result['cookie'], url: result['location']);
          pushPage(
            context,
            FStarWebView(url: result['location']),
          );
          EasyLoading.dismiss();
          break;
        case SystemMode.VPN:
          if (user.jwAccount == null || user.jwPassword == null) {
            EasyLoading.showToast('没有验证教务系统账号');
            return;
          }
          if (user.vpnAccount == null || user.vpnPassword == null) {
            EasyLoading.showToast('没有验证VPN账号');
            return;
          }
          final cookie = await VPN.instance.getCookie(
              username: user.jwAccount,
              password: user.jwPassword,
              vpnUsername: user.vpnAccount,
              vpnPassword: user.vpnPassword);
          setCookie(
              cookie: cookie,
              url:
                  'https://vpn.just.edu.cn/jsxsd/framework/,DanaInfo=jwgl.just.edu.cn,Port=8080+xsMain.jsp');
          pushPage(
              context,
              FStarWebView(
                  url:
                      'https://vpn.just.edu.cn/jsxsd/framework/,DanaInfo=jwgl.just.edu.cn,Port=8080+xsMain.jsp'));
          EasyLoading.dismiss();
          break;
        case SystemMode.VPN2:
          // TODO: Handle this case.
          EasyLoading.showToast('待实现');
          break;
        case SystemMode.CLOUD:
          // TODO: Handle this case.
          EasyLoading.showToast('待实现');
          break;
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
      Log.logger.e(e.toString());
    }
  }

  void _handleSySystem(
      BuildContext context, UserData user, SettingsData settings) async {
    if (user.syAccount == null || user.syPassword == null) {
      EasyLoading.showToast('没有验证实验系统账号');
      return;
    }
    try {
      EasyLoading.show(status: '正在启动');
      await Future.delayed(Duration(milliseconds: 200));
      final user = getUserData();
      switch (settings.systemMode) {
        case SystemMode.JUST:
          final cookie = await JUST.instance
              .getSyCookie(username: user.syAccount, password: user.syPassword);
          setCookie(
              cookie: cookie['cookie'], url: 'http://202.195.195.198/sy/');
          pushPage(context,
              FStarWebView(url: 'http://202.195.195.198${cookie['location']}'));
          EasyLoading.dismiss();
          break;
        case SystemMode.VPN:
          if (user.vpnAccount == null || user.vpnPassword == null) {
            EasyLoading.showToast('请先验证教务系统账号');
            return;
          }
          if (user.syAccount == null || user.syPassword == null) {
            EasyLoading.showToast('没有验证实验账号');
            return;
          }
          final result = await VPN.instance.getSyCookie(
              username: user.syAccount,
              password: user.syPassword,
              vpnUsername: user.vpnAccount,
              vpnPassword: user.vpnPassword);
          setCookie(cookie: result['cookie'], url: result['location']);
          pushPage(context, FStarWebView(url: result['location']));
          EasyLoading.dismiss();
          break;
        case SystemMode.VPN2:
          // TODO: Handle this case.
          EasyLoading.showToast('待实现');
          break;
        case SystemMode.CLOUD:
          // TODO: Handle this case.
          EasyLoading.showToast('待实现');
          break;
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
      Log.logger.e(e.toString());
    }
  }

  void _handleVpn(
      BuildContext context, UserData user, SettingsData settings) async {
    EasyLoading.show(status: '正在启动');
    await Future.delayed(Duration(milliseconds: 200));
    try {
      switch (settings.systemMode) {
        case SystemMode.VPN:
          if (user.vpnAccount != null && user.vpnPassword != null) {
            final response = await VPN.instance.vpnLogin(
                vpnUsername: user.vpnAccount, vpnPassword: user.vpnPassword);
            final cookie = response.request.headers[HttpHeaders.cookieHeader];
            setCookie(
                cookie: cookie,
                url: 'https://vpn.just.edu.cn/dana/home/index.cgi');
          }
          pushPage(context,
              FStarWebView(url: 'https://vpn.just.edu.cn/dana/home/index.cgi'));
          EasyLoading.dismiss();
          break;
        case SystemMode.JUST:
        case SystemMode.VPN2:
        case SystemMode.CLOUD:
          pushPage(
              context,
              FStarWebView(
                  url:
                      'https://vpn.just.edu.cn/dana-na/auth/url_default/welcome.cgi'));
          EasyLoading.dismiss();
          break;
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
      Log.logger.e(e.toString());
    }
  }

  void _handleLibrary(
      BuildContext context, UserData user, SettingsData settings) {
    pushPage(context, FStarWebView(url: 'http://lib.just.edu.cn/'));
  }

  void _handleServiceHall(
      BuildContext context, UserData user, SettingsData settings) {
    pushPage(
        context,
        FStarWebView(
          url: 'http://vpn2.just.edu.cn/',
        ));
  }

  void _handleGraduation(
      BuildContext context, UserData user, SettingsData settings) {
    pushPage(context, FStarWebView(url: 'http://bysj.just.edu.cn/'));
  }

  void _handleEvaluation(
      BuildContext context, UserData user, SettingsData settings) {
    if (user.jwAccount == null || user.jwPassword == null) {
      EasyLoading.showToast('没有验证教务系统账号');
      return;
    }
    pushPage(context, PJ());
  }

  int _getItemCount(IdentityType identityType) {
    switch (identityType) {
      case IdentityType.undergraduate:
        return ToolItem.values.length;
        break;
      case IdentityType.graduate:
        return YJSToolItem.values.length;
        break;
      default:
        throw UnimplementedError();
    }
  }

  void _handleSchoolBus(BuildContext context) async {
    try {
      EasyLoading.show(status: '请稍等');
      final result = await FStarNet().getJustSchoolBus();
      checkResult(result);
      final url = result.data;
      if (url == null) {
        EasyLoading.showError('校车url为空');
        return;
      }
      EasyLoading.dismiss();
      pushPage(context, UrlImage(url: url, title: '校车'));
    } catch (e) {
      Log.logger.e(e.toString());
      EasyLoading.showError(e.toString());
    }
  }

  void _handleCalendar(BuildContext context) async {
    try {
      EasyLoading.show(status: '请稍等');
      final result = await FStarNet().getJustSchoolCalendar();
      checkResult(result);
      final url = result.data;
      if (url == null) {
        EasyLoading.showError('校历url为空');
        return;
      }
      EasyLoading.dismiss();
      pushPage(context, UrlImage(url: url, title: '校历'));
    } catch (e) {
      Log.logger.e(e.toString());
      EasyLoading.showError(e.toString());
    }
  }

  void _handleYjsSystem(
      BuildContext context, UserData user, SettingsData settings) async {
    try {
      EasyLoading.show(status: '正在启动');
      await Future.delayed(Duration(milliseconds: 200));
      switch (settings.systemMode) {
        case SystemMode.JUST:
          if (user.jwAccount == null || user.jwPassword == null) {
            EasyLoading.showToast('没有验证研究生系统账号');
            return;
          }
          var response = await YJS.instance
              .login(username: user.jwAccount, password: user.jwPassword);
          var cookie = response.request.headers[HttpHeaders.cookieHeader];
          await setCookie(cookie: cookie, url: response.request.uri.toString());
          pushPage(
            context,
            FStarWebView(url: response.request.uri.toString()),
          );
          EasyLoading.dismiss();
          break;
        case SystemMode.VPN:
          if (user.jwAccount == null || user.jwPassword == null) {
            EasyLoading.showToast('没有验证研究生系统账号');
            return;
          }
          if (user.vpnAccount == null || user.vpnPassword == null) {
            EasyLoading.showToast('没有验证VPN账号');
            return;
          }
          final response = await YJS_VPN.instance.login(
              username: user.jwAccount,
              password: user.jwPassword,
              vpnUsername: user.vpnAccount,
              vpnPassword: user.vpnPassword);
          var cookie = response.request.headers[HttpHeaders.cookieHeader];
          setCookie(cookie: cookie, url: response.request.uri.toString());
          pushPage(context, FStarWebView(url: response.request.uri.toString()));
          EasyLoading.dismiss();
          break;
        case SystemMode.VPN2:
          // TODO: Handle this case.
          EasyLoading.showToast('待实现');
          break;
        case SystemMode.CLOUD:
          // TODO: Handle this case.
          EasyLoading.showToast('待实现');
          break;
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
      Log.logger.e(e.toString());
    }
  }
}
