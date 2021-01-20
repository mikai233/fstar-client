import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fstar/model/application.dart';
import 'package:fstar/model/course_map.dart';
import 'package:fstar/model/fstar_mode_enum.dart';
import 'package:fstar/model/identity_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/user_data.dart';
import 'package:fstar/page/faq_page.dart';
import 'package:fstar/page/import_webview.dart';
import 'package:fstar/page/jw_login_page.dart';
import 'package:fstar/page/other_system_login.dart';
import 'package:fstar/route/routes.dart';
import 'package:fstar/utils/fstar_scroll_behavior.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: FStarOverScrollBehavior(),
      child: Drawer(
        child: Selector<SettingsData, FStarMode>(
          selector: (_, data) => data.fStarMode,
          builder: (BuildContext context, mode, Widget child) {
            switch (mode) {
              case FStarMode.JUST:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildPadding(context),
                    _buildAvatar(context),
                    _buildHeader(context),
                    Expanded(
                      child: Selector<SettingsData, IdentityType>(
                        selector: (BuildContext context, data) =>
                            data.identityType,
                        builder:
                            (BuildContext context, identityType, Widget child) {
                          return ListView(
                            children: []
                              ..addAll(_buildJustConfig(context, identityType))
                              ..addAll(_buildCommonConfig(context)),
                          );
                        },
                      ),
                    ),
                    _buildButton(context),
                  ],
                );
                break;
              case FStarMode.ThirdParty:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildPadding(context),
                    _buildAvatar(context),
                    _buildHeader(context),
                    Expanded(
                      child: ListView(
                        children: []
                          ..addAll(_buildThirdPartyConfig(context))
                          ..addAll(_buildCommonConfig(context)),
                      ),
                    ),
                  ],
                );
                break;
              default:
                throw UnimplementedError('不支持的课表模式');
            }
          },
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        children: <Widget>[
          OutlinedButton(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                '清除',
              ),
            ),
            onPressed: () {
              EasyLoading.instance.indicatorType =
                  EasyLoadingIndicatorType.squareCircle;
              EasyLoading.show();
              _clearData(context);
              // if (Global.mode == Mode.VPN2) {
              //   VPN2.instance.vpnLogout();
              // }
              Future.delayed(Duration(seconds: 1), () {
                EasyLoading.dismiss();
              });
              Future.delayed(
                Duration(seconds: 2),
                () {
                  EasyLoading.showToast('用户数据已清除');
                },
              );
            },
          ),
          OutlinedButton(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                '登录',
              ),
            ),
            onPressed: () {
              pushPage(context, JwLogin());
            },
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ),
    );
  }

  Color _buildLeadingColor(BuildContext context) {
    return isDarkMode(context)
        ? Theme.of(context).backgroundColor
        : Theme.of(context).primaryColor;
  }

  void _clearData(BuildContext context) {
    context.read<UserData>()
      ..clear() //清除用户数据
      ..save();
    context.read<CourseMap>()
      ..clearCourse()
      ..save();
  }

  List<Widget> _buildCommonConfig(BuildContext context) {
    var config = <Widget>[
      ListTile(
        leading: Icon(
          FontAwesomeIcons.usersCog,
          color: _buildLeadingColor(context),
        ),
        title: Text('设置'),
        onTap: () {
          Application.router.navigateTo(context, Routes.settings,
              transition: TransitionType.material);
        },
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.paperPlane,
          color: _buildLeadingColor(context),
        ),
        title: Text('反馈'),
        onTap: () async {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.NO_HEADER,
            headerAnimationLoop: false,
            animType: AnimType.SCALE,
            title: '反馈',
            desc: '欢迎提交bug和意见',
            btnOkColor: Theme.of(context).primaryColor,
            btnOk: ElevatedButton(
              // color: Theme.of(context).primaryColor,
              child: Text(
                'QQ群',
              ),
              onPressed: () async {
                Navigator.pop(context);
                const key = 'JslDEQedUcWHlRcdR1GqIHLuounce5Q4';
                const url =
                    'mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3D$key';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  EasyLoading.showToast('打开QQ遇到问题');
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45.0),
                ),
              ),
            ),
          ).show();
        },
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.info,
          color: _buildLeadingColor(context),
        ),
        title: Text('关于'),
        onTap: () {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  '繁星是一款由个人开发的课程表软件，包含通用适配模式和江苏科技学专有模式，本软件非官方软件，此软件旨在为大家提供更为便捷的校园服务，简洁无广告。数据的请求和解析全部在手机端完成，不经过服务器。',
                ),
              ),
            ),
          ).show();
        },
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.questionCircle,
          color: _buildLeadingColor(context),
        ),
        title: Text('FAQ'),
        onTap: () {
          pushPage(context, FAQ());
        },
      )
    ];
    return config;
  }

  void _onTap(BuildContext context) async {
    var platform = getCurrentPlatform();
    switch (platform) {
      case FPlatform.android:
      case FPlatform.iOS:
        {
          final picker = ImagePicker();
          File croppedFile;
          try {
            final image = await picker.getImage(source: ImageSource.gallery);
            if (image != null && image.path.isNotEmpty) {
              croppedFile = await cropImage(context, image.path);
            }
            if (croppedFile != null && croppedFile.path.isNotEmpty) {
              String nextPath =
                  (await getApplicationDocumentsDirectory()).path +
                      '/avatar_${DateTime.now().millisecondsSinceEpoch}';
              final settings = context.read<SettingsData>();
              final previousPath = settings.avatarPath;
              if (previousPath != null) {
                final previousFile = File(previousPath);
                if (previousFile.existsSync()) {
                  previousFile.delete();
                }
              }
              final bytes = await croppedFile.readAsBytes();
              File(nextPath).writeAsBytes(bytes).then((value) {
                context.read<SettingsData>()
                  ..avatarPath = nextPath
                  ..save();
              });
            }
          } catch (e) {
            Log.logger.e(e.toString());
          }
        }
        break;
      case FPlatform.fuchsia:
        // TODO: Handle this case.
        break;
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

//本科生
  List<Widget> _buildJustUndergraduateConfig(BuildContext context) {
    return [
      ListTile(
        leading: Icon(
          FontAwesomeIcons.userGraduate,
          color: _buildLeadingColor(context),
        ),
        title: Selector<UserData, String>(
          selector: (_, data) => data.userNumber,
          builder: (_, value, __) {
            return Text(
              '学号:${value ?? ''}',
            );
          },
        ),
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.futbol,
          color: _buildLeadingColor(context),
        ),
        trailing: Selector<UserData, bool>(
          selector: (_, userData) =>
              userData.tyAccount != null && userData.tyPassword != null,
          builder: (_, data, __) {
            return data
                ? Icon(
                    FontAwesomeIcons.checkCircle,
                    color: Colors.green,
                  )
                : Icon(
                    FontAwesomeIcons.timesCircle,
                    color: Colors.red,
                  );
          },
        ),
        title: Text('体育账号'),
        onTap: () {
          pushPage(context, OtherLogin(loginType: LoginType.sport));
        },
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.flask,
          color: _buildLeadingColor(context),
        ),
        trailing: Selector<UserData, bool>(
          selector: (_, data) =>
              data.syAccount != null && data.syPassword != null,
          builder: (_, data, __) {
            return data
                ? Icon(
                    FontAwesomeIcons.checkCircle,
                    color: Colors.green,
                  )
                : Icon(
                    FontAwesomeIcons.timesCircle,
                    color: Colors.red,
                  );
          },
        ),
        title: Text('实验账号'),
        subtitle: Text(
          '非VPN模式需要使用校园网',
          style: TextStyle(fontSize: 45.sp),
        ),
        onTap: () {
          pushPage(context, OtherLogin(loginType: LoginType.experiment));
        },
      )
    ];
  }

//研究生
  List<Widget> _buildJustGraduateConfig(BuildContext context) {
    return [
      ListTile(
        leading: Icon(
          Icons.person,
          color: _buildLeadingColor(context),
        ),
        title: Selector<UserData, String>(
          selector: (_, data) => data.userNumber,
          builder: (_, value, __) {
            return Text(
              '学号:${value ?? ''}',
            );
          },
        ),
      ),
    ];
  }

//头像
  _buildAvatar(BuildContext context) {
    return GestureDetector(
      child: Selector<SettingsData, String>(
          builder: (_, value, __) {
            return Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        spreadRadius: .1,
                        blurRadius: .5)
                  ]),
              child: CircleAvatar(
                backgroundImage: _buildImage(value),
                backgroundColor: Color.fromRGBO(60, 170, 220, 1),
              ),
            );
          },
          selector: (_, data) => data.avatarPath),
      onTap: () {
        _onTap(context);
      },
    );
  }

  _buildPadding(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 50));
  }

//江苏科技大学配置
  _buildJustConfig(BuildContext context, IdentityType identityType) {
    switch (identityType) {
      case IdentityType.undergraduate:
        return _buildJustUndergraduateConfig(context);
        break;
      case IdentityType.graduate:
        return _buildJustGraduateConfig(context);
        break;
      // case IdentityType.teacher:
      //   throw UnimplementedError();
      //   break;
      default:
        throw UnimplementedError();
    }
  }

  _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Selector<UserData, String>(
        selector: (_, data) => data.username,
        builder: (_, username, __) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              username ?? '繁星',
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  _buildThirdPartyConfig(BuildContext context) {
    return [
      ListTile(
        leading: Icon(
          FontAwesomeIcons.fileImport,
          color: _buildLeadingColor(context),
        ),
        title: Text('课表导入'),
        onTap: () {
          pushPage(context, ImportWebView());
        },
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.code,
          color: _buildLeadingColor(context),
        ),
        title: Text('导入指南'),
        onTap: () {
          Navigator.pushNamed(context, 'importSetting');
        },
      ),
    ];
  }

  _buildImage(String value) {
    if (value == null) {
      return Image.asset(
        'images/icon.png',
        fit: BoxFit.fill,
      ).image;
    } else {
      return Image.file(
        File(value),
        fit: BoxFit.cover,
      ).image;
    }
  }
}
