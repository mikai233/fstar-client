import 'package:flutter/material.dart';
import 'package:fstar/model/date_today_data.dart';
import 'package:fstar/model/settings_data.dart';
import 'package:fstar/model/time_array_data.dart';
import 'package:fstar/model/week_index_data.dart';
import 'package:fstar/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class WeekHeader extends StatefulWidget {
  @override
  State createState() => _WeekHeaderState();
}

class _WeekHeaderState extends State<WeekHeader> {
  final _duration = Duration(milliseconds: 375);

  @override
  Widget build(BuildContext context) {
    return Consumer3<WeekIndexData, TimeArrayData, DateTodayData>(builder:
        (BuildContext context, weekIndex, timeArray, dateToday, Widget child) {
      return Container(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Text(
                      _buildMonthText(
                          timeArrayData: timeArray,
                          weekIndexData: weekIndex,
                          todayData: dateToday),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
            ),
            Selector<SettingsData, Tuple2<bool, bool>>(
              selector: (_, data) => Tuple2(data.showSaturday, data.showSunday),
              builder: (BuildContext context, value, Widget child) => Expanded(
                flex: _buildFlex(value.item1, value.item2),
                child: Row(
                  children: _buildItems(
                      context: context,
                      weekIndexData: weekIndex,
                      todayData: dateToday,
                      timeArrayData: timeArray,
                      saturday: value.item1,
                      sunday: value.item2),
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  _buildDecoration(
      {@required BuildContext context,
      @required int appbarIndex,
      @required DateTime today,
      @required List<DateTime> timeArray,
      @required int index}) {
    var positionalDate = timeArray[appbarIndex * 7 + index - 1];
    return BoxDecoration(
      color: sameDay(positionalDate, today)
          ? Theme.of(context).primaryColor
          : null,
      borderRadius: BorderRadius.circular(5),
    );
  }

  TextStyle _buildTextStyle(
      {@required BuildContext context,
      @required int appbarIndex,
      @required DateTime today,
      @required List<DateTime> timeArray,
      @required int index}) {
    var positionalDate = timeArray[appbarIndex * 7 + index - 1];
    if (sameDay(positionalDate, today)) {
      return TextStyle(color: getReverseForegroundColor(context));
    } else
      return isDarkMode(context)
          ? TextStyle(color: Colors.white)
          : TextStyle(color: Colors.black);
  }

  int _buildFlex(bool saturday, bool sunday) {
    var flex = 2 * 7;
    if (!saturday) {
      flex -= 2;
    }
    if (!sunday) {
      flex -= 2;
    }
    return flex;
  }

  _buildItems(
      {@required BuildContext context,
      @required WeekIndexData weekIndexData,
      @required DateTodayData todayData,
      @required TimeArrayData timeArrayData,
      @required bool saturday,
      @required bool sunday}) {
    return List.generate(7, (index) => index)
        .where((index) =>
            index >= 0 && index <= 4 ||
            saturday && index == 5 ||
            sunday && index == 6)
        .map(
          (index) => Expanded(
            child: AnimatedContainer(
              decoration: _buildDecoration(
                  context: context,
                  appbarIndex: weekIndexData.index,
                  today: todayData.now,
                  timeArray: timeArrayData.array,
                  index: index + 1),
              duration: _duration,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: indexWeekToStringWeek(index + 1),
                    ),
                    TextSpan(
                      text:
                          "\n${timeArrayData.array[weekIndexData.index * 7 + index].day}",
                    ),
                  ],
                  style: _buildTextStyle(
                      context: context,
                      appbarIndex: weekIndexData.index,
                      today: todayData.now,
                      timeArray: timeArrayData.array,
                      index: index + 1),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
        .toList();
  }

  String _buildMonthText(
      {@required TimeArrayData timeArrayData,
      @required WeekIndexData weekIndexData,
      @required DateTodayData todayData}) {
    var currentWeek = getCurrentWeek();
    if (currentWeek == weekIndexData.index) {
      return '${DateTime.now().month}\n月';
    } else {
      return '${timeArrayData.array[weekIndexData.index * 7].month}\n月';
    }
  }
}

// class _WeekHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final height = 40.0;
//   final _duration = Duration(milliseconds: 375);
//
//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Consumer3<WeekIndexData, TimeArrayData, DateTodayData>(builder:
//         (BuildContext context, weekIndex, timeArray, dateToday, Widget child) {
//       return Container(
//         height: 50,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Expanded(
//               flex: 1,
//               child: Container(
//                 child: Column(
//                   children: <Widget>[
//                     Text(
//                       _buildMonthText(
//                           timeArrayData: timeArray,
//                           weekIndexData: weekIndex,
//                           todayData: dateToday),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                   mainAxisAlignment: MainAxisAlignment.center,
//                 ),
//               ),
//             ),
//             Selector<SettingsData, Tuple2<bool, bool>>(
//               selector: (_, data) => Tuple2(data.saturday, data.sunday),
//               builder: (BuildContext context, value, Widget child) => Expanded(
//                 flex: _buildFlex(value.item1, value.item2),
//                 child: Row(
//                   children: _buildItems(
//                       context: context,
//                       weekIndexData: weekIndex,
//                       todayData: dateToday,
//                       timeArrayData: timeArray,
//                       saturday: value.item1,
//                       sunday: value.item2),
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
//
//   @override
//   bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
//     return minExtent != oldDelegate.minExtent ||
//         maxExtent != oldDelegate.maxExtent;
//   }
//
//   @override
//   double get maxExtent {
//     return height;
//   }
//
//   @override
//   double get minExtent {
//     return height;
//   }
//
//   _buildDecoration(
//       {@required BuildContext context,
//       @required int appbarIndex,
//       @required DateTime today,
//       @required List<DateTime> timeArray,
//       @required int index}) {
//     var positionalDate = timeArray[appbarIndex * 7 + index - 1];
//     return BoxDecoration(
//       color: sameDay(positionalDate, today)
//           ? Theme.of(context).primaryColor
//           : null,
//       borderRadius: BorderRadius.circular(5),
//     );
//   }
//
//   TextStyle _buildTextStyle(
//       {@required BuildContext context,
//       @required int appbarIndex,
//       @required DateTime today,
//       @required List<DateTime> timeArray,
//       @required int index}) {
//     var positionalDate = timeArray[appbarIndex * 7 + index - 1];
//     if (sameDay(positionalDate, today)) {
//       return TextStyle(color: getReverseForegroundColor(context));
//     } else
//       return isDarkMode(context)
//           ? TextStyle(color: Colors.white)
//           : TextStyle(color: Colors.black);
//   }
//
//   int _buildFlex(bool saturday, bool sunday) {
//     var flex = 2 * 7;
//     if (!saturday) {
//       flex -= 2;
//     }
//     if (!sunday) {
//       flex -= 2;
//     }
//     return flex;
//   }
//
//   _buildItems(
//       {@required BuildContext context,
//       @required WeekIndexData weekIndexData,
//       @required DateTodayData todayData,
//       @required TimeArrayData timeArrayData,
//       @required bool saturday,
//       @required bool sunday}) {
//     return List.generate(7, (index) => index)
//         .where((index) =>
//             index >= 0 && index <= 4 ||
//             saturday && index == 5 ||
//             sunday && index == 6)
//         .map(
//           (index) => Expanded(
//             child: AnimatedContainer(
//               decoration: _buildDecoration(
//                   context: context,
//                   appbarIndex: weekIndexData.index,
//                   today: todayData.now,
//                   timeArray: timeArrayData.array,
//                   index: index + 1),
//               duration: _duration,
//               child: Text.rich(
//                 TextSpan(
//                   children: [
//                     TextSpan(
//                       text: indexWeekToStringWeek(index + 1),
//                     ),
//                     TextSpan(
//                       text:
//                           "\n${timeArrayData.array[weekIndexData.index * 7 + index].day}",
//                     ),
//                   ],
//                   style: _buildTextStyle(
//                       context: context,
//                       appbarIndex: weekIndexData.index,
//                       today: todayData.now,
//                       timeArray: timeArrayData.array,
//                       index: index + 1),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         )
//         .toList();
//   }
//
//   String _buildMonthText(
//       {@required TimeArrayData timeArrayData,
//       @required WeekIndexData weekIndexData,
//       @required DateTodayData todayData}) {
//     var currentWeek = getCurrentWeek();
//     if (currentWeek == weekIndexData.index) {
//       return '${DateTime.now().month}\n月';
//     } else {
//       return '${timeArrayData.array[weekIndexData.index * 7].month}\n月';
//     }
//   }
// }
