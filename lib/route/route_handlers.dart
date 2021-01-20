import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fstar/page/error_page.dart';
import 'package:fstar/page/fstar_home_page.dart';
import 'package:fstar/page/settings_page.dart';
import 'package:fstar/page/time_table.dart';
import 'package:fstar/page/tool_page.dart';

final homeHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) =>
        FStarHomePage());
final timeTableHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) =>
        TimeTable());
final toolHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) =>
        ToolPage());
final settingsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) =>
        SettingsPage());
final errorHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) =>
        ErrorPage());
