import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fstar/model/parse_config_data.dart';
import 'package:fstar/page/config_management.dart';
import 'package:fstar/utils/FStarNet.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadCode extends StatefulWidget {
  @override
  State createState() => _UploadCodeState();
}

class _UploadCodeState extends State<UploadCode> {
  final _schoolUrlController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _authorController = TextEditingController();
  final _remarkController = TextEditingController();
  final _preController = TextEditingController();
  final _codeController = TextEditingController();
  final _urlFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _authorFocusNode = FocusNode();
  final _remarkFocusNode = FocusNode();
  final _preFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final directory = await getApplicationDocumentsDirectory();
      final urlPath = directory.path + '/url.js';
      final urlFile = File(urlPath);
      if (urlFile.existsSync()) {
        _schoolUrlController.text = urlFile.readAsStringSync();
      }
      final prePath = directory.path + '/pre.js';
      final preFile = File(prePath);
      if (preFile.existsSync()) {
        _preController.text = preFile.readAsStringSync();
      }
      final codePath = directory.path + '/parse.js';
      final codeFile = File(codePath);
      if (codeFile.existsSync()) {
        _codeController.text = codeFile.readAsStringSync();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _schoolUrlController.dispose();
    _schoolNameController.dispose();
    _authorController.dispose();
    _remarkController.dispose();
    _preController.dispose();
    _codeController.dispose();
    _urlFocusNode.dispose();
    _nameFocusNode.dispose();
    _authorFocusNode.dispose();
    _remarkFocusNode.dispose();
    _preFocusNode.dispose();
    _codeFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上传解析函数'),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: _onUploadPressed,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.remove('fstarUsername');
                      prefs.remove('fstarPassword');
                      EasyLoading.showToast('已退出');
                    },
                    child: Text('退出登录'),
                  ),
                  TextButton(
                    onPressed: _onLoginPressed,
                    child: Text('登录/注册'),
                  ),
                  TextButton(
                    onPressed: () async {
                      _unFocus();
                      EasyLoading.show(status: '请稍等');
                      final prefs = await SharedPreferences.getInstance();
                      final username = prefs.getString('fstarUsername');
                      final password = prefs.getString('fstarPassword');
                      if (username == null || password == null) {
                        EasyLoading.showToast('请先登录');
                        return;
                      }
                      try {
                        var result = await FStarNet()
                            .login(username: username, password: password);
                        print(result);
                        checkResult(result);
                        FStarNet().setHeader({
                          result.data['tokenHeader']:
                              '${result.data['tokenPrefix']} ${result.data['token']}'
                        });
                        EasyLoading.dismiss();
                        pushPage(context, ConfigManagement());
                      } catch (e) {
                        EasyLoading.showError(e.toString());
                        Log.logger.e(e.toString());
                      }
                    },
                    child: Text('上传管理'),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.end,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                controller: _schoolNameController,
                focusNode: _nameFocusNode,
                maxLines: null,
                validator: (value) {
                  if (value.isEmpty) {
                    return '请输入学校名称';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: '学校全名',
                  hintText: '必填',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                controller: _schoolUrlController,
                focusNode: _urlFocusNode,
                maxLines: null,
                validator: (value) {
                  if (value.isEmpty) {
                    return '请输入教务系统网址';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: '教务系统网址',
                  hintText: '必填',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                controller: _authorController,
                focusNode: _authorFocusNode,
                maxLines: null,
                validator: (value) {
                  if (value.isEmpty) {
                    return '请输入作者名字';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: '作者',
                  hintText: '必填',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                controller: _remarkController,
                focusNode: _remarkFocusNode,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: '备注',
                  hintText: '可选',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 150),
                child: TextFormField(
                  controller: _preController,
                  focusNode: _preFocusNode,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: '预处理函数',
                    hintText: '可选',
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                    errorBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 300),
                child: TextFormField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  maxLines: null,
                  validator: (value) {
                    if (value.isEmpty) {
                      return '请输入解析函数';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: '解析函数',
                    hintText: '必填',
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                    errorBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLoginPressed() async {
    final prefs = await SharedPreferences.getInstance();
    final fstarUserController = TextEditingController();
    final fstarPasswordController = TextEditingController();
    _unFocus();
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            height: 40,
            decoration: BoxDecoration(
              color: Color.fromRGBO(240, 240, 240, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: fstarUserController,
              decoration: InputDecoration(
                labelText: '用户名',
                hintText: '必填',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            height: 40,
            decoration: BoxDecoration(
              color: Color.fromRGBO(240, 240, 240, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: fstarPasswordController,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '必填',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
      btnOk: ElevatedButton(
        onPressed: () async {
          if (fstarUserController.text.isEmpty ||
              fstarPasswordController.text.isEmpty) {
            EasyLoading.showToast('用户名或密码不能为空');
            return;
          }
          try {
            EasyLoading.show(status: '正在登录');
            var result = await FStarNet().login(
                username: fstarUserController.text.trim(),
                password: fstarPasswordController.text.trim());
            checkResult(result);
            prefs.setString('fstarUsername', fstarUserController.text.trim());
            prefs.setString(
                'fstarPassword', fstarPasswordController.text.trim());
            EasyLoading.dismiss();
            Navigator.pop(context);
          } catch (e) {
            Log.logger.e(e.toString());
            EasyLoading.showError(e.toString());
          }
        },
        child: Text('登录'),
      ),
      btnCancel: ElevatedButton(
        onPressed: () async {
          if (fstarUserController.text.isEmpty ||
              fstarPasswordController.text.isEmpty) {
            EasyLoading.showToast('用户名或密码不能为空');
            return;
          }
          try {
            EasyLoading.show(status: '正在注册');
            var result = await FStarNet().register(
                username: fstarUserController.text.trim(),
                password: fstarPasswordController.text.trim());
            checkResult(result);
            prefs.setString('fstarUsername', fstarUserController.text.trim());
            prefs.setString(
                'fstarPassword', fstarPasswordController.text.trim());
            EasyLoading.dismiss();
            Navigator.pop(context);
          } catch (e) {
            Log.logger.e(e.toString());
            EasyLoading.showError(e.toString());
          }
        },
        child: Text('注册'),
      ),
    ).show();
  }

  void _onUploadPressed() async {
    _unFocus();
    if (_formKey.currentState.validate()) {
      final name = _schoolNameController.text.trim();
      final url = _schoolUrlController.text.trim();
      final author = _authorController.text.trim();
      final remark = _remarkController.text.trim();
      final pre = _preController.text.trim();
      final code = _codeController.text.trim();
      final prefs = await SharedPreferences.getInstance();
      final fstarUsername = prefs.getString('fstarUsername');
      final fstarPassword = prefs.getString('fstarPassword');
      if (fstarUsername == null || fstarPassword == null) {
        EasyLoading.showToast('请先注册账号');
        return;
      }
      try {
        var result = await FStarNet()
            .login(username: fstarUsername, password: fstarPassword);
        checkResult(result);
        FStarNet().setHeader({
          result.data['tokenHeader']:
              '${result.data['tokenPrefix']} ${result.data['token']}'
        });
        final channel = 'com.mdreamfever.fstar/qiniu';
        final methodChannel = MethodChannel(channel);
        String preKey;
        if (pre.isNotEmpty) {
          preKey =
              '${fstarUsername}_${DateTime.now().millisecondsSinceEpoch}_pre.js';
          var result = await FStarNet().getUploadToken(preKey);
          checkResult(result);
          var preToken = result.data;
          Log.logger.i('preToken $preToken');

          methodChannel.invokeMethod('upload',
              {'key': preKey, 'token': preToken, 'data': utf8.encode(pre)});
        }
        final codeKey =
            '${fstarUsername}_${DateTime.now().millisecondsSinceEpoch}_code.js';
        var codeResult = await FStarNet().getUploadToken(codeKey);
        checkResult(codeResult);
        var codeToken = codeResult.data;
        Log.logger.i('codeToken $codeToken');

        methodChannel.invokeMethod('upload',
            {'key': codeKey, 'token': codeToken, 'data': utf8.encode(code)});
        final parseConfigData = ParseConfigData(
            id: null,
            schoolName: name,
            schoolUrl: url,
            user: fstarUsername,
            author: author,
            preUrl: preKey,
            codeUrl: codeKey,
            publishTime: null,
            remark: remark,
            download: null);
        FStarNet().addConfig(parseConfigData);
        EasyLoading.showToast('上传成功');
        Navigator.pop(context);
      } catch (e) {
        Log.logger.e(e.toString());
        EasyLoading.showError(e.toString());
      }
    }
  }

  void _unFocus() {
    _urlFocusNode.unfocus();
    _nameFocusNode.unfocus();
    _authorFocusNode.unfocus();
    _remarkFocusNode.unfocus();
    _preFocusNode.unfocus();
    _codeFocusNode.unfocus();
  }
}
