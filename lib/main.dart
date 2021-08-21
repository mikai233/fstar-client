import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fstar/model/box_name.dart';
import 'package:fstar/model/color_adapter.dart';
import 'package:fstar/model/course_data.dart';
import 'package:fstar/model/course_map.dart';
import 'package:fstar/model/datetime_adapter.dart';
import 'package:fstar/model/fstar_mode_enum.dart';
import 'package:fstar/model/identity_enum.dart';
import 'package:fstar/model/score_data.dart';
import 'package:fstar/model/score_display_mode_enum.dart';
import 'package:fstar/model/score_list.dart';
import 'package:fstar/model/score_query_mode_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/system_mode_enum.dart';
import 'package:fstar/model/table_mode_enum.dart';
import 'package:fstar/model/theme_color_data.dart';
import 'package:fstar/model/user_data.dart';
import 'package:fstar/page/fstar_home_page.dart';
import 'package:fstar/page/import_setting_page.dart';
import 'package:fstar/page/jw_login_page.dart';
import 'package:fstar/page/privacy_policy_page.dart';
import 'package:fstar/page/settings_page.dart';
import 'package:fstar/page/time_table.dart';
import 'package:fstar/utils/utils.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

Map<String, Object> boxMap = {
  BoxName.userBox: UserData(),
  BoxName.themeBox: ThemeColorData(),
  BoxName.courseBox: CourseMap(),
  BoxName.scoreBox: ScoreList(),
  BoxName.settingsBox: SettingsData(),
};

void main() async {
  Provider.debugCheckInvalidValueType = null;
  try {
    await _initHive();
    _initHiveAdapter();
    await _openHiveBox(boxMap.keys);
    _initBoxValue();
    _setRefreshRate().catchError(print);
    _setScreenFeature();
    configRequesterAndParser();
    _configEasyLoading();
  } catch (e) {
    //ignore
    print(e);
  }
  runApp(FStarApp());
}

class FStarApp extends StatelessWidget {
  final _themeData = getBoxData<ThemeColorData>(BoxName.themeBox);
  final _settingsData = getBoxData<SettingsData>(BoxName.settingsBox);
  final _courseMap = getBoxData<CourseMap>(BoxName.courseBox);
  final _userData = getBoxData<UserData>(BoxName.userBox);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeData),
        ChangeNotifierProvider.value(value: _settingsData),
        ChangeNotifierProvider.value(value: _courseMap),
        ChangeNotifierProvider.value(value: _userData),
        //不可以用下面的方式创建继承自HiveObject类的对象
        //当页面销毁的时候该对象也会被Provider调用dispose
        //当页面再次创建的时候使用的是box中已经dispose的对象
        // ChangeNotifierProvider(create: (_) {
        //   return getBoxData<CourseMap>(BoxName.courseBox);
        // })
      ],
      builder: (BuildContext context, Widget child) => ScreenUtilInit(
        designSize: Size(1440, 2560),
        builder: () => MaterialApp(
          debugShowCheckedModeBanner: false,
          // checkerboardOffscreenLayers: true,
          // checkerboardRasterCacheImages: true,
          title: '繁星课程表',
          theme: ThemeData(
            primarySwatch:
                Colors.primaries[context.watch<ThemeColorData>().index],
            pageTransitionsTheme: _createPageTransitionsTheme(),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            pageTransitionsTheme: _createPageTransitionsTheme(),
          ),
          routes: <String, WidgetBuilder>{
            '/': (context) => FStarHomePage(),
            'setting': (context) => SettingsPage(),
            'timeTable': (_) => TimeTable(),
            'importSetting': (_) => ImportSetting(),
            'privacyPolicy': (_) => PrivacyPolicy(),
            'jwLogin': (_) => JwLogin(),
          },
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            RefreshLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('zh', 'CH'),
            const Locale('en', 'US'),
          ],
          builder: (BuildContext context, Widget child) =>
              FlutterEasyLoading(child: child),
        ),
      ),
    );
  }

  _createPageTransitionsTheme() {
    return PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder()
      },
    );
  }
}

//初始化Hive
Future<void> _initHive() async {
  var platform = getCurrentPlatform();
  switch (platform) {
    case FPlatform.android:
    case FPlatform.iOS:
      await Hive.initFlutter();
      break;
    case FPlatform.fuchsia:
    case FPlatform.linux:
    case FPlatform.macOS:
    case FPlatform.windows:
      Directory current = Directory.current;
      Hive.init(current.path + '/data/');
      break;
    case FPlatform.web:
      throw UnimplementedError();
  }
}

//初始化Hive适配器
void _initHiveAdapter() {
  Hive
    ..registerAdapter(UserDataAdapter())
    ..registerAdapter(ThemeColorDataAdapter())
    ..registerAdapter(SettingsDataAdapter())
    ..registerAdapter(ColorAdapter())
    ..registerAdapter(DateTimeAdapter())
    ..registerAdapter(IdentityTypeAdapter())
    ..registerAdapter(SystemModeAdapter())
    ..registerAdapter(FStarModeAdapter())
    ..registerAdapter(ScoreQueryModeAdapter())
    ..registerAdapter(ScoreDisplayModeAdapter())
    ..registerAdapter(CourseMapAdapter())
    ..registerAdapter(ScoreDataAdapter())
    ..registerAdapter(ScoreListAdapter())
    ..registerAdapter(TableModeAdapter())
    ..registerAdapter(CourseDataAdapter());
}

Future<void> _openHiveBox(Iterable<String> boxes) async {
  var boxesOpenFuture = boxes.map((boxName) => Hive.openBox(boxName));
  await Future.wait(boxesOpenFuture);
}

//设置一加高分屏刷频率
Future<void> _setRefreshRate() async {
  var platform = getCurrentPlatform();
  if (platform == FPlatform.android) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.brand == 'OnePlus') {
      await FlutterDisplayMode.setHighRefreshRate();
    }
  }
}

void _initBoxValue() {
  boxMap.forEach((key, value) {
    var box = Hive.box(key);
    if (box.isEmpty) {
      box.add(value);
    }
  });
}

//设置状态栏透明
void _setScreenFeature() {
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

void _configEasyLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..indicatorSize = 80;
}
