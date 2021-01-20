import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fstar/model/course_data.dart';
import 'package:fstar/model/course_map.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ImportWebView extends StatefulWidget {
  @override
  State createState() => _ImportWebViewState();
}

class _ImportWebViewState extends State<ImportWebView> {
  InAppWebViewController _appWebViewController;
  double _value = 0.0;
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _appWebViewController.canGoBack()) {
          _appWebViewController.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Container(
            height: 35,
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              onSubmitted: (value) {
                _focusNode.unfocus();
                _appWebViewController.loadUrl(url: value);
              },
              decoration: InputDecoration(
                hintText: '教务系统网址',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: isDarkMode(context)
                    ? Theme.of(context).backgroundColor
                    : Color.fromRGBO(240, 240, 240, 1),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: TextButton(
                  onPressed: () {
                    if (_focusNode.hasFocus) {
                      _focusNode.unfocus();
                    }
                    _appWebViewController.loadUrl(
                        url: _textController.text.trim());
                  },
                  child: Text('搜索'),
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(3.0),
            child: NeumorphicProgress(
              style: ProgressStyle(
                  variant: Theme.of(context).backgroundColor,
                  accent: Theme.of(context).primaryColor),
              percent: _value,
            ),
          ),
          actions: [
            IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                icon: Icon(
                  FontAwesomeIcons.fileImport,
                  size: 16,
                ),
                onPressed: () async {
                  try {
                    EasyLoading.show(status: '正在执行');
                    final directory = await getApplicationDocumentsDirectory();
                    await Future.delayed(Duration(milliseconds: 200));
                    final preFile = File(directory.path + '/pre.js');
                    if (preFile.existsSync()) {
                      final preCode = preFile.readAsStringSync();
                      await _appWebViewController.evaluateJavascript(
                          source: preCode);
                    }
                    final codeFile = File(directory.path + '/parse.js');
                    if (codeFile.existsSync()) {
                      final code = codeFile.readAsStringSync();
                      await _appWebViewController.evaluateJavascript(
                          source: code);
                    } else {
                      EasyLoading.showToast('没有解析函数');
                      await Future.delayed(Duration(seconds: 2));
                    }
                    EasyLoading.dismiss();
                  } catch (e) {
                    Log.logger.e(e.toString());
                    EasyLoading.showError(e.toString());
                  }
                }),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              onPressed: () {
                _appWebViewController.reload();
              },
              icon: Icon(
                FontAwesomeIcons.redo,
                size: 16,
              ),
            ),
          ],
        ),
        body: InAppWebView(
          initialUrl: 'https://www.bing.com/',
          onProgressChanged: (controller, updateValue) {
            setState(() {
              _value = updateValue / 100;
            });
          },
          onCloseWindow: (controller) {
            CookieManager.instance().deleteAllCookies();
          },
          onWebViewCreated: (controller) async {
            _appWebViewController = controller;
            _appWebViewController.addJavaScriptHandler(
                handlerName: 'postCourse',
                callback: (List<dynamic> arguments) {
                  if (arguments.isNotEmpty) {
                    final stringData = arguments[0];
                    final data = jsonDecode(stringData);
                    final settings = context.read<SettingsData>();
                    final courseMap = context.read<CourseMap>();
                    int colorIndex = 0;
                    final colorList = getColorList();
                    var idColorMap = Map<String, Color>();
                    try {
                      final course = <CourseData>[];
                      (data['course'] as List<dynamic>).forEach((element) {
                        print(element);
                        element['week'] = (element['week'] as List<dynamic>)
                            .map((e) => e as int)
                            .toList();
                        element['top'] = 0;
                        element['rawWeek'] = weekList2RawWeek(element['week']);
                        idColorMap.putIfAbsent(element['id'], () {
                          return colorList[colorIndex++ % colorList.length];
                        });
                        element['defaultColor'] = idColorMap[element['id']];
                        course.add(CourseData.fromMap(element));
                      });
                      var remark =
                          data['remark']?.trim()?.replaceAll('\n', '') ?? '';
                      courseMap
                        ..addCourseByList(course, true)
                        ..remark = remark
                        ..save();
                      settings
                        ..unusedCourseColorIndex = colorIndex
                        ..save();
                      EasyLoading.showToast('课表导入成功');
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => route == null);
                    } catch (e) {
                      EasyLoading.showError(e.toString());
                      Log.logger.e(e.toString());
                    }
                  }
                });
            final directory = await getApplicationDocumentsDirectory();
            final urlFile = File(directory.path + '/url.js');
            if (urlFile.existsSync()) {
              final url = urlFile.readAsStringSync();
              _appWebViewController.loadUrl(url: url);
            }
          },
          onScrollChanged: (controller, x, y) {
            //TODO 不要立即unfocus
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
            }
          },
          onLoadStart: (controller, url) {
            _textController.text = url;
          },
          onLoadStop: (controller, url) {
            _appWebViewController.evaluateJavascript(source: r'''
            window.showModalDialog=window.open;
            ''');
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          },
        ),
      ),
    );
  }
}
