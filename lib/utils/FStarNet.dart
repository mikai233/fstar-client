import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fstar/model/client_data.dart';
import 'package:fstar/model/f_result.dart';
import 'package:fstar/model/parse_config_data.dart';
import 'package:fstar/model/score_data.dart';
import 'package:fstar/utils/utils.dart';

class FStarNet {
  static final FStarNet _singleton = FStarNet._internal();

  factory FStarNet() => _singleton;
  Dio _dio;

  FStarNet._internal() {
    _dio = Dio();
    _dio.options = BaseOptions(
        contentType: ContentType.json.value,
        connectTimeout: 5000,
        // baseUrl: 'http://10.0.2.2:3939',
        baseUrl: 'https://mdreamfever.com:9009'
        // baseUrl: 'http://192.168.1.103:8080'
        );
    (_dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    // (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (client) {
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) {
    //     return true;
    //   };
    // };
  }

  void setHeader(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  Future<FResult> getChangelog() async {
    var response = await _dio.get('/v2/changelog');
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> getClassScore(String classNumber) async {
    var response = await _dio.get('/v2/score/class/$classNumber');
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> uploadScore(List<ScoreData> score) async {
    final user = getUserData();
    var response = await _dio.post('/v2/score',
        data: score
            .map((e) => e.toMap()
              ..addAll(<String, String>{
                'studentNumber': user.userNumber,
              }))
            .toList());
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> checkVersion() async {
    var response = await _dio.get('/v2/changelog/current_version');
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> getCurrentMessage(int buildNumber) async {
    var response = await _dio.get('/v2/message/latest',
        queryParameters: {'buildNumber': buildNumber});
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> getAllMessage() async {
    var response = await _dio.get('/v2/message');
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> updateStatus(ClientData clientData) async {
    var response =
        await _dio.post('/v2/service/vitality', data: clientData.toMap());
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> getJustSchoolBus() async {
    var response = await _dio.get('/v2/service/just/school_bus');
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> getJustSchoolCalendar() async {
    var response = await _dio.get('/v2/service/just/school_calendar');
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> getUploadToken(String key) async {
    var response = await _dio
        .get('/v2/service/upload_token', queryParameters: {'key': key});
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> getCourseParseConfig(
      {@required int page, @required int size}) async {
    var response = await _dio.get('/v2/service/config',
        queryParameters: {'page': page, 'size': size});
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> getCourseParseConfigBySchoolName(String schoolName) async {
    var response = await _dio.get('/v2/service/config/school/$schoolName');
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> login(
      {@required String username, @required String password}) async {
    var response = await _dio
        .post('/v2/auth', data: {'username': username, 'password': password});
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> register(
      {@required String username, @required String password}) async {
    var response = await _dio.post('/v2/auth/register',
        data: {'username': username, 'password': password});
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> addConfig(ParseConfigData parseConfigData) async {
    var response =
        await _dio.post('/v2/service/config', data: parseConfigData.toMap());
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> getCodeHost() async {
    var response = await _dio.get('/v2/service/code_host');
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> getConfigByUsername() async {
    var response = await _dio.get('/v2/service/config/user');
    var result = FResult.fromMap(response.data);
    return result;
  }

  Future<FResult> deleteConfigById(int id) async {
    var response =
        await _dio.delete('/v2/service/config', queryParameters: {'id': id});
    var result = FResult.fromMap(response.data);
    return result;
  }
}
