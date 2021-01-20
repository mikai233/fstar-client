import 'package:flutter/material.dart';

class GPAInfo extends StatelessWidget {
  GPAInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('绩点计算说明'),
      ),
      body: Scaffold(
        body: Scrollbar(
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  "课程成绩与绩点",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "课程成绩与绩点的核计方法如下：\n",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text:
                              "（1）百分制成绩：J=(F/10)-5\n式中：J为某门课程的学分绩点，当J小于1时按0计；F为某门课程的成绩分数\n"),
                      TextSpan(
                          text:
                              "（2）五级分制成绩：成绩等级 优良 中 及格 不及格绩点 4.5 3.5 2.5 1.5 0\n"),
                      TextSpan(text: "（3）两级分制成绩：成绩等级 通过 不通过绩点 2.5 0"),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "学分绩点",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text("学分绩点是指某一门课程的学分乘以学习该课程所得的绩点，即：学分绩点=课程学分×绩点"),
              ),
              ListTile(
                title: Text(
                  "平均学分绩点",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "平均学分绩点的计算公式为：\n",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text:
                              "平均学分绩点=（所修各门课程的学分绩点总和）/（所修各门课程的学分总和）=Σ学分绩点/Σ学分\n\n"),
                      TextSpan(
                          text:
                              "如果将所修各门课程的学分绩点总和以及所修各门课程的学分总和，限定在学期或学年或在校整个学习年限，则平均绩点可分为学期平均绩点、学年平均绩点和总平均绩点。平均绩点按四舍五入取到小数点后两位"),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "繁星绩点计算说明",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text:
                              "繁星绩点计算参照江苏科技大学教务处印发的《江苏科技大学学生成绩管理工作细则（江科大校【2018】111号）》中的计算规则\n\n"),
                      TextSpan(
                        text: "计算必修（成绩查询时的默认计算方式）\n",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text: "此方式计算所有的必修课程（不包含体育和限选课程|课程属性请点击每条分数查看）\n"),
                      TextSpan(
                        text: "注意：",
                        style: TextStyle(color: Colors.red),
                      ),
                      TextSpan(text: "根据设置中成绩显示方式的不同（最好成绩和全部成绩）绩点的计算结果会有差异，"),
                      TextSpan(
                        text: "要参考绩点请以最好成绩为准，",
                        style: TextStyle(color: Colors.red),
                      ),
                      TextSpan(
                          text:
                              "查询方式为全部成绩时，如果该学期有重复的成绩会重复计算，导致绩点不准确，不能作为参考绩点\n\n"),
                      TextSpan(
                        text: "计算必修+任选\n",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "必修绩点的计算方式同上，此方式加上课程属性为任选的课程\n\n"),
                      TextSpan(
                        text: "计算全部\n",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "此方式将计算在成绩页面出现的所有课程的绩点\n\n"),
                      TextSpan(
                        text: "手动（分学期）\n",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "此方式选择课程计算绩点将把计算之后的绩点归入课程对应的学期\n\n"),
                      TextSpan(
                        text: "手动（跨学期）\n",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "此方式选择课程计算绩点将无视学期，统一归入跨学期绩点当中"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
