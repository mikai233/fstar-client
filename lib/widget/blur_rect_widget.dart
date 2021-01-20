import 'dart:ui';

import 'package:flutter/material.dart';

class BlurRectWidget extends StatelessWidget {
  final Widget widget;
  final double padding;

  BlurRectWidget({@required this.widget, this.padding = 10})
      : assert(widget != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: Container(
            color: Colors.white10,
            padding: EdgeInsets.all(padding),
            child: widget,
          ),
        ),
      ),
    );
  }
}
