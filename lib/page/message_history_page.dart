import 'package:flutter/material.dart';
import 'package:fstar/model/message_data.dart';
import 'package:fstar/utils/FStarNet.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MessageHistory extends StatefulWidget {
  @override
  State createState() => _MessageHistoryState();
}

class _MessageHistoryState extends State<MessageHistory> {
  final _refreshController = RefreshController(initialRefresh: true);
  List<MessageData> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('历史消息'),
      ),
      body: SmartRefresher(
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: () async {
          try {
            var result = await FStarNet().getAllMessage();
            checkResult(result);
            setState(() {
              _messages = (result.data as List)
                  .map((e) => MessageData.fromMap(e))
                  .toList();
            });
            _refreshController.refreshCompleted();
          } catch (e) {
            Log.logger.e(e.toString());
            _refreshController.refreshFailed();
          }
        },
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title:
                  Text(DateTime.parse(_messages[index].publishTime).toString()),
              subtitle: Column(
                children: _messages[index]
                    .content
                    .split('\r\n')
                    .map((e) => Text(e))
                    .toList(),
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemCount: _messages.length,
        ),
      ),
    );
  }
}
