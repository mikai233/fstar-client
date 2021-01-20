import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fstar/model/fstar_mode_enum.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/utils/utils.dart';
import 'package:provider/provider.dart';

class TimeTable extends StatefulWidget {
  @override
  State createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上课时间'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_time),
            onPressed: () {
              switch (getSettingsData().fStarMode) {
                case FStarMode.JUST:
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.NO_HEADER,
                    body: Column(
                      children: [
                        ListTile(
                          title: Text('长山校区'),
                          onTap: () {
                            final settings = context.read<SettingsData>();
                            final table = settings.timeTable;
                            table
                              ..removeRange(0, 10)
                              ..insertAll(0, [
                                '8:30 9:15',
                                '9:20 10:05',
                                '10:25 11:10',
                                '11:15 12:00',
                                '13:30 14:15',
                                '14:20 15:05',
                                '15:25 16:10',
                                '16:15 17:00',
                                '18:30 19:15',
                                '19:20 20:05'
                              ]);
                            settings
                              ..timeTable = table
                              ..save();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text('梦溪/张家港校区'),
                          onTap: () {
                            final settings = context.read<SettingsData>();
                            final table = settings.timeTable;
                            table
                              ..removeRange(0, 11)
                              ..insertAll(0, [
                                '8:00 8:45',
                                '9:55 9:40',
                                '10:00 10:45',
                                '10:55 11:40',
                                '14:00 14:45',
                                '14:55 15:40',
                                '15:50 16:35',
                                '16:45 17:30',
                                '19:00 19:45',
                                '19:55 20:40',
                                '20:50 21:35',
                              ]);
                            settings
                              ..timeTable = table
                              ..save();
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  ).show();
                  break;
                case FStarMode.ThirdParty:
                  // TODO: Handle this case.
                  break;
              }
            },
          )
        ],
      ),
      body: Selector<SettingsData, List<String>>(
        selector: (context, value) => value.timeTable,
        shouldRebuild: (pre, next) => true,
        builder: (context, timeTable, child) {
          return ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              return StatefulBuilder(
                builder: (BuildContext context,
                    void Function(void Function()) setState) {
                  var time = timeTable[index].split(' ');
                  var sBeginHour = time[0].split(':')[0];
                  var sBeginMinute = time[0].split(':')[1];
                  var sEndHour = time[1].split(':')[0];
                  var sEndMinute = time[1].split(':')[1];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            '第${index + 1}节',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          child: Text('开始时间'),
                          onPressed: () async {
                            final begin = await showTimePicker(
                                context: context,
                                initialTime: _parseTimeOfDay(time[0]));
                            sBeginHour = begin.hour.toString();
                            sBeginMinute = begin.minute.toString();
                            setState(() {
                              timeTable[index] =
                                  '$sBeginHour:$sBeginMinute $sEndHour:$sEndMinute';
                            });
                            context.read<SettingsData>()
                              ..timeTable = timeTable
                              ..save();
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${sBeginHour.padLeft(2, '0')}:${sBeginMinute.padLeft(2, '0')}',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          child: Text('结束时间'),
                          onPressed: () async {
                            final end = await showTimePicker(
                                context: context,
                                initialTime: _parseTimeOfDay(time[1]));
                            sEndHour = end.hour.toString();
                            sEndMinute = end.minute.toString();
                            setState(() {
                              timeTable[index] =
                                  '$sBeginHour:$sBeginMinute $sEndHour:$sEndMinute';
                            });
                            context.read<SettingsData>()
                              ..timeTable = timeTable
                              ..save();
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${sEndHour.padLeft(2, '0')}:${sEndMinute.padLeft(2, '0')}',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemCount: timeTable.length,
          );
        },
      ),
    );
  }

  TimeOfDay _parseTimeOfDay(String stringTime) {
    final beginEnd = stringTime.split(':');
    var sBeginHour = beginEnd[0];
    var sBeginMinute = beginEnd[1];
    return TimeOfDay(
        hour: int.parse(sBeginHour) ?? 0, minute: int.parse(sBeginMinute) ?? 0);
  }
}
