import 'dart:io';
import 'dart:math';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fstar/model/rank_data.dart';
import 'package:fstar/model/score_data.dart';
import 'package:fstar/model/score_popup_menu_item.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/page/gpa_info_page.dart';
import 'package:fstar/page/rank_page.dart';
import 'package:fstar/utils/FStarNet.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:fstar/widget/blur_rect_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ScorePage extends StatefulWidget {
  ScorePage(this.scoreData, {Key key}) : super(key: key);

  final List<ScoreData> scoreData;

  @override
  State createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage>
    with SingleTickerProviderStateMixin {
  int _semesterCount = 0;
  List<String> gpa = [];
  AnimationController _floatingController;
  final _scrollController = ScrollController();
  Offset _position;
  bool _showButton;
  bool _rendered;
  List<bool> _selectedCourse;
  bool _isCheckedAll;
  bool _isCrossing;
  ScorePopupMenuItem _exportFlag = ScorePopupMenuItem.BX;
  final calculateComplete = '计算完成';
  final networkError = '网络错误';
  final unknownError = '未知错误';

  @override
  void initState() {
    super.initState();
    gpa = calculateGPA(
        widget.scoreData,
        (ScoreData data) =>
            data.courseProperty == '必修' && !data.name.contains('体育'));
    gpa.insert(0, '必修绩点');
    _semesterCount = _getSemesterCount(widget.scoreData);
    _floatingController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    CurvedAnimation(parent: _floatingController, curve: Curves.bounceOut);
    _showButton = false;
    _position = Offset(0, 210);
    _rendered = false;
    _selectedCourse = List(widget.scoreData.length);
    _selectedCourse.fillRange(0, widget.scoreData.length, false);
    _isCheckedAll = false;
    _isCrossing = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _position = Offset(MediaQuery.of(context).size.width - 70, 210.0);
      _rendered = true;
    });
  }

  _exportScore(List<ScoreData> data) async {
    var semesterScore = Map<String, List<ScoreData>>();
    data.forEach((element) {
      if (semesterScore[element.semester] == null)
        semesterScore[element.semester] = [];
      semesterScore[element.semester].add(element);
    });
    final dir = await getExternalStorageDirectory();
    var file = '${dir.path}/personal.xlsx';
    var excel = Excel.createExcel();
    semesterScore.forEach((semester, scores) {
      var header = scores.map((e) => e.name).toList();
      var body = scores.map((e) => e.score).toList();
      excel.appendRow(semester, header);
      excel.appendRow(semester, body);
    });
    const sheet = '全部成绩';
    var header = [
      '序号',
      '课程号',
      '课程名称',
      '开课学期',
      '成绩',
      '学分',
      '总学时',
      '考核方式',
      '课程属性',
      '课程性质',
      '替代课程号',
      '替代课程名',
      '成绩标志'
    ];
    excel.appendRow(sheet, header);
    int index = 1;
    data.forEach((d) {
      excel.appendRow(sheet, [
        index++,
        d.scoreNo,
        d.name,
        d.semester,
        d.score,
        d.credit,
        d.period,
        d.evaluationMode,
        d.courseProperty,
        d.courseNature,
        d.alternativeCourseNumber,
        d.alternativeCourseName,
        d.scoreFlag
      ]);
    });
    excel.delete('Sheet1');
    excel.encode().then((value) {
      File(file)
        ..createSync(recursive: true)
        ..writeAsBytesSync(value);
      EasyLoading.showSuccess('导出目录${dir.path}');
    }).catchError((error) {
      EasyLoading.showError('导出失败');
      Log.logger.e(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: Stack(
          children: [
            AnimationLimiter(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    actions: [
                      _buildPopUpButton(),
                    ],
                    pinned: true,
                    expandedHeight: _semesterCount * 26 + 200.0,
                    //此值要根据成绩的统计结果动态计算
                    flexibleSpace: _buildFlexibleSpace(),
                  ),
                  _buildSliverPersistentHeader(),
                  SliverList(
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
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadiusDirectional.circular(5),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    showScoreDetails(
                                        context, widget.scoreData[index]);
                                  },
                                  child: Container(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "${index + 1}",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.scoreData[index].name,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.scoreData[index].score,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: _scoreColor(widget
                                                      .scoreData[index].score)),
                                            ),
                                          ),
                                          Offstage(
                                            offstage: !_showButton,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                              child: AnimatedBuilder(
                                                animation: _floatingController,
                                                child: Checkbox(
                                                    value:
                                                        _selectedCourse[index],
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        _selectedCourse[index] =
                                                            value;
                                                      });
                                                    }),
                                                builder: (BuildContext context,
                                                    Widget child) {
                                                  return Transform.scale(
                                                    scale: _floatingController
                                                        .value,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            ),
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
                ],
              ),
            ),
            Positioned(
                left: _rendered
                    ? _position.dx
                    : MediaQuery.of(context).size.width - 70,
                top: _position.dy,
                child: Draggable(
                    feedback: Container(
                        child: FloatingActionButton(
                            child: Icon(Icons.check), onPressed: () {})),
                    child: AnimatedBuilder(
                      animation: _floatingController,
                      builder: (BuildContext context, Widget child) {
                        return Transform.scale(
                          scale: _floatingController.value,
                          child: child,
                        );
                      },
                      child: Container(
                        child: FloatingActionButton(
                            child: Icon(Icons.check),
                            onPressed: () {
                              _floatingController.reverse();
                              var scoreList = <ScoreData>[];
                              for (int i = 0;
                                  i < widget.scoreData.length;
                                  ++i) {
                                if (_selectedCourse[i]) {
                                  if (_isCrossing) {
                                    var e = widget.scoreData[i];
                                    var data = ScoreData(
                                        no: e.no,
                                        semester: "跨",
                                        scoreNo: e.scoreNo,
                                        name: e.name,
                                        score: e.score,
                                        credit: e.credit,
                                        period: e.period,
                                        evaluationMode: e.evaluationMode,
                                        courseProperty: e.courseProperty,
                                        courseNature: e.courseNature,
                                        alternativeCourseName:
                                            e.alternativeCourseName,
                                        alternativeCourseNumber:
                                            e.alternativeCourseNumber,
                                        scoreFlag: e.scoreFlag);
                                    scoreList.add(data);
                                  } else {
                                    scoreList.add(widget.scoreData[i]);
                                  }
                                }
                              }
                              setState(() {
                                _showButton = false;
                                gpa = calculateGPA(
                                    scoreList, (scoreData) => true);
                                gpa.insert(0, '自选课程绩点');
                              });
                              EasyLoading.showToast(calculateComplete);
                            }),
                      ),
                    ),
                    childWhenDragging: Container(),
                    onDragEnd: (details) {
                      var dx = details.offset.dx;
                      var dy = details.offset.dy;
                      var size = MediaQuery.of(context).size;
                      var width = size.width;
                      var height = size.height;
                      var point = details.offset;
                      var offset = 10.0;
                      if (point.dx < 0) {
                        point = point.translate(-dx + offset, 0);
                      }
                      if (point.dx > width - 50) {
                        point = point.translate(-point.dx + width - 65, 0);
                      }
                      if (point.dy < 0) {
                        point = point.translate(0, -dy + offset);
                      }
                      if (point.dy > height - 50) {
                        point = point.translate(0, -point.dy + height - 65);
                      }
                      setState(() {
                        _position = point;
                      });
                    }))
          ],
        ),
        onWillPop: () async {
          if (_showButton) {
            setState(() {
              _showButton = false;
            });
            _floatingController.reverse();
            return false;
          } else {
            return true;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _floatingController.dispose();
  }

  Color _scoreColor(String score) {
    //深色主题适配
    Color color;
    double s;
    bool flag = true;
    try {
      s = double.parse(score);
    } catch (e) {
      flag = false;
    }
    if (flag && s >= 80) {
      color = Colors.green;
    } else if (flag && s < 60) {
      color = Colors.red;
    } else if (score == "优" || score == "良") {
      color = Colors.green;
    } else if (score == "差" || score == "不及格" || score == "不通过") {
      color = Colors.red;
    }
    return color;
  }

  int _getSemesterCount(List<ScoreData> scoreData) {
    Set<String> semester = Set<String>();
    scoreData.forEach((element) {
      semester.add(element.semester);
    });
    return semester.length;
  }

  void _onSelected(ScorePopupMenuItem value) async {
    switch (value) {
      case ScorePopupMenuItem.BX:
        _exportFlag = value;
        setState(() {
          gpa = calculateGPA(
              widget.scoreData,
              (ScoreData data) =>
                  data.courseProperty == '必修' && !data.name.contains('体育'));
          gpa.insert(0, '必修绩点');
        });
        EasyLoading.showToast(calculateComplete);
        break;
      case ScorePopupMenuItem.BXRX:
        _exportFlag = value;
        setState(() {
          gpa = calculateGPA(
              widget.scoreData, (ScoreData data) => !data.name.contains('体育'));
          gpa.insert(0, '必修任选绩点');
        });
        EasyLoading.showToast(calculateComplete);
        break;
      case ScorePopupMenuItem.ALL:
        _exportFlag = value;
        setState(() {
          gpa = calculateGPA(widget.scoreData, (_) => true);
          gpa.insert(0, '全部绩点');
        });
        EasyLoading.showToast(calculateComplete);
        break;
      case ScorePopupMenuItem.MANUAL1:
        _exportFlag = value;
        _floatingController.forward();
        _isCrossing = false;
        setState(() {
          _showButton = true;
        });
        break;
      case ScorePopupMenuItem.MANUAL2:
        _exportFlag = value;
        _floatingController.forward();
        _isCrossing = true;
        setState(() {
          _showButton = true;
        });
        break;
      case ScorePopupMenuItem.INFO:
        pushPage(context, GPAInfo());
        break;
      case ScorePopupMenuItem.RANK:
        final settings = getSettingsData();
        if (!settings.saveScoreCloud) {
          EasyLoading.showToast('未在设置中开启成绩上传');
          return;
        }
        try {
          EasyLoading.show(status: '请稍等');
          final user = getUserData();
          var result = await FStarNet().getClassScore(
              user.userNumber.substring(0, user.userNumber.length - 2));
          checkResult(result);
          // print(result.data);
          final students = Map<String, List<ScoreData>>();
          (result.data as List).forEach((element) {
            students.putIfAbsent(element['studentNumber'], () => []);
            students[element['studentNumber']].add(ScoreData.fromMap(element));
          });
          final rankResult = <RankData>[];
          students.forEach((key, value) {
            rankResult.add(RankData(key, value));
          });
          EasyLoading.dismiss();
          pushPage(context, RankPage(rankResult));
        } catch (e) {
          Log.logger.e(e.toString());
          EasyLoading.showError(e.toString());
        }
        break;
      case ScorePopupMenuItem.EXPORT:
        _exportScore(widget.scoreData);
        break;
    }
  }

  _buildSliverPersistentHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ScoreHeaderDelegate(
        child: Card(
          child: Container(
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                  child: Text(
                    '序号',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '课程名称',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '成绩',
                    textAlign: TextAlign.center,
                  ),
                ),
                Offstage(
                  offstage: !_showButton,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AnimatedBuilder(
                      animation: _floatingController,
                      child: Checkbox(
                          value: _isCheckedAll,
                          onChanged: (bool value) {
                            setState(() {
                              _selectedCourse.fillRange(
                                  0, _selectedCourse.length, value);
                              _isCheckedAll = value;
                            });
                          }),
                      builder: (BuildContext context, Widget child) {
                        return Transform.scale(
                          scale: _floatingController.value,
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        minHeight: 40.0,
        maxHeight: 40.0,
      ),
    );
  }

  _buildPopUpButton() {
    return PopupMenuButton(
        icon: Icon(Icons.more_horiz),
        itemBuilder: (context) {
          return ScorePopupMenuItem.values
              .map(
                (e) => PopupMenuItem(
                  value: e,
                  child: Text('${e.name()} ${_exportFlag == e ? '*' : ''}'),
                ),
              )
              .toList();
        },
        onSelected: _onSelected);
  }

  _buildFlexibleSpace() {
    return FlexibleSpaceBar(
      title: Text('学业成绩'),
      background: Selector<SettingsData, Tuple2<bool, String>>(
        selector: (_, data) =>
            Tuple2(data.showScoreBackground, data.scoreBackgroundPath),
        builder: (_, data, __) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (data.item1)
                data.item2 == null
                    ? Image.asset(
                        'images/1.jpg',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      )
                    : Image.file(
                        File(data.item2),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
              Center(
                child: BlurRectWidget(
                  widget: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: gpa
                        .map(
                          (e) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(e),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

//成绩表头
class _ScoreHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget _child;
  final num _minHeight;
  final num _maxHeight;

  _ScoreHeaderDelegate(
      {@required Widget child, @required minHeight, @required maxHeight})
      : _child = child,
        _minHeight = minHeight,
        _maxHeight = maxHeight;

  @override
  bool shouldRebuild(_ScoreHeaderDelegate oldDelegate) {
    return oldDelegate.minExtent != _minHeight ||
        oldDelegate.maxExtent != _maxHeight ||
        _child != oldDelegate._child;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: _child,
    );
  }

  @override
  double get minExtent {
    return _minHeight;
  }

  @override
  double get maxExtent {
    return max(_minHeight, _maxHeight);
  }
}
