import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';

class NativeCode extends StatefulWidget {
  @override
  State createState() => _NativeCodeState();
}

class _NativeCodeState extends State<NativeCode> {
  final _schoolUrlController = TextEditingController();
  final _preController = TextEditingController();
  final _codeController = TextEditingController();
  final _urlFocusNode = FocusNode();
  final _preFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final directory = await getApplicationDocumentsDirectory();
      final urlPath = directory.path + '/url.js';
      final urlFile = File(urlPath);
      if (urlFile.existsSync()) {
        _schoolUrlController.text = urlFile.readAsStringSync();
      }
      final prePath = directory.path + '/pre.js';
      final preFile = File(prePath);
      if (preFile.existsSync()) {
        _preController.text = preFile.readAsStringSync();
      }
      final codePath = directory.path + '/parse.js';
      final codeFile = File(codePath);
      if (codeFile.existsSync()) {
        _codeController.text = codeFile.readAsStringSync();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _schoolUrlController.dispose();
    _preController.dispose();
    _codeController.dispose();
    _urlFocusNode.dispose();
    _preFocusNode.dispose();
    _codeFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上传解析函数'),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () async {
              _urlFocusNode.unfocus();
              _preFocusNode.unfocus();
              _codeFocusNode.unfocus();
              if (_formKey.currentState.validate()) {
                final url = _schoolUrlController.text.trim();
                final pre = _preController.text.trim();
                final code = _codeController.text.trim();
                final directory = await getApplicationDocumentsDirectory();

                final codePath = directory.path + '/parse.js';
                final codeFile = File(codePath);
                if (!codeFile.existsSync()) {
                  codeFile.createSync();
                }
                codeFile.writeAsString(code).catchError(
                    (error) => EasyLoading.showError(error.toString()));

                final prePath = directory.path + '/pre.js';
                final preFile = File(prePath);
                if (!preFile.existsSync()) {
                  preFile.createSync();
                }
                preFile.writeAsString(pre).catchError(
                    (error) => EasyLoading.showError(error.toString()));

                final urlPath = directory.path + '/url.js';
                final urlFile = File(urlPath);
                if (!urlFile.existsSync()) {
                  urlFile.createSync();
                }
                urlFile.writeAsString(url).catchError(
                    (error) => EasyLoading.showError(error.toString()));
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                controller: _schoolUrlController,
                focusNode: _urlFocusNode,
                maxLines: null,
                validator: (value) {
                  if (value.isEmpty) {
                    return '请输入教务系统网址';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: '教务系统网址',
                  hintText: '必填',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 150),
                child: TextFormField(
                  controller: _preController,
                  focusNode: _preFocusNode,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: '预处理函数',
                    hintText: '可选',
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                    errorBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 300),
                child: TextFormField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  maxLines: null,
                  validator: (value) {
                    if (value.isEmpty) {
                      return '请输入解析函数';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: '解析函数',
                    hintText: '必填',
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                    errorBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
