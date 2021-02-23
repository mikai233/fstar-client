import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fstar/model/application.dart';
import 'package:fstar/model/box_name.dart';
import 'package:fstar/model/fstar_mode_enum.dart';
import 'package:fstar/model/identity_enum.dart';
import 'package:fstar/model/score_display_mode_enum.dart';
import 'package:fstar/model/score_query_mode_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/system_mode_enum.dart';
import 'package:fstar/model/table_mode_enum.dart';
import 'package:fstar/model/theme_color_data.dart';
import 'package:fstar/page/log_page.dart';
import 'package:fstar/page/message_history_page.dart';
import 'package:fstar/page/privacy_policy_page.dart';
import 'package:fstar/route/routes.dart';
import 'package:fstar/utils/fstar_scroll_behavior.dart';
import 'package:fstar/utils/logger.dart';
import 'package:fstar/utils/utils.dart';
import 'package:fstar/widget/my_switch.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:tuple/tuple.dart';

class SettingsPage extends StatefulWidget {
  @override
  State createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  final picker = ImagePicker();
  final _editingController = TextEditingController.fromValue(
      TextEditingValue(text: getSettingsData().currentSemester));
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  String _currentVersion = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('设置'),
        ),
        body: Selector<SettingsData, FStarMode>(
          selector: (_, settingsData) => settingsData.fStarMode,
          builder: (BuildContext context, mode, Widget child) {
            final config = <Widget>[
              ListTile(
                title: Text('课表模式'),
                trailing: Container(
                  height: 30,
                  child: ToggleSwitch(
                    minWidth: 90.0,
                    initialLabelIndex: mode.index,
                    cornerRadius: 20.0,
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    labels: FStarMode.values.map((e) => e.name()).toList(),
                    activeBgColors:
                        Colors.primaries.take(FStarMode.values.length).toList(),
                    onToggle: (index) {
                      context.read<SettingsData>()
                        ..fStarMode = FStarMode.values[index]
                        ..save();
                    },
                  ),
                ),
              ),
            ];
            switch (mode) {
              case FStarMode.JUST:
                config..addAll(_buildJUSTConfig());
                break;
              case FStarMode.ThirdParty:
                break;
              default:
                throw UnimplementedError();
            }
            config.addAll(_buildCommonConfig());
            return ListView.separated(
              cacheExtent: 10,
              controller: _scrollController,
              itemBuilder: (BuildContext context, int index) {
                return config[index];
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
              itemCount: config.length,
            );
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // configRequester();
    configRequesterAndParser();
    _editingController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
  }

  NeumorphicSwitchStyle _buildSwitchStyle() {
    return NeumorphicSwitchStyle(
        inactiveTrackColor:
            isDarkMode(context) ? Theme.of(context).backgroundColor : null,
        activeTrackColor: isDarkMode(context)
            ? Theme.of(context).accentColor
            : Theme.of(context).primaryColor);
  }

  List<Widget> _buildJUSTConfig() {
    //用户身份只能在登录页改变，所以这里直接switch，打开设置页面的时候会重新构建页面
    final identityType = context.read<SettingsData>().identityType;
    final config = <Widget>[];
    switch (identityType) {
      case IdentityType.undergraduate:
        config.addAll([
          Selector<SettingsData, Tuple2<String, List<String>>>(
            selector: (_, data) =>
                Tuple2(data.scoreQuerySemester, data.semesterList),
            builder: (BuildContext context, value, Widget child) {
              return ListTile(
                title: Text(
                    "${'成绩查询学期'}: ${value.item1 == '' ? '全部' : value.item1}"),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  final controller = ScrollController();
                  final semesters = ['']..addAll(value.item2);
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.NO_HEADER,
                    onDissmissCallback: () {
                      controller.dispose();
                    },
                    body: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height / 3),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Center(
                              child: Text(
                                '选择学期',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1.5,
                          ),
                          Expanded(
                            child: Scrollbar(
                              isAlwaysShown: true,
                              controller: controller,
                              child: ListView.builder(
                                controller: controller,
                                physics: BouncingScrollPhysics(),
                                itemCount: semesters.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: ListTile(
                                      title: Center(
                                        child: Text(
                                          semesters[index] == ''
                                              ? '全部'
                                              : semesters[index],
                                          style: TextStyle(
                                              color: semesters[index] ==
                                                      value.item1
                                                  ? (isDarkMode(context)
                                                      ? Theme.of(context)
                                                          .accentColor
                                                      : Theme.of(context)
                                                          .primaryColor)
                                                  : (isDarkMode(context)
                                                      ? Colors.white
                                                      : Colors.black)),
                                        ),
                                      ),
                                      onTap: () async {
                                        context.read<SettingsData>()
                                          ..scoreQuerySemester =
                                              semesters[index]
                                          ..save();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    btnCancel: ElevatedButton(
                      child: Text(
                        '取消',
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ).show();
                },
              );
            },
          ),
          Selector<SettingsData, String>(
            selector: (_, data) => data.currentSemester,
            builder: (BuildContext context, value, Widget child) {
              return ListTile(
                title: Text('手动校正学期'),
                trailing: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 2,
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _editingController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: isDarkMode(context)
                          ? Theme.of(context).backgroundColor
                          : Color.fromRGBO(240, 240, 240, 1),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      suffix: TextButton(
                        onPressed: () {
                          if (_editingController.text.isNotEmpty) {
                            _focusNode.unfocus();
                            context.read<SettingsData>()
                              ..currentSemester = _editingController.text
                              ..save();
                          }
                        },
                        child: Text('确定'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: Text('成绩查询入口'),
            trailing: Selector<SettingsData, ScoreQueryMode>(
              selector: (_, settings) => settings.scoreQueryMode,
              builder: (_, value, __) => Container(
                height: 30,
                child: ToggleSwitch(
                  minWidth: 80.0,
                  initialLabelIndex: value.index,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  labels: ScoreQueryMode.values.map((e) => e.name()).toList(),
                  activeBgColors: Colors.primaries
                      .take(ScoreQueryMode.values.length)
                      .toList(),
                  onToggle: (index) {
                    context.read<SettingsData>()
                      ..scoreQueryMode = ScoreQueryMode.values[index]
                      ..save();
                  },
                ),
              ),
            ),
          ),
          Selector<SettingsData, Tuple2<ScoreDisplayMode, ScoreQueryMode>>(
            selector: (_, settingsData) => Tuple2(
                settingsData.scoreDisplayMode, settingsData.scoreQueryMode),
            builder: (_, value, __) => ListTile(
              enabled: value.item2 == ScoreQueryMode.DEFAULT,
              title: Text('成绩查询方式'),
              trailing: Container(
                height: 30,
                child: AbsorbPointer(
                  absorbing: value.item2 != ScoreQueryMode.DEFAULT,
                  child: ToggleSwitch(
                    minWidth: 80.0,
                    initialLabelIndex: value.item1.index,
                    cornerRadius: 20.0,
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    labels: ScoreDisplayMode.values
                        .map((e) => e.description())
                        .toList(),
                    activeBgColors: Colors.primaries
                        .take(ScoreDisplayMode.values.length)
                        .toList(),
                    onToggle: (index) {
                      context.read<SettingsData>()
                        ..scoreDisplayMode = ScoreDisplayMode.values[index]
                        ..save();
                      // setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ),
          Selector<SettingsData, SystemMode>(
            selector: (_, settingsData) => settingsData.systemMode,
            builder: (_, mode, __) => ListTile(
              title: Text('系统访问模式: ${mode.name()}'),
              trailing: Icon(Icons.chevron_right),
              onTap: _onSystemModeTap,
            ),
          ),
          Selector<SettingsData, bool>(
            selector: (_, settingsData) => settingsData.saveScoreCloud,
            builder: (_, data, __) => MySwitch(
              title: Text('成绩云端保存'),
              value: data,
              onChanged: (bool value) {
                if (value) {
                  AwesomeDialog(
                          context: context,
                          dialogType: DialogType.WARNING,
                          headerAnimationLoop: false,
                          body: Container(
                            child: Center(
                              child: Text(
                                  '开启此选项将会在你查询成绩的时候把你的成绩上传到服务器（你的学号和成绩将会存储到服务器数据库，你的账号和密码服务器不会存储），用于班级排名，尽管数据传输过程已经加密处理，但仍有泄漏的风险，（成绩上传的条件为：成绩查询入口为默认入口且成绩显示方式为最好成绩）'),
                            ),
                          ),
                          btnOkOnPress: () {
                            context.read<SettingsData>()
                              ..saveScoreCloud = value
                              ..save();
                          },
                          dismissOnTouchOutside: false,
                          btnOkText: '确定',
                          btnOkColor: Colors.red,
                          btnCancelOnPress: () {},
                          btnCancelText: '取消',
                          btnCancelColor: Theme.of(context).primaryColor)
                      .show();
                } else {
                  context.read<SettingsData>()
                    ..saveScoreCloud = value
                    ..save();
                  SharedPreferences.getInstance().then((value) {
                    value.remove('scoreDigest');
                  });
                }
              },
            ),
          ),
          Selector<SettingsData, bool>(
            selector: (_, settingsData) => settingsData.reverseScore,
            builder: (_, data, __) => MySwitch(
              title: Text('最新成绩靠前'),
              value: data,
              onChanged: (bool value) => context.read<SettingsData>()
                ..reverseScore = value
                ..save(),
            ),
          ),
          Selector<SettingsData, bool>(
            selector: (_, settingsData) => settingsData.refreshTablePerDay,
            builder: (_, data, __) => MySwitch(
              title: Text('每天刷新一次课表'),
              value: data,
              onChanged: (bool value) => context.read<SettingsData>()
                ..refreshTablePerDay = value
                ..save(),
            ),
          ),
        ]);
        break;
      case IdentityType.graduate:
        config.addAll([
          Selector<SettingsData, SystemMode>(
            selector: (_, settingsData) => settingsData.systemMode,
            builder: (_, mode, __) => ListTile(
              title: Text('系统访问模式: ${mode.name()}'),
              trailing: Icon(Icons.chevron_right),
              onTap: _onSystemModeTap,
            ),
          ),
        ]);
        break;
      // case IdentityType.teacher:
      // TODO: Handle this case.
      // break;
      default:
        throw UnimplementedError();
    }
    return config;
  }

  List<Widget> _buildCommonConfig() {
    var config = <Widget>[
      ListTile(
        title: Text('主题颜色'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          ColorSwatch newColorSwatch;
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: MaterialColorPicker(
                    allowShades: false,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    colors: Colors.primaries,
                    selectedColor: Colors.primaries[
                        getBoxData<ThemeColorData>(BoxName.themeBox).index],
                    onMainColorChange: (ColorSwatch colorSwatch) {
                      newColorSwatch = colorSwatch;
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('取消'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text('确定'),
                      onPressed: () {
                        context.read<ThemeColorData>()
                          ..index = Colors.primaries.indexOf(newColorSwatch)
                          ..save();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
        },
      ),
      ListTile(
        title: Text('头像'),
        subtitle: Text('长按重置'),
        trailing: Icon(Icons.chevron_right),
        onLongPress: () async {
          final settings = context.read<SettingsData>();
          String previousPath = settings.avatarPath;
          final file = File(previousPath);
          if (file.existsSync()) {
            file.deleteSync();
            settings
              ..avatarPath = null
              ..save();
            EasyLoading.showToast('头像重置成功');
          } else {
            EasyLoading.showToast('已是默认头像');
          }
        },
        onTap: () async {
          File croppedFile;
          try {
            final image = await picker.getImage(source: ImageSource.gallery);
            if (image != null && image.path.isNotEmpty) {
              croppedFile = await cropImage(context, image.path);
            }
          } catch (e) {
            EasyLoading.showError('头像设置失败');
            Log.logger.e(e.toString());
          }
          if (croppedFile != null && croppedFile.path.isNotEmpty) {
            String path =
                (await getApplicationDocumentsDirectory()).path + "/avatar";
            var bytes = await croppedFile.readAsBytes();
            File(path)
                .writeAsBytes(bytes)
                .then((value) => context.read<SettingsData>()
                  ..avatarPath = value.path
                  ..save());
          }
        },
      ),
      ListTile(
        title: Text('上课时间'),
        onTap: () {
          Application.router.navigateTo(context, Routes.timeTable,
              transition: TransitionType.material);
        },
        trailing: Icon(Icons.chevron_right),
      ),
      ListTile(
        title: Text('课表属性'),
        onTap: _onTablePropertyTap,
        trailing: Icon(Icons.chevron_right),
      ),
      ListTile(
        title: Text('微件属性'),
        onTap: _onAppWidgetPropertyTap,
        trailing: Icon(Icons.chevron_right),
      ),
      ListTile(
        title: Text('学期周数'),
        onTap: _onSemesterWeekTap,
        trailing: Icon(Icons.chevron_right),
      ),
      ListTile(
        title: Text('课表展示风格'),
        trailing: Selector<SettingsData, TableMode>(
          selector: (BuildContext context, data) => data.tableMode,
          builder: (BuildContext context, value, Widget child) {
            return Container(
              height: 30,
              child: ToggleSwitch(
                minWidth: 50.0,
                initialLabelIndex: value.index,
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                labels: TableMode.values.map((e) => e.name()).toList(),
                activeBgColors:
                    Colors.primaries.take(TableMode.values.length).toList(),
                onToggle: (index) {
                  context.read<SettingsData>()
                    ..tableMode = TableMode.values[index]
                    ..save();
                },
              ),
            );
          },
        ),
      ),
      Selector<SettingsData, bool>(
        selector: (_, settingsData) => settingsData.onlyShowThisWeek,
        builder: (_, data, __) => MySwitch(
            title: Text('只显示本周课程'),
            value: data,
            onChanged: (bool value) {
              context.read<SettingsData>()
                ..onlyShowThisWeek = value
                ..save();
              // Utils.notifyNativeInitSelectionNumberChanged();
            }),
      ),
      Selector<SettingsData, bool>(
        selector: (_, settingsData) => settingsData.tableScrollable,
        builder: (_, data, __) => MySwitch(
          title: Text('课表可左右滑动'),
          value: data,
          onChanged: (bool value) => context.read<SettingsData>()
            ..tableScrollable = value
            ..save(),
        ),
      ),
      Selector<SettingsData, bool>(
        selector: (_, settingsData) => settingsData.showSaturday,
        builder: (_, data, __) => MySwitch(
          title: Text('开启周六'),
          value: data,
          onChanged: (bool value) => context.read<SettingsData>()
            ..showSaturday = value
            ..save(),
        ),
      ),
      Selector<SettingsData, bool>(
        selector: (_, settingsData) => settingsData.showSunday,
        builder: (_, data, __) => MySwitch(
          title: Text('开启周日'),
          value: data,
          onChanged: (bool value) => context.read<SettingsData>()
            ..showSunday = value
            ..save(),
        ),
      ),
      ListTile(
        title: Text('课表背景'),
        subtitle: Text('点击切换|长按重置'),
        onLongPress: () async {
          final settings = context.read<SettingsData>();
          String previousPath = settings.courseBackgroundPath;
          if (previousPath != null) {
            final file = File(previousPath);
            if (file.existsSync()) {
              file.deleteSync();
              settings
                ..courseBackgroundPath = null
                ..save();
              EasyLoading.showToast('背景重置成功');
            }
          } else {
            EasyLoading.showToast('已是默认背景');
          }
        },
        onTap: () async {
          File croppedFile;
          try {
            final image = await picker.getImage(source: ImageSource.gallery);
            if (image != null && image.path.isNotEmpty) {
              croppedFile = await cropImage(context, image.path);
            }
            if (croppedFile != null && croppedFile.path.isNotEmpty) {
              String nextPath =
                  (await getApplicationDocumentsDirectory()).path +
                      '/courseImage_${DateTime.now().millisecondsSinceEpoch}';
              final settings = context.read<SettingsData>();
              final previousPath = settings.courseBackgroundPath;
              if (previousPath != null) {
                final previousFile = File(previousPath);
                if (previousFile.existsSync()) {
                  previousFile.delete();
                }
              }
              final bytes = await croppedFile.readAsBytes();
              File(nextPath).writeAsBytes(bytes).then((value) => settings
                ..courseBackgroundPath = value.path
                ..save());
            }
          } catch (e) {
            EasyLoading.showError('背景设置失败');
            Log.logger.e(e.toString());
          }
        },
        trailing: Selector<SettingsData, bool>(
          builder: (_, bool data, __) {
            return NeumorphicSwitch(
              height: 30,
              style: _buildSwitchStyle(),
              value: data,
              onChanged: (value) {
                context.read<SettingsData>().showCourseBackground = value;
              },
            );
          },
          selector: (_, settingsData) {
            return settingsData.showCourseBackground;
          },
        ),
      ),
      ListTile(
        title: Text('成绩背景'),
        subtitle: Text('点击切换|长按重置'),
        onLongPress: () async {
          final settings = context.read<SettingsData>();
          String previousPath = settings.scoreBackgroundPath;
          if (previousPath != null) {
            final file = File(previousPath);
            if (file.existsSync()) {
              file.deleteSync();
              settings
                ..scoreBackgroundPath = null
                ..save();
              EasyLoading.showToast('背景重置成功');
            }
          } else {
            EasyLoading.showToast('已是默认背景');
          }
        },
        onTap: () async {
          File croppedFile;
          try {
            final image = await picker.getImage(source: ImageSource.gallery);
            if (image != null && image.path.isNotEmpty) {
              croppedFile = await cropImage(context, image.path);
            }
            if (croppedFile != null && croppedFile.path.isNotEmpty) {
              String nextPath =
                  (await getApplicationDocumentsDirectory()).path +
                      '/scoreImage_${DateTime.now().millisecondsSinceEpoch}';
              final settings = context.read<SettingsData>();
              final previousPath = settings.scoreBackgroundPath;
              if (previousPath != null) {
                final previousFile = File(previousPath);
                if (previousFile.existsSync()) {
                  previousFile.delete();
                }
              }
              final bytes = await croppedFile.readAsBytes();
              File(nextPath).writeAsBytes(bytes).then((value) => settings
                ..scoreBackgroundPath = value.path
                ..save());
            }
          } catch (e) {
            EasyLoading.showError('背景设置失败');
            Log.logger.e(e.toString());
          }
        },
        trailing: Selector<SettingsData, bool>(
          builder: (_, bool data, __) {
            return NeumorphicSwitch(
              value: data,
              height: 30,
              style: _buildSwitchStyle(),
              onChanged: (value) {
                context.read<SettingsData>()
                  ..showScoreBackground = value
                  ..save();
              },
            );
          },
          selector: (_, settingsData) {
            return settingsData.showScoreBackground;
          },
        ),
      ),
      ListTile(
        title: Text('工具背景'),
        subtitle: Text('点击切换|长按重置'),
        onLongPress: () async {
          final settings = context.read<SettingsData>();
          String previousPath = settings.toolBackgroundPath;
          if (previousPath != null) {
            final file = File(previousPath);
            if (file.existsSync()) {
              file.deleteSync();
              settings
                ..toolBackgroundPath = null
                ..save();
              EasyLoading.showToast('背景重置成功');
            }
          } else {
            EasyLoading.showToast('已是默认背景');
          }
        },
        onTap: () async {
          File croppedFile;
          try {
            final image = await picker.getImage(source: ImageSource.gallery);
            if (image != null && image.path.isNotEmpty) {
              croppedFile = await cropImage(context, image.path);
            }
            if (croppedFile != null && croppedFile.path.isNotEmpty) {
              String nextPath =
                  (await getApplicationDocumentsDirectory()).path +
                      '/toolImage_${DateTime.now().millisecondsSinceEpoch}';
              final settings = context.read<SettingsData>();
              final previousPath = settings.scoreBackgroundPath;
              if (previousPath != null) {
                final previousFile = File(previousPath);
                if (previousFile.existsSync()) {
                  previousFile.delete();
                }
              }
              final bytes = await croppedFile.readAsBytes();
              File(nextPath).writeAsBytes(bytes).then((value) => settings
                ..toolBackgroundPath
                ..save());
            }
          } catch (e) {
            EasyLoading.showError('背景设置失败');
            Log.logger.e(e.toString());
          }
        },
        trailing: Selector<SettingsData, bool>(
          builder: (_, bool data, __) {
            return NeumorphicSwitch(
              value: data,
              height: 30,
              style: _buildSwitchStyle(),
              onChanged: (value) {
                context.read<SettingsData>()
                  ..showToolBackground = value
                  ..save();
              },
            );
          },
          selector: (_, settingsData) {
            return settingsData.showToolBackground;
          },
        ),
      ),
      Selector<SettingsData, bool>(
        selector: (_, settingsData) => settingsData.autoCheckUpdate,
        builder: (_, data, __) => MySwitch(
          title: Text('自动检查更新'),
          value: data,
          onChanged: (bool value) => context.read<SettingsData>()
            ..autoCheckUpdate = value
            ..save(),
        ),
      ),
      ListTile(
        title: Text('检查更新'),
        onTap: () async {
          EasyLoading.show(status: '请稍等');
          var newVersion = await showCheckVersion(context);
          EasyLoading.dismiss();
          if (!newVersion) {
            EasyLoading.showToast('当前无更新');
          }
        },
        subtitle: FutureBuilder(
          future: PackageInfo.fromPlatform(),
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(
                  child: Text('none'),
                );
                break;
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case ConnectionState.done:
                if (snapshot.hasData) {
                  final packageInfo = snapshot.data;
                  _currentVersion = packageInfo.version;
                  return Text(
                      '版本号：${packageInfo.version} 构建号：${packageInfo.buildNumber}');
                } else {
                  return Text('没有获取到版本信息');
                }
                break;
              default:
                throw UnimplementedError();
            }
          },
        ),
        trailing: Icon(Icons.chevron_right),
        // onTap: () async {
        //   Utils.setEasyLoadingWaitType();
        //   EasyLoading.show(status: '请稍等');
        //   var data;
        //   try {
        //     data = await Global.networkUtils.getServerVersion();
        //     EasyLoading.dismiss();
        //   } on DioError catch (e) {
        //     Global.logger.e(e.message);
        //     EasyLoading.showError(networkError);
        //   } catch (e) {
        //     Global.logger.e(e);
        //     EasyLoading.showError(unknownError);
        //   }
        //   if (data == null) {
        //     return;
        //   }
        //   var buildNumber = data['buildNumber'];
        //   var packageInfo = await PackageInfo.fromPlatform();
        //   var descriptions = data['description'].split('-');
        //   var url = data['downloadUrl'];
        //   if (int.parse(packageInfo.buildNumber, onError: (value) => 0) <
        //       int.parse(buildNumber, onError: (value) => 0)) {
        //     AwesomeDialog(
        //       context: context,
        //       dialogType: DialogType.INFO,
        //       headerAnimationLoop: false,
        //       body: Container(
        //         height: MediaQuery.of(context).size.height / 2 - 100,
        //         child: Column(
        //           children: [
        //             Padding(
        //               padding: const EdgeInsets.all(8.0),
        //               child: Center(
        //                 child: Text(
        //                   '新版本${data['releaseVersion']}',
        //                   style: TextStyle(fontSize: 18),
        //                 ),
        //               ),
        //             ),
        //             Expanded(
        //               child: Padding(
        //                 padding: const EdgeInsets.all(8.0),
        //                 child: ListView.separated(
        //                     physics: BouncingScrollPhysics(),
        //                     itemBuilder: (_, int index) => Padding(
        //                           padding: const EdgeInsets.all(8.0),
        //                           child: Text(
        //                             '${index + 1}.${descriptions[index]}',
        //                             style: TextStyle(fontSize: 16),
        //                           ),
        //                         ),
        //                     separatorBuilder: (_, int index) => Divider(),
        //                     itemCount: descriptions.length),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       btnOkColor: Theme.of(context).primaryColor,
        //       btnCancelColor: Theme.of(context).primaryColor,
        //       btnOkText: '应用内下载',
        //       btnCancelText: '浏览器下载',
        //       btnOkOnPress: () async {
        //         Utils.installApk(url, context);
        //       },
        //       btnCancelOnPress: () async {
        //         if (await canLaunch(url)) {
        //           await launch(url);
        //         } else {
        //           EasyLoading.showToast('打开浏览器遇到问题');
        //         }
        //       },
        //     ).show();
        //   } else {
        //     EasyLoading.showToast('当前无更新');
        //   }
        // },
      ),
      ListTile(
        title: Text('请作者喝杯奶茶'),
        subtitle: Text('如果你觉得本软件不错请支持一下作者'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          var size = MediaQuery.of(context).size;
          AwesomeDialog(
            context: context,
            dialogType: DialogType.NO_HEADER,
            body: Container(
              width: size.width / 4 * 3,
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      "images/pay.png",
                    ),
                  ),
                ],
              ),
            ),
            btnOk: ElevatedButton(
              // color: Theme.of(context).primaryColor,
              child: Text(
                '保存到相册',
                // style: TextStyle(
                //   color: Utils.getReverseForegroundColor(context),
                // ),
              ),
              onPressed: () async {
                var bytes = await rootBundle.load('images/pay.png');
                if (await Permission.storage.isGranted ||
                    await Permission.storage.request().isGranted) {
                  final String result = await ImageGallerySaver.saveImage(
                      bytes.buffer.asUint8List(),
                      name: "pay");
                  if (result.isNotEmpty) {
                    EasyLoading.showToast('保存成功');
                  } else {
                    EasyLoading.showToast('保存失败');
                  }
                } else if (await Permission.storage.isDenied) {
                  EasyLoading.showToast('保存图片需要读写外部存储器权限');
                } else if (await Permission.storage.isPermanentlyDenied) {
                  EasyLoading.showToast('请到设置中开启允许本软件读写外部存储器的权限');
                }
                Navigator.pop(context);
              },
            ),
          ).show();
        },
      ),
      ListTile(
        title: Text('更新日志'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          pushPage(context, LogPage());
        },
      ),
      ListTile(
        title: Text('历史消息'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          pushPage(context, MessageHistory());
        },
      ),
      ListTile(
        title: Text('隐私政策'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          pushPage(context, PrivacyPolicy());
        },
      ),
      ListTile(
        title: Text('许可'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          pushPage(
            context,
            LicensePage(
              applicationIcon: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset(
                  'images/icon.png',
                  width: 80,
                ),
              ),
              applicationVersion: _currentVersion,
              applicationLegalese:
                  "Copyright © 2019-${DateTime.now().year < 2019 ? 2020 : DateTime.now().year} mdreamfever, all rights reserved.",
            ),
          );
        },
      )
    ];
    return config;
  }

  _onTablePropertyTap() {
    final settings = context.read<SettingsData>();
    var initSelectionNumber = settings.initSelectionNumber;
    var initHeight = settings.initHeight;
    var courseMargin = settings.courseMargin;
    var coursePadding = settings.coursePadding;
    var courseCircular = settings.courseCircular;
    var courseFontSize = settings.courseFontSize;
    var shadow = settings.shadow;
    var boxColor = settings.boxColor;
    var backgroundColor = settings.tableBackgroundColor;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      btnOk: ElevatedButton(
        child: Text('确定'),
        onPressed: () {
          final settings = context.read<SettingsData>();
          if (initSelectionNumber != settings.initSelectionNumber) {
            settings.initSelectionNumber = initSelectionNumber;
            final len = initSelectionNumber - settings.timeTable.length;
            for (int i = 0; i < len; ++i) {
              settings.timeTable.add('0:0 0:0');
            }
          }
          if (initHeight != settings.initHeight) {
            settings.initHeight = initHeight;
          }
          if (courseMargin != settings.courseMargin) {
            settings.courseMargin = courseMargin;
          }
          if (coursePadding != settings.coursePadding) {
            settings.coursePadding = coursePadding;
          }
          if (courseCircular != settings.courseCircular) {
            settings.courseCircular = courseCircular;
          }
          if (courseFontSize != settings.courseFontSize) {
            settings.courseFontSize = courseFontSize;
          }
          if (shadow != settings.shadow) {
            settings.shadow = shadow;
          }
          if (boxColor != settings.boxColor) {
            settings.boxColor = boxColor;
          }
          if (backgroundColor != settings.tableBackgroundColor) {
            settings.tableBackgroundColor = backgroundColor;
          }
          settings.save();
          Navigator.pop(context);
        },
      ),
      body: StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Column(
            children: [
              ListTile(
                title: Text('小节'),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: NeumorphicSlider(
                        style: SliderStyle(
                            variant: Theme.of(context).backgroundColor,
                            accent: Theme.of(context).primaryColor),
                        min: 1,
                        max: 30,
                        value: initSelectionNumber.toDouble(),
                        onChanged: (double value) {
                          setState(() {
                            initSelectionNumber = value.toInt();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$initSelectionNumber'.padLeft(2, '0')),
                    )
                  ],
                ),
              ),
              ListTile(
                title: Text('格子高度'),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: NeumorphicSlider(
                        style: SliderStyle(
                            variant: Theme.of(context).backgroundColor,
                            accent: Theme.of(context).primaryColor),
                        min: 30,
                        max: 200,
                        value: initHeight,
                        onChanged: (double value) {
                          setState(() {
                            initHeight = value.toInt().toDouble();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${initHeight.toInt()}'.padLeft(3, '0')),
                    )
                  ],
                ),
              ),
              ListTile(
                title: Text('颜色'),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      child: Text('格子'),
                      onPressed: () {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.NO_HEADER,
                          body: ColorPicker(
                            pickerColor: boxColor,
                            onColorChanged: (Color c) {
                              boxColor = c;
                            },
                            showLabel: true,
                            pickerAreaHeightPercent: 0.8,
                          ),
                          btnOk: ElevatedButton(
                            child: Text('确定'),
                            onPressed: () {
                              // Provider.of<SettingsData>(context,
                              //         listen: false)
                              //     .boxColor = pickerColor;
                              Navigator.pop(context);
                            },
                          ),
                        ).show();
                      },
                    ),
                    OutlinedButton(
                      onPressed: () {
                        AwesomeDialog(
                            context: context,
                            dialogType: DialogType.NO_HEADER,
                            body: ColorPicker(
                              pickerColor: backgroundColor,
                              onColorChanged: (Color c) {
                                backgroundColor = c;
                              },
                              showLabel: true,
                              pickerAreaHeightPercent: 0.8,
                            ),
                            btnOk: ElevatedButton(
                              child: Text('确定'),
                              onPressed: () {
                                // Provider.of<SettingsData>(context,
                                //         listen: false)
                                //     .backgroundColor = pickerColor;
                                Navigator.pop(context);
                              },
                            )).show();
                      },
                      child: Text('背景'),
                    ),
                    Text(
                      '阴影',
                      textAlign: TextAlign.center,
                    ),
                    Checkbox(
                      value: shadow,
                      onChanged: (bool value) {
                        setState(() {
                          shadow = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('margin'),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: NeumorphicSlider(
                        style: SliderStyle(
                            variant: Theme.of(context).backgroundColor,
                            accent: Theme.of(context).primaryColor),
                        min: 0,
                        max: 15,
                        value: courseMargin,
                        onChanged: (double value) {
                          setState(() {
                            courseMargin =
                                double.parse(value.toStringAsFixed(1));
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Text(courseMargin.toStringAsFixed(1).padLeft(4, '0')),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.only(right: courseMargin),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.only(left: courseMargin),
                    )
                  ],
                ),
              ),
              ListTile(
                title: Text('padding'),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: NeumorphicSlider(
                        style: SliderStyle(
                            variant: Theme.of(context).backgroundColor,
                            accent: Theme.of(context).primaryColor),
                        min: 0,
                        max: 15,
                        value: coursePadding,
                        onChanged: (double value) {
                          setState(() {
                            coursePadding =
                                double.parse(value.toStringAsFixed(1));
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          coursePadding.toStringAsFixed(1).padLeft(4, '0')),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      color: Theme.of(context).backgroundColor,
                      padding: EdgeInsets.all(coursePadding),
                      child: Container(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('字体'),
                subtitle: Container(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: NeumorphicSlider(
                          style: SliderStyle(
                              variant: Theme.of(context).backgroundColor,
                              accent: Theme.of(context).primaryColor),
                          min: 5,
                          max: 30,
                          value: courseFontSize,
                          onChanged: (double value) {
                            setState(() {
                              courseFontSize =
                                  double.parse(value.toStringAsFixed(1));
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            courseFontSize.toStringAsFixed(1).padLeft(4, '0')),
                      ),
                      Center(
                        child: Text(
                          '繁星',
                          style: TextStyle(fontSize: courseFontSize),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text('圆角'),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: NeumorphicSlider(
                        style: SliderStyle(
                            variant: Theme.of(context).backgroundColor,
                            accent: Theme.of(context).primaryColor),
                        min: 0,
                        max: 25,
                        value: courseCircular,
                        onChanged: (double value) {
                          setState(() {
                            courseCircular =
                                double.parse(value.toStringAsFixed(1));
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          courseCircular.toStringAsFixed(1).padLeft(4, '0')),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(courseCircular)),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ).show();
  }

  _onAppWidgetPropertyTap() {
    final settings = context.read<SettingsData>();
    var opacity = settings.appWidgetOpacity;
    AwesomeDialog(
        context: context,
        dialogType: DialogType.NO_HEADER,
        body: StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Column(
              children: [
                ListTile(
                  title: Text('透明度'),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: NeumorphicSlider(
                          style: SliderStyle(
                              variant: Theme.of(context).backgroundColor,
                              accent: Theme.of(context).primaryColor),
                          min: 0,
                          max: 255,
                          value: opacity.toDouble(),
                          onChanged: (double value) {
                            setState(() {
                              opacity = value.toInt();
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(opacity.toInt().toString().padLeft(3, '0')),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        btnOk: ElevatedButton(
          child: Text('确定'),
          onPressed: () {
            if (opacity != settings.appWidgetOpacity) {
              settings
                ..appWidgetOpacity = opacity
                ..save();
            }
            Navigator.pop(context);
          },
        )).show();
  }

  _onSystemModeTap() {
    AwesomeDialog(
      context: context,
      title: '选择方式',
      dialogType: DialogType.NO_HEADER,
      body: ScrollConfiguration(
        behavior: FStarOverScrollBehavior(),
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Center(
                child: Text(
                  SystemMode.values[index].name(),
                  style: TextStyle(fontSize: 18),
                ),
              ),
              onTap: () {
                context.read<SettingsData>().systemMode =
                    SystemMode.values[index];
                configRequesterAndParser();
                Navigator.pop(context);
              },
            );
          },
          itemCount: SystemMode.values.length,
        ),
      ),
    ).show();
  }

  void _onSemesterWeekTap() {
    final settings = getSettingsData();
    var week = settings.semesterWeek;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      body: StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Row(
            children: [
              Expanded(
                child: NeumorphicSlider(
                  style: SliderStyle(
                      variant: Theme.of(context).backgroundColor,
                      accent: Theme.of(context).primaryColor),
                  min: 10,
                  max: 30,
                  value: week.toDouble(),
                  onChanged: (double value) {
                    setState(() {
                      week = value.toInt();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(week.toString()),
              ),
            ],
          );
        },
      ),
      btnOk: ElevatedButton(
        onPressed: () {
          final settings = context.read<SettingsData>();
          if (settings.semesterWeek != week) {
            settings
              ..semesterWeek = week
              ..save();
          }
          Navigator.pop(context);
        },
        child: Text('确定'),
      ),
    ).show();
  }
}
