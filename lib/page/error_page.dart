import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          '该页面不存在',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
