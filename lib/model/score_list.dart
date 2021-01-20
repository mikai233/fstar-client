import 'package:flutter/cupertino.dart';
import 'package:fstar/model/score_data.dart';
import 'package:hive/hive.dart';

part 'score_list.g.dart';

@HiveType(typeId: 14)
class ScoreList extends HiveObject with ChangeNotifier {
  @HiveField(0)
  List<ScoreData> _list = [];

  List<ScoreData> get list => _list;

  set list(List<ScoreData> value) {
    _list = value;
    notifyListeners();
  }
}
