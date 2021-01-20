import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fstar/model/parse_config_data.dart';
import 'package:fstar/utils/FStarNet.dart';
import 'package:fstar/utils/fstar_scroll_behavior.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ConfigSearchPage extends StatefulWidget {
  @override
  State createState() => _ConfigSearchPageState();
}

class _ConfigSearchPageState extends State<ConfigSearchPage> {
  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  final _refreshController = RefreshController();
  Future<List<ParseConfigData>> _configFuture;
  var _page = 0;
  final _size = 20;
  List<ParseConfigData> _configs = [];

  @override
  void initState() {
    super.initState();
    _configFuture = FStarNet()
        .getCourseParseConfig(page: _page, size: _size)
        .then((result) {
      checkResult(result);
      _configs = (result.data['content'] as List)
          .map((e) => ParseConfigData.fromMap(e))
          .toList();
      return _configs;
    });
    _textController.addListener(() {
      _handleSearch();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 35,
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            onSubmitted: (value) {
              _focusNode.unfocus();
            },
            decoration: InputDecoration(
              hintText: '学校',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Color.fromRGBO(240, 240, 240, 1),
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
                  _handleSearch();
                },
                child: Text('搜索'),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _configFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<ParseConfigData>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(
                child: Text('none'),
              );
              break;
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
              break;
            case ConnectionState.active:
              return Center(
                child: Text('active'),
              );
              break;
            case ConnectionState.done:
              if (snapshot.hasData) {
                return ScrollConfiguration(
                  behavior: FStarOverScrollBehavior(),
                  child: SmartRefresher(
                    controller: _refreshController,
                    enablePullUp: true,
                    header: WaterDropHeader(),
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: ListView.separated(
                      itemCount: _configs.length,
                      itemBuilder: (BuildContext context, int index) {
                        final config = _configs[index];
                        return ListTile(
                          onTap: () async {
                            EasyLoading.show(status: '正在导入配置');
                            var result = await FStarNet().getCodeHost();
                            checkResult(result);
                            final codeHost = result.data;
                            try {
                              final dio = Dio();
                              final directory =
                                  await getApplicationDocumentsDirectory();
                              final urlPath = directory.path + '/url.js';
                              final urlFile = File(urlPath);
                              if (!urlFile.existsSync()) {
                                urlFile.createSync();
                              }
                              urlFile.writeAsStringSync(config.schoolUrl);
                              if (config.preUrl != null) {
                                final response =
                                    await dio.get('$codeHost/${config.preUrl}');
                                final data = response.data;
                                final prePath = directory.path + '/pre.js';
                                final preFile = File(prePath);
                                if (!preFile.existsSync()) {
                                  preFile.createSync();
                                }
                                preFile.writeAsStringSync(data);
                              }
                              final response =
                                  await dio.get('$codeHost/${config.codeUrl}');
                              final codePath = directory.path + '/parse.js';
                              final codeFile = File(codePath);
                              if (!codeFile.existsSync()) {
                                codeFile.createSync();
                              }
                              codeFile.writeAsStringSync(response.data);
                              EasyLoading.dismiss();
                              await Future.delayed(Duration(milliseconds: 200));
                              EasyLoading.showSuccess('导入成功');
                              Navigator.pop(context);
                              Navigator.pop(context);
                            } catch (e) {
                              EasyLoading.showError(e.toString());
                              Log.logger.e(e.toString());
                            }
                          },
                          title: Text(config.schoolName),
                          trailing: Text('${config.download}次下载'),
                          subtitle: Column(
                            children: [
                              Text('作者:${config.author}'),
                              Text('备注:${config.remark ?? ''}'),
                              Text('预处理函数:${config.preUrl}'),
                              Text('解析函数:${config.codeUrl}'),
                              Text('发布时间:${DateTime.parse(config.publishTime)}')
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider();
                      },
                    ),
                  ),
                );
              } else {
                return SmartRefresher(
                  controller: _refreshController,
                  header: WaterDropHeader(),
                  onRefresh: _onRefresh,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                );
              }
              break;
            default:
              throw UnimplementedError();
              break;
          }
        },
      ),
    );
  }

  void _onRefresh() async {
    try {
      _page = 0;
      var result =
          await FStarNet().getCourseParseConfig(page: _page, size: _size);
      checkResult(result);
      setState(() {
        _configs = (result.data['content'] as List)
            .map((e) => ParseConfigData.fromMap(e))
            .toList();
      });
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
      Log.logger.e(e.toString());
    }
  }

  void _onLoading() async {
    try {
      var result =
          await FStarNet().getCourseParseConfig(page: ++_page, size: _size);
      checkResult(result);
      setState(() {
        _configs.addAll((result.data['content'] as List)
            .map((e) => ParseConfigData.fromMap(e)));
      });
      _refreshController.loadComplete();
    } catch (e) {
      _refreshController.loadFailed();
      Log.logger.e(e.toString());
    }
  }

  void _handleSearch() {
    setState(() {
      if (_textController.text.isNotEmpty) {
        _configFuture = FStarNet()
            .getCourseParseConfigBySchoolName(_textController.text)
            .then((result) {
          checkResult(result);
          print(result.data);
          if (result.data is Map) {
            _configs = (result.data['content'] as List)
                .map((e) => ParseConfigData.fromMap(e))
                .toList();
          } else {
            print(result.data);
            _configs = (result.data as List)
                .map((e) => ParseConfigData.fromMap(e))
                .toList();
          }
          return _configs;
        });
      } else {
        _page = 0;
        _configFuture = FStarNet()
            .getCourseParseConfig(page: _page, size: _size)
            .then((result) {
          checkResult(result);
          if (result.data.isEmpty) {
            _configs = [];
            return _configs;
          }
          _configs = (result.data['content'] as List)
              .map((e) => ParseConfigData.fromMap(e))
              .toList();
          return _configs;
        });
      }
    });
  }
}
