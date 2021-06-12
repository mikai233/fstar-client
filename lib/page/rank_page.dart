import 'dart:io';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fstar/model/rank_data.dart';
import 'package:fstar/model/score_data.dart';
import 'package:fstar/utils/utils.dart';
import 'package:fstar/widget/manual_picker.dart';
import 'package:path_provider/path_provider.dart';

typedef Predicate = bool Function(ScoreData scoreData);

class RankPage extends StatefulWidget {
  final List<RankData> students;

  RankPage(this.students, {Key key}) : super(key: key);

  @override
  State createState() => _RankPageState();
}

class _RankPageState extends State<RankPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> _semesters;
  List<String> _dialogSemesters;
  List<RankData> _students;
  Map<String, List<bool>> _selectedMap;
  Map<String, Set<String>> _selectedCoursesMap;
  Map<String, Set<String>> _courseMap;
  Map<String, List<Map<String, dynamic>>> _semesterRankingMap;
  String _exportFlag;
  ScrollController _scoresDialogController;
  ScrollController _scoreDetailController;

  @override
  void initState() {
    super.initState();
    _exportFlag = 'bx';
    _semesterRankingMap = Map<String, List<Map<String, dynamic>>>();
    _students = widget.students;
    _courseMap = _getCourses(_students);
    _selectedMap = Map<String, List<bool>>();
    _courseMap.forEach((key, value) {
      if (_selectedMap[key] == null) {
        _selectedMap[key] = [];
      }
      _selectedMap[key] = value.map((e) => true).toList();
    });
    _students = widget.students;
    if (_students.isNotEmpty) {
      _semesters = _students[0].getSemesters();
    } else {
      _semesters = [];
    }
    _dialogSemesters = List<String>();
    _dialogSemesters =
        _semesters.where((element) => element.split('-').length == 3).toList();
    _semesters.add('总');

    _semesters.forEach((semester) {
      _semesterRankingMap[semester] = _getRanking(
          _students,
          semester,
          (ScoreData data) =>
              data.courseProperty == '必修' && !data.name.contains('体育'));
    });

    _tabController = TabController(length: _semesters.length, vsync: this);
    _scoresDialogController = ScrollController();
    _scoreDetailController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scoreDetailController.dispose();
    _scoresDialogController.dispose();
  }

  List<Map<String, dynamic>> _getRanking(
      List<RankData> students, String semester, Predicate predicate) {
    var rankingList = List<Map<String, dynamic>>();
    students.forEach((student) {
      if (semester != '总') {
        var result = Map<String, dynamic>();
        var GPA = student.getGPA(semester, predicate);
        result['GPA'] = GPA;
        result['scoreData'] = student.getScore(semester);
        result['studentNumber'] = student.studentNumber;
        rankingList.add(result);
      } else {
        var result = Map<String, dynamic>();
        var GPA = student.getTotalGPA(predicate);
        result['GPA'] = GPA;
        result['scoreData'] = student.scoreData;
        result['studentNumber'] = student.studentNumber;
        rankingList.add(result);
      }
    });
    rankingList.sort((a, b) {
      var d = double.parse(a['GPA']) - double.parse(b['GPA']);
      if (d < 0) {
        return 1;
      } else if (d > 0) {
        return -1;
      } else {
        return 0;
      }
    });
    return rankingList;
  }

  Map<String, Set<String>> _getCourses(List<RankData> data) {
    var map = Map<String, Set<String>>();
    data.forEach((element) {
      element.scoreData.forEach((score) {
        if (map[score.semester] == null) {
          map[score.semester] = Set<String>();
        }
        map[score.semester].add(score.name);
      });
    });
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('班级成绩'),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.more_horiz),
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                PopupMenuItem(
                  child: Text('必修绩点 ${_exportFlag == 'bx' ? '*' : ''}'),
                  value: 'bx',
                ),
                PopupMenuItem(
                  child: Text('全部绩点 ${_exportFlag == 'all' ? '*' : ''}'),
                  value: 'all',
                ),
                PopupMenuItem(
                  child: Text('自选绩点 ${_exportFlag == 'manual' ? '*' : ''}'),
                  value: 'manual',
                ),
                PopupMenuItem(
                  child: Text('导出成绩'),
                  value: 'export',
                )
              ],
              onSelected: (String value) async {
                switch (value) {
                  case 'bx':
                    _exportFlag = value;
                    setState(() {
                      _semesters.forEach((semester) {
                        _semesterRankingMap[semester] = _getRanking(
                            _students,
                            semester,
                            (ScoreData data) =>
                                data.courseProperty == '必修' &&
                                !data.name.contains('体育'));
                      });
                    });
                    break;
                  case 'all':
                    _exportFlag = value;
                    setState(() {
                      _semesters.forEach((semester) {
                        _semesterRankingMap[semester] = _getRanking(
                            _students, semester, (ScoreData data) => true);
                      });
                    });
                    break;
                  case 'manual':
                    _exportFlag = value;
                    var size = MediaQuery.of(context).size;
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.NO_HEADER,
                      body: Container(
                        height: size.height / 3 * 2,
                        child: ManualPicker(
                            _dialogSemesters, _courseMap, _selectedMap),
                      ),
                      btnOk: ElevatedButton(
                        // color: Theme.of(context).primaryColor,
                        child: Text(
                          '确定',
                          // style: TextStyle(
                          //   color: Utils.getReverseForegroundColor(context),
                          // ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _selectedCoursesMap = Map<String, Set<String>>();
                          _semesters.forEach((semester) {
                            if (_selectedCoursesMap[semester] == null) {
                              _selectedCoursesMap[semester] = Set<String>();
                            }
                            if (semester.split('-').length == 3) {
                              var list = _courseMap[semester].toList();
                              var var1 = _selectedMap[semester];
                              for (int i = 0; i < var1.length; ++i) {
                                if (var1[i]) {
                                  _selectedCoursesMap[semester].add(list[i]);
                                }
                              }
                            } else if (semester.split('-').length == 2) {
                              _selectedCoursesMap[semester]
                                  .addAll(_selectedCoursesMap['$semester-1']);
                              _selectedCoursesMap[semester]
                                  .addAll(_selectedCoursesMap['$semester-2']);
                            } else {
                              var set = Set<String>();
                              _selectedCoursesMap.forEach((key, value) {
                                set.addAll(value);
                              });
                              _selectedCoursesMap[semester].addAll(set);
                            }
                          });
                          setState(() {
                            _semesters.forEach((semester) {
                              _semesterRankingMap[semester] = _getRanking(
                                  _students,
                                  semester,
                                  (ScoreData data) =>
                                      _selectedCoursesMap[semester]
                                          .contains(data.name));
                            });
                          });
                        },
                      ),
                    ).show();
                    break;
                  case 'export':
                    final dir = await getExternalStorageDirectory();
                    var file = '${dir.path}/$_exportFlag.xlsx';
                    var excel = Excel.createExcel();
                    //统计每学期有多少种课程
                    var eachSemesterScore = Map<String, Set<String>>();
                    _semesterRankingMap.forEach((semester, value) {
                      if (eachSemesterScore[semester] == null) {
                        eachSemesterScore[semester] = Set();
                      }
                      value.forEach((dataMap) {
                        List<ScoreData> scoreData = dataMap['scoreData'];
                        var set = scoreData.map((e) => e.name).toSet();
                        eachSemesterScore[semester].addAll(set);
                      });
                    });
                    _semesterRankingMap.forEach((semester, value) {
                      var header = <String>[];
                      header.add('学号');
                      header.addAll(eachSemesterScore[semester]);
                      header.add('绩点');
                      excel.appendRow(semester, header);
                      value.forEach((dataMap) {
                        var row = <String>[];
                        var studentNumber = dataMap['studentNumber'];
                        var GPA = dataMap['GPA'];
                        row.add(studentNumber);
                        List<ScoreData> scoreData = dataMap['scoreData'];
                        var semesterScore = eachSemesterScore[semester];
                        Function f = (ScoreData s) => bool;
                        switch (_exportFlag) {
                          case 'bx':
                            f = (ScoreData s) =>
                                s.courseProperty == '必修' &&
                                !s.name.contains('体育');
                            break;
                          case 'all':
                            f = (ScoreData s) => true;
                            break;
                          case 'manual':
                            f = (ScoreData s) =>
                                _selectedCoursesMap[semester].contains(s.name);
                            break;
                        }
                        semesterScore.forEach((score) {
                          var data = scoreData.firstWhere(
                              (element) => element.name == score && f(element),
                              orElse: () => null);
                          if (data != null) {
                            row.add(data.score);
                          } else {
                            row.add('');
                          }
                        });
                        row.add(GPA);
                        excel.appendRow(semester, row);
                      });
                    });
                    excel.delete('Sheet1');
                    var bytes = excel.save();
                    File(file)
                      ..createSync(recursive: true)
                      ..writeAsBytes(bytes)
                          .whenComplete(
                              () => EasyLoading.showSuccess('导出目录${dir.path}'))
                          .catchError((error) {
                        EasyLoading.showError('导出失败');
                      });
                    break;
                }
              },
            )
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: _semesters
                .map((e) => Tab(
                      text: e,
                    ))
                .toList(),
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: _semesters.map((semester) {
            var rankingList = _semesterRankingMap[semester];
            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _RankHeaderDelegate(
                    child: Card(
                      child: Container(
                        child: Flex(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '排名',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '学号',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '绩点',
                                textAlign: TextAlign.center,
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
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.circular(5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () async {
                            var scoresList = rankingList[index]['scoreData'];
                            var size = MediaQuery.of(context).size;
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.NO_HEADER,
                              body: Container(
                                width: size.width / 4 * 3,
                                height: size.height / 3 * 2,
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
                                    Expanded(
                                      child: Scrollbar(
                                        isAlwaysShown: true,
                                        controller: _scoresDialogController,
                                        child: ListView.separated(
                                          physics: BouncingScrollPhysics(),
                                          controller: _scoresDialogController,
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int separatorIndex) =>
                                                  Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            child: Divider(),
                                          ),
                                          itemBuilder: (BuildContext context,
                                                  int index2) =>
                                              InkWell(
                                            onTap: () {
                                              showScoreDetails(
                                                  context, scoresList[index2]);
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      "${index2 + 1}",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      scoresList[index2].name,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      scoresList[index2].score,
                                                      textAlign:
                                                          TextAlign.center,
//                                                      style: TextStyle(
//                                                        color: _scoreColor(
//                                                            widget
//                                                                .scoreData[index]
//                                                                .score),),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          itemCount: rankingList[index]
                                                  ['scoreData']
                                              .length,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              btnOk: ElevatedButton(
                                // color: Theme.of(context).primaryColor,
                                child: Text(
                                  '确定',
                                  // style: TextStyle(
                                  //   color: Utils.getReverseForegroundColor(
                                  //       context),
                                  // ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ).show();
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '${index + 1}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      rankingList[index]['studentNumber'],
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      rankingList[index]['GPA'],
                                      textAlign: TextAlign.center,
//                                              style: TextStyle(
//                                                  color: _scoreColor(widget
//                                                      .scoreData[index].score)),
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
                      );
                    },
                    childCount: rankingList.length,
                  ),
                ),
              ],
            );
          }).toList(),
        ));
  }
}

class _RankHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget _child;
  final num _minHeight;
  final num _maxHeight;

  _RankHeaderDelegate(
      {@required Widget child, @required minHeight, @required maxHeight})
      : _child = child,
        _minHeight = minHeight,
        _maxHeight = maxHeight;

  @override
  bool shouldRebuild(_RankHeaderDelegate oldDelegate) {
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
