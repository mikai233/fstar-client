import 'dart:async';

import 'package:flutter/material.dart';

class TimerCountDownButton extends StatefulWidget {
  final Function onFinish;
  final VoidCallback onPressed;

  TimerCountDownButton({Key key, this.onFinish, @required this.onPressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimerCountDownButtonState();
}

class _TimerCountDownButtonState extends State<TimerCountDownButton> {
  Timer _timer;
  int _countdownTime = 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(45.0),
        ),
      ),
      child: Text(
        _countdownTime > 0 ? '$_countdownTime' : '确定',
      ),
      onPressed: _countdownTime > 0 ? null : widget.onPressed,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_countdownTime == 0) {
        setState(() {
          _countdownTime = 5;
        });
        //开始倒计时
        startCountdownTimer();
      }
    });
  }

  void startCountdownTimer() {
    _timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer timer) => {
              setState(() {
                if (_countdownTime < 1) {
                  if (widget.onFinish != null) {
                    widget.onFinish();
                  }
                  _timer.cancel();
                } else {
                  _countdownTime = _countdownTime - 1;
                }
              })
            });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }
}
