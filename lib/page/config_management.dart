import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fstar/model/parse_config_data.dart';
import 'package:fstar/utils/FStarNet.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ConfigManagement extends StatefulWidget {
  @override
  State createState() => _ConfigManagementState();
}

class _ConfigManagementState extends State<ConfigManagement> {
  final _refreshController = RefreshController(initialRefresh: true);
  List<ParseConfigData> _config = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的上传'),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () async {
          try {
            var result = await FStarNet().getConfigByUsername();
            print(result);
            checkResult(result);
            setState(() {
              _config = (result.data as List)
                  .map((e) => ParseConfigData.fromMap(e))
                  .toList();
            });
            _refreshController.refreshCompleted();
          } catch (e) {
            Log.logger.e(e.toString());
            _refreshController.refreshFailed();
          }
        },
        child: ListView.separated(
          itemCount: _config.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemBuilder: (BuildContext context, int index) {
            final config = _config[index];
            return ListTile(
              onLongPress: () {
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                try {
                                  var result = await FStarNet()
                                      .deleteConfigById(config.id);
                                  checkResult(result);
                                  setState(() {
                                    _config.removeAt(index);
                                  });
                                  Navigator.pop(context);
                                } catch (e) {
                                  Log.logger.e(e.toString());
                                  EasyLoading.showError(e.toString());
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Text('删除'),
                              ),
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.end,
                        ),
                      );
                    });
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
        ),
      ),
    );
  }
}
