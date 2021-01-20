import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fstar/utils/utils.dart';

class MySwitch extends StatelessWidget {
  final bool value;
  final Widget title;
  final ValueChanged<bool> onChanged;

  const MySwitch({Key key, this.value, this.title, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ListTile(
      title: title,
      trailing: NeumorphicSwitch(
          style: NeumorphicSwitchStyle(
            inactiveTrackColor:
                isDarkMode(context) ? Theme.of(context).backgroundColor : null,
            activeTrackColor: isDarkMode(context)
                ? Theme.of(context).accentColor
                : Theme.of(context).primaryColor,
          ),
          height: 30,
          value: value,
          onChanged: onChanged),
      onTap: onChanged != null
          ? () {
              onChanged(!value);
            }
          : null);
}
