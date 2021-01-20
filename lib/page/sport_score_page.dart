import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/sport_score_data.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class SportScore extends StatefulWidget {
  SportScore({@required this.scoreData, Key key})
      : assert(scoreData != null),
        super(key: key);

  final List<SportScoreData> scoreData;

  @override
  State createState() => _SportScoreState();
}

class _SportScoreState extends State<SportScore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimationLimiter(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('体育成绩'),
                background: Selector<SettingsData, Tuple2<bool, String>>(
                  selector: (_, data) =>
                      Tuple2(data.showScoreBackground, data.scoreBackgroundPath),
                  builder: (_, data, __) {
                    return data.item1
                        ? data.item2 == null
                            ? Image.asset(
                                'images/1.jpg',
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              )
                            : Image.file(
                                File(data.item2),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              )
                        : SizedBox();
                  },
                ),
              ),
            ),
            AnimationLimiter(
              child: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        //滑动动画
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          //渐隐渐现动画
                          child: Card(
                            margin: EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusDirectional.circular(5),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.NO_HEADER,
                                  body: Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Text(
                                            '详情',
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Divider(
                                          thickness: 1.5,
                                        ),
                                        Text(widget.scoreData[index].detail),
                                      ],
                                    ),
                                  ),
                                  btnOk: ElevatedButton(
                                    child: Text(
                                      '确定',
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ).show();
                              },
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "学期",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.scoreData[index].semester,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "专项名称",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.scoreData[index].special,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "上课时间",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.scoreData[index].time,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "体育教师",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.scoreData[index].teacher,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "课程名称",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.scoreData[index].name,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "体育课总分",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.scoreData[index].score,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "评价",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.scoreData[index].evaluate,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "备注",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.scoreData[index].remark,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black12,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: widget.scoreData.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
