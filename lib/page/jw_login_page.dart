import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fstar/model/application.dart';
import 'package:fstar/model/box_name.dart';
import 'package:fstar/model/course_map.dart';
import 'package:fstar/model/identity_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/system_mode_enum.dart';
import 'package:fstar/model/user_data.dart';
import 'package:fstar/page/fstar_webview.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:just/just.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:tuple/tuple.dart';

//教务系统登录页
class JwLogin extends StatefulWidget {
  JwLogin({Key key}) : super(key: key);

  @override
  _JwLoginState createState() => _JwLoginState();
}

class _JwLoginState extends State<JwLogin> with WidgetsBindingObserver {
  //获取Key用来获取Form表单组件
  final _formKey = GlobalKey<FormState>();
  bool _isShowPassword = false;
  bool _isShowVpnPassword = false;
  final _settings = getSettingsData();
  final _usernameController = TextEditingController.fromValue(TextEditingValue(
      text: getBoxData<UserData>(BoxName.userBox).jwAccount ?? ''));
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isKeyBoardTypeActive = false;
  final _vpnUsernameController = TextEditingController.fromValue(
      TextEditingValue(text: getUserData().vpnAccount ?? ''));
  final _vpnPasswordController = TextEditingController();
  final _vpnUsernameFocusNode = FocusNode();
  final _vpnPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _vpnUsernameController.dispose();
    _vpnPasswordController.dispose();
    _vpnUsernameFocusNode.dispose();
    _vpnPasswordFocusNode.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
          //关闭键盘
          setState(() {
            _isKeyBoardTypeActive = false;
          });
        } else {
          //显示键盘
          setState(() {
            _isKeyBoardTypeActive = true;
          });
        }
      }
    });
  }

  void _login() async {
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      EasyLoading.showToast('账号或密码不能为空');
      return;
    }
    if (_settings.systemMode == SystemMode.VPN) {
      if (_vpnUsernameController.text.trim().isEmpty ||
          _vpnPasswordController.text.isEmpty) {
        EasyLoading.showToast('VPN账号或密码不能为空');
        return;
      }
    }
    if (_formKey.currentState.validate()) {
      if (_usernameFocusNode.hasFocus) {
        _usernameFocusNode.unfocus();
      }
      if (_passwordFocusNode.hasFocus) {
        _passwordFocusNode.unfocus();
      }
      final username = _usernameController.text;
      final password = _passwordController.text;
      try {
        final userData = context.read<UserData>();
        switch (_settings.identityType) {
          case IdentityType.undergraduate:
            {
              switch (_settings.systemMode) {
                case SystemMode.JUST:
                  {
                    EasyLoading.show(status: '正在验证');
                    await JUST.instance
                        .validate(username: username, password: password);
                    await Future.delayed(Duration(milliseconds: 200));
                    EasyLoading.dismiss();
                    userData
                      ..jwAccount = username
                      ..jwPassword = password
                      ..userNumber = username;
                  }
                  break;
                case SystemMode.VPN:
                  {
                    final vpnUsername = _vpnUsernameController.text;
                    final vpnPassword = _vpnPasswordController.text;
                    EasyLoading.show(status: '正在验证VPN');
                    await Future.delayed(Duration(milliseconds: 200));
                    await VPN.instance.validateVPN(
                        username: vpnUsername, password: vpnPassword);
                    EasyLoading.dismiss();
                    await Future.delayed(Duration(milliseconds: 200));
                    await VPN.instance.validateJw(
                        username: username,
                        password: password,
                        vpnUsername: vpnUsername,
                        vpnPassword: vpnPassword);
                    EasyLoading.show(status: '正在验证教务系统账号');
                    await Future.delayed(Duration(milliseconds: 200));
                    EasyLoading.dismiss();
                    userData
                      ..vpnAccount = vpnUsername
                      ..vpnPassword = vpnPassword
                      ..jwAccount = username
                      ..jwPassword = password
                      ..userNumber = username;
                  }
                  break;
                case SystemMode.VPN2:
                  final webview = FStarWebView(
                    url: 'https://vpn2.just.edu.cn',
                    onLoadComplete: (controller, uri) async {
                      Log.logger.i(uri.toString());
                      serviceLoginToServiceHome(
                        uri: uri,
                        controller: controller,
                        settingsData: _settings,
                        args: Tuple2(
                            userData.serviceAccount, userData.servicePassword),
                      );
                      serviceHomeToJwHome(
                          uri: uri,
                          controller: controller,
                          settingsData: _settings,
                          args: Tuple3(userData, _usernameController.text,
                              _passwordController.text));
                      jwHomeToCourse(
                          uri: uri,
                          controller: controller,
                          settingsData: _settings);
                      onCourse(
                          uri: uri,
                          controller: controller,
                          context: context,
                          settingsData: _settings,
                          userData: userData);
                    },
                  );
                  pushPage(context, webview);
                  return;
                  break;
                case SystemMode.CLOUD:
                  //TODO
                  EasyLoading.showToast('待实现');
                  return;
                  break;
              }
            }
            break;
          case IdentityType.graduate:
            {
              switch (_settings.systemMode) {
                case SystemMode.JUST:
                  {
                    EasyLoading.show(status: '正在验证');
                    await YJS.instance
                        .validate(username: username, password: password);
                    await Future.delayed(Duration(milliseconds: 200));
                    EasyLoading.dismiss();
                    userData
                      ..jwAccount = username
                      ..jwPassword = password
                      ..userNumber = username;
                  }
                  break;
                case SystemMode.VPN:
                  {
                    {
                      final vpnUsername = _vpnUsernameController.text;
                      final vpnPassword = _vpnPasswordController.text;
                      EasyLoading.show(status: '正在验证VPN');
                      await Future.delayed(Duration(milliseconds: 200));
                      await YJS_VPN.instance.validateVPN(
                          username: vpnUsername, password: vpnPassword);
                      EasyLoading.dismiss();
                      await Future.delayed(Duration(milliseconds: 200));
                      await YJS_VPN.instance.validate(
                          username: username,
                          password: password,
                          vpnUsername: vpnUsername,
                          vpnPassword: vpnPassword);
                      EasyLoading.show(status: '正在验证研究生系统账号');
                      await Future.delayed(Duration(milliseconds: 200));
                      EasyLoading.dismiss();
                      userData
                        ..vpnAccount = vpnUsername
                        ..vpnPassword = vpnPassword
                        ..jwAccount = username
                        ..jwPassword = password
                        ..userNumber = username;
                    }
                  }
                  break;
                case SystemMode.VPN2:
                  // TODO: Handle this case.
                  EasyLoading.showToast('待实现');
                  return;
                  break;
                case SystemMode.CLOUD:
                  // TODO: Handle this case.
                  EasyLoading.showToast('待实现');
                  return;
                  break;
              }
            }
            break;
        }
        await Future.delayed(Duration(milliseconds: 200));
        EasyLoading.show(status: '正在请求课表');
        final course = await Application.getCourse();
        context.read<CourseMap>()
          ..clearCourse()
          ..addCourseByList(course)
          ..remark = Application.courseParser.remark
          ..save();
        userData
          ..username = Application.courseParser.studentName
          ..save();
        context.read<SettingsData>()
          ..semesterList = Application.courseParser.semesters
          ..save();
        await Future.delayed(Duration(milliseconds: 200));
        EasyLoading.showToast('课表获取成功');
        Navigator.pushNamedAndRemoveUntil(
            context, '/', (route) => route == null);
      } catch (e) {
        Log.logger.e(e.toString());
        EasyLoading.showError(e.toString());
      }
    }
  }

  void showPassWord() {
    setState(() {
      _isShowPassword = !_isShowPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQueryData.fromWindow(window).padding.top,
                      bottom: 5.0),
                  child: Image.asset(
                    "images/icon.png",
                    width: MediaQuery.of(context).size.width / 3,
                  )),
            ),
            if (_settings.systemMode == SystemMode.JUST ||
                _settings.systemMode == SystemMode.VPN)
              Container(
                height: 30,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Selector<SettingsData, IdentityType>(
                  selector: (_, data) => data.identityType,
                  builder: (BuildContext context, value, Widget child) {
                    return ToggleSwitch(
                      minWidth: 90.0,
                      initialLabelIndex: value.index,
                      cornerRadius: 20.0,
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      labels: IdentityType.values.map((e) => e.name()).toList(),
                      activeBgColors: Colors.primaries
                          .take(IdentityType.values.length)
                          .map((color) => [color])
                          .toList(),
                      onToggle: (index) {
                        context.read<SettingsData>()
                          ..identityType = IdentityType.values[index]
                          ..save();
                        configRequesterAndParser();
                      },
                      totalSwitches: IdentityType.values.length,
                    );
                  },
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: <Widget>[
                    if (_settings.systemMode == SystemMode.VPN)
                      Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: TextFormField(
                          decoration: _buildDecoration(
                            labelText: 'VPN账号',
                            prefixIcon: Icon(Icons.person),
                          ),
                          onFieldSubmitted: (value) {
                            _vpnPasswordFocusNode.requestFocus();
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.phone,
                          controller: _vpnUsernameController,
                          focusNode: _vpnUsernameFocusNode,
                          onSaved: (value) {
                            _vpnUsernameController.text = value;
                          },
                          // validator: (String value) {
                          //   var regex = RegExp(r'^[0-9]+$');
                          //   if (regex.hasMatch(value)) {
                          //     return null;
                          //   } else {
                          //     return '账号输入不合法';
                          //   }
                          // },
                        ),
                      ),
                    if (_settings.systemMode == SystemMode.VPN)
                      Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: TextFormField(
                          decoration: _buildDecoration(
                            labelText: 'VPN密码',
                            // hintText: '默认身份证后六位',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isShowVpnPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color.fromARGB(255, 126, 126, 126),
                              ),
                              onPressed: showVpnPassWord,
                            ),
                          ),
                          obscureText: !_isShowVpnPassword,
                          onFieldSubmitted: (value) {
                            _usernameFocusNode.requestFocus();
                          },
                          // keyboardType: TextInputType.text,
                          controller: _vpnPasswordController,
                          focusNode: _vpnPasswordFocusNode,
                          onSaved: (value) {
                            _vpnPasswordController.text = value;
                          },
                          // validator: (String value) {
                          //   var regex = RegExp(r'^[0-9]+$');
                          //   if (regex.hasMatch(value)) {
                          //     return null;
                          //   } else {
                          //     return '账号输入不合法';
                          //   }
                          // },
                        ),
                      ),
                    Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: TextFormField(
                        decoration: _buildDecoration(
                          labelText: '账号',
                          prefixIcon: Icon(Icons.person),
                        ),
                        onFieldSubmitted: (value) {
                          _passwordFocusNode.requestFocus();
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: _usernameController,
                        focusNode: _usernameFocusNode,
                        onSaved: (value) {
                          _usernameController.text = value;
                        },
                        // validator: (String value) {
                        //   var regex = RegExp(r'^[0-9]+$');
                        //   if (regex.hasMatch(value)) {
                        //     return null;
                        //   } else {
                        //     return '账号输入不合法';
                        //   }
                        // },
                      ),
                    ),
                    Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: TextFormField(
                        decoration: _buildDecoration(
                          labelText: '密码',
                          // hintText: '默认身份证后六位',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isShowPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color.fromARGB(255, 126, 126, 126),
                            ),
                            onPressed: showPassWord,
                          ),
                        ),
                        obscureText: !_isShowPassword,
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        onFieldSubmitted: (value) {
                          _login();
                        },
                        onSaved: (value) {
                          _passwordController.text = value;
                        },
                        // validator: (String value) {
                        //   return value.trim().isEmpty ? '密码不能为空' : null;
                        // },
                      ),
                    ),
                    if (_settings.systemMode == SystemMode.JUST)
                      Selector<SettingsData, IdentityType>(
                        selector: (BuildContext context, data) =>
                            data.identityType,
                        builder: (BuildContext context, value, Widget child) {
                          switch (value) {
                            case IdentityType.undergraduate:
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    _buildChangePasswordButton(),
                                    _buildResetPasswordButton(),
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                ),
                              );
                              break;
                            case IdentityType.graduate:
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                              );
                              break;
                            // case IdentityType.teacher:
                            //   return Padding(
                            //     padding: EdgeInsets.symmetric(vertical: 8.0),
                            //   );
                            //   break;
                            default:
                              throw UnimplementedError();
                          }
                        },
                      ),
                    Container(
                      height: 40.0,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: SizedBox.expand(
                        child: ElevatedButton(
                          onPressed: _login,
                          child: Text(
                            '登录',
                            style: TextStyle(fontSize: 14.0),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(45.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedContainer(
              height: _isKeyBoardTypeActive ? 0 : 80,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOutQuad,
              child: Center(
                child: Text(
                  "Copyright © 2019-${DateTime.now().year < 2019 ? 2020 : DateTime.now().year} mdreamfever, all rights reserved.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildChangePasswordButton() {
    return TextButton(
      child: Text('修改密码'),
      onPressed: () {
        final user = getUserData();
        final userController = TextEditingController(text: user.jwAccount);
        final oldPwdController = TextEditingController(text: user.jwPassword);
        final newPwdController = TextEditingController();
        _usernameFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.NO_HEADER,
          body: Column(
            children: [
              Container(
                height: 40.0,
                margin: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: userController,
                  decoration: _buildDecoration(labelText: '学号'),
                ),
              ),
              Container(
                height: 40,
                margin: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: oldPwdController,
                  decoration: _buildDecoration(labelText: '旧密码'),
                ),
              ),
              Container(
                height: 40,
                margin: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: newPwdController,
                  decoration: _buildDecoration(labelText: '新密码'),
                ),
              ),
              Container(
                height: 40.0,
                margin: EdgeInsets.all(8.0),
                child: SizedBox.expand(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (userController.text.trim().isEmpty) {
                        EasyLoading.showToast('账号不能为空');
                        return;
                      }
                      if (oldPwdController.text.trim().isEmpty ||
                          newPwdController.text.trim().isEmpty) {
                        EasyLoading.showToast('密码不能为空');
                        return;
                      }
                      final pre = EasyLoading.instance.indicatorType;
                      EasyLoading.instance.indicatorType =
                          EasyLoadingIndicatorType.pouringHourGlass;
                      EasyLoading.show(status: '请稍等');
                      try {
                        bool success = await JUST.instance.changePassword(
                            account: userController.text.trim(),
                            oldPassword: oldPwdController.text.trim(),
                            newPassword: newPwdController.text.trim());
                        if (success) {
                          EasyLoading.showSuccess('密码修改成功');
                          Navigator.pop(context);
                        } else {
                          EasyLoading.showError('密码修改失败');
                        }
                      } catch (e) {
                        Log.logger.e(e.toString());
                        EasyLoading.showError(e.toString());
                      } finally {
                        EasyLoading.instance.indicatorType = pre;
                      }
                    },
                    child: Text(
                      '确定',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).show();
      },
    );
  }

  _buildResetPasswordButton() {
    return TextButton(
      child: Text('重置密码'),
      onPressed: () {
        final userController = TextEditingController();
        final idController = TextEditingController();
        _usernameFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.NO_HEADER,
          body: Form(
            child: Column(
              children: [
                Container(
                  height: 40,
                  margin: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: userController,
                    decoration: _buildDecoration(labelText: '学号'),
                  ),
                ),
                Container(
                  height: 40,
                  margin: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: idController,
                    decoration: _buildDecoration(labelText: '身份证号'),
                  ),
                ),
                Container(
                  height: 40.0,
                  margin: EdgeInsets.all(8.0),
                  child: SizedBox.expand(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (userController.text.trim().isEmpty) {
                          EasyLoading.showToast('学号不能为空');
                          return;
                        }
                        if (idController.text.trim().isEmpty) {
                          EasyLoading.showToast('身份证号不能为空');
                          return;
                        }
                        final pre = EasyLoading.instance.indicatorType;
                        EasyLoading.instance.indicatorType =
                            EasyLoadingIndicatorType.pouringHourGlass;
                        EasyLoading.show(status: '请稍等');
                        try {
                          bool success = await JUST.instance.resetPassword(
                              user: userController.text.trim(),
                              idCard: idController.text.trim());
                          if (success) {
                            EasyLoading.showSuccess('密码修改成功');
                            Navigator.pop(context);
                          } else {
                            EasyLoading.showError('密码修改失败');
                          }
                        } catch (e) {
                          Log.logger.e(e.toString());
                          EasyLoading.showError(e.toString());
                        } finally {
                          EasyLoading.instance.indicatorType = pre;
                        }
                      },
                      child: Text(
                        '确定',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(45.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).show();
      },
    );
  }

  _buildDecoration(
      {String labelText,
      Widget prefixIcon,
      String suffixText,
      String hintText,
      Widget suffixIcon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      filled: true,
      fillColor: isDarkMode(context)
          ? Theme.of(context).backgroundColor
          : Color.fromRGBO(240, 240, 240, 1),
      hintText: hintText,
      prefixIcon: prefixIcon,
      labelText: labelText,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
    );
  }

  void showVpnPassWord() {
    setState(() {
      _isShowVpnPassword = !_isShowVpnPassword;
    });
  }
}
