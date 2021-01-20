import 'package:flutter/material.dart';
import 'package:fstar/model/changelog.dart';
import 'package:fstar/utils/FStarNet.dart';
import 'package:fstar/utils/logger.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LogPage extends StatefulWidget {
  LogPage({Key key}) : super(key: key);

  @override
  State createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<Changelog> _changelog = [];
  final _refreshController = RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更新日志'),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        header: WaterDropHeader(),
        onRefresh: () async {
          try {
            var result = await FStarNet().getChangelog();
            setState(() {
              _changelog = (result.data as List<dynamic>)
                  .map((e) => Changelog.fromMap(e))
                  .toList();
            });
            _refreshController.refreshCompleted();
          } catch (e) {
            _refreshController.refreshFailed();
            Log.logger.e(e.toString());
          }
        },
        child: ListView.separated(
            itemBuilder: (_, int index) {
              var item = _changelog[index];
              return ListTile(
                title: Text(item.version),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDescription(item.description),
                ),
              );
            },
            separatorBuilder: (_, int index) => Divider(),
            itemCount: _changelog.length),
      ),
      // body: ListView.separated(
      //     itemBuilder: (_, int index) {
      //       var item = data[index];
      //       return ListTile(
      //         title: Text(item['version']),
      //         subtitle: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: _buildDescription(item['description']),
      //         ),
      //       );
      //     },
      //     separatorBuilder: (_, int index) => Divider(),
      //     itemCount: data.length),
//      body: SingleChildScrollView(
//        child: Column(
//          children: [
//            ListTile(
//              title: Text("1.1.5"),
//              subtitle: Text("新增手动选择课程计算绩点 修正总平均绩点计算的错误 增加绩点计算说明"),
//            ),
//            Divider(),
//            ListTile(
//              title: Text("1.1.4"),
//              subtitle: Text("新增工具=>评教功能 登录页增加重置密码功能"),
//            ),
//            Divider(),
//            ListTile(
//              title: Text("1.1.3"),
//              subtitle: Text("软件优化"),
//            ),
//            Divider(),
//            ListTile(
//              title: Text("1.1.2"),
//              subtitle:
//                  Text("此版本更换了软件的ABI，会导致1.1.1和1.1.0直接升级出现不兼容，需要卸载原有版本才能安装"),
//            ),
//            Divider(),
//            ListTile(
//              title: Text("1.1.1"),
//              subtitle: Text("修复登录逻辑判断BUG"),
//            ),
//            Divider(),
//            ListTile(
//              title: Text("1.1.0"),
//              subtitle: Text("新增成绩查询入口=>评教系统未开放时可使用设置中的未评教入口"),
//            ),
//            Divider(),
//          ],
//        ),
//      ),
    );
  }

  _buildDescription(String description) {
    var descriptions = description.split('-');
    return descriptions.map((e) => Text(e)).toList();
  }
}
