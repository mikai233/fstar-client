import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fstar/model/system_mode_enum.dart';
import 'package:fstar/model/user_data.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:just/just.dart';
import 'package:provider/provider.dart';

import 'fstar_webview.dart';

enum LoginType {
  experiment,
  sport,
}

class OtherLogin extends StatefulWidget {
  final LoginType loginType;

  const OtherLogin({Key key, @required this.loginType})
      : assert(loginType != null),
        super(key: key);

  @override
  State createState() => _OtherLoginState();
}

class _OtherLoginState extends State<OtherLogin> with WidgetsBindingObserver {
  bool _isShowPassWord = false;
  final _usernameController = TextEditingController.fromValue(
      TextEditingValue(text: getUserData().jwAccount ?? ''));
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isKeyBoardTypeActive = false;

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
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    Log.logger.i('did ChangeMetrics');
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
    if (_usernameFocusNode.hasFocus) {
      _usernameFocusNode.unfocus();
    }
    if (_passwordFocusNode.hasFocus) {
      _passwordFocusNode.unfocus();
    }
    final settings = getSettingsData();
    switch (settings.systemMode) {
      case SystemMode.JUST:
        switch (widget.loginType) {
          case LoginType.experiment:
            try {
              EasyLoading.show(status: '正在验证');
              await Future.delayed(Duration(milliseconds: 200));
              await JUST.instance.validateSy(
                  username: _usernameController.text,
                  password: _passwordController.text);
              context.read<UserData>()
                ..syAccount = _usernameController.text
                ..syPassword = _passwordController.text
                ..save();
              EasyLoading.showSuccess('验证成功');
              Navigator.pop(context);
            } catch (e) {
              Log.logger.e(e.toString());
              EasyLoading.showError(e.toString());
            }
            break;
          case LoginType.sport:
            try {
              EasyLoading.show(status: '正在验证');
              await Future.delayed(Duration(milliseconds: 200));
              await JUST.instance.validatePe(
                  username: _usernameController.text,
                  password: _passwordController.text);
              context.read<UserData>()
                ..tyAccount = _usernameController.text
                ..tyPassword = _passwordController.text
                ..save();
              EasyLoading.showSuccess('验证成功');
              Navigator.pop(context);
            } catch (e) {
              Log.logger.e(e.toString());
              EasyLoading.showError(e.toString());
            }
            break;
        }
        break;
      case SystemMode.VPN:
        final user = getUserData();
        if (user.vpnAccount == null || user.vpnPassword == null) {
          EasyLoading.showToast('请先验证教务系统账号');
          return;
        }
        switch (widget.loginType) {
          case LoginType.experiment:
            try {
              EasyLoading.show(status: '正在验证');
              await Future.delayed(Duration(milliseconds: 200));
              await VPN.instance.validateSy(
                  username: _usernameController.text,
                  password: _passwordController.text,
                  vpnUsername: user.vpnAccount,
                  vpnPassword: user.vpnPassword);
              context.read<UserData>()
                ..syAccount = _usernameController.text
                ..syPassword = _passwordController.text
                ..save();
              EasyLoading.showSuccess('验证成功');
              Navigator.pop(context);
            } catch (e) {
              Log.logger.e(e.toString());
              EasyLoading.showError(e.toString());
            }
            break;
          case LoginType.sport:
            try {
              EasyLoading.show(status: '正在验证');
              await Future.delayed(Duration(milliseconds: 200));
              await VPN.instance.validatePe(
                  username: _usernameController.text,
                  password: _passwordController.text,
                  vpnUsername: user.vpnAccount,
                  vpnPassword: user.vpnPassword);
              context.read<UserData>()
                ..tyAccount = _usernameController.text
                ..tyPassword = _passwordController.text
                ..save();
              EasyLoading.showSuccess('验证成功');
              Navigator.pop(context);
            } catch (e) {
              Log.logger.e(e.toString());
              EasyLoading.showError(e.toString());
            }
            break;
        }
        break;
      case SystemMode.VPN2:
        final user = getUserData();
        if (user.serviceAccount == null || user.servicePassword == null) {
          EasyLoading.showToast('请先验证服务大厅账号');
          return;
        }
        final webview = FStarWebView(
          url: 'https://vpn2.just.edu.cn',
          onLoadComplete: (controller, uri) async {
            Log.logger.i(uri.toString());
            switch (uri.toString()) {
              //服务大厅登录页
              case 'https://cas.v.just.edu.cn/cas/login?service=http%3A%2F%2Fmy.just.edu.cn%2F':
                controller.evaluateJavascript(source: '''
                      document.querySelector("#username").value="${user.serviceAccount}";
                      document.querySelector("#password").value="${user.servicePassword}";
                      document.querySelector("#passbutton").click()
                      ''');
                break;
              //服务大厅主页
              case 'https://ids.v.just.edu.cn/_s2/students_sy/main.psp':
                controller.evaluateJavascript(source: '''
                          window.location.href="https://sjjx.v.just.edu.cn/sy/";
                          ''');
                break;
              case 'https://sjjx.v.just.edu.cn/sy/':
                controller.evaluateJavascript(source: '''
                      document.querySelector("#Login1_UserName").value="${_usernameController.text}";
                      document.querySelector("#Login1_PassWord").value="${_passwordController.text}";
                      document.querySelector("#Login1_ImageButton1").click()
                  ''');
                break;
            }
            if (uri.toString().contains(
                'https://sjjx.v.just.edu.cn/sy/student/xsDefault.aspx')) {
              user
                ..syAccount = _usernameController.text
                ..syPassword = _passwordController.text;
              Navigator.pop(context);
              Navigator.pop(context);
            }
          },
        );
        pushPage(context, webview);
        EasyLoading.dismiss();
        break;
      case SystemMode.CLOUD:
        // TODO: Handle this case.
        EasyLoading.showToast('待实现');
        break;
    }
  }

  void showPassWord() {
    setState(() {
      _isShowPassWord = !_isShowPassWord;
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 8),
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
                        keyboardType: TextInputType.phone,
                        controller: _usernameController,
                        focusNode: _usernameFocusNode,
                        onSaved: (value) {
                          _usernameController.text = value;
                        },
                      ),
                    ),
                    Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: _buildDecoration(
                          labelText: '密码',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isShowPassWord
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color.fromARGB(255, 126, 126, 126),
                            ),
                            onPressed: showPassWord,
                          ),
                        ),
                        obscureText: !_isShowPassWord,
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        onFieldSubmitted: (value) {
                          _login();
                        },
                        onSaved: (value) {
                          _passwordController.text = value;
                        },
                      ),
                    ),
                    Container(
                      height: 40.0,
                      margin: EdgeInsets.symmetric(vertical: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  _buildDecoration(
      {String labelText,
      Widget prefixIcon,
      String suffixText,
      Widget suffixIcon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      filled: true,
      fillColor: isDarkMode(context)
          ? Theme.of(context).backgroundColor
          : Color.fromRGBO(240, 240, 240, 1),
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
}
