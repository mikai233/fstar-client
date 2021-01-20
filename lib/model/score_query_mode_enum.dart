import 'package:hive/hive.dart';

part 'score_query_mode_enum.g.dart';

@HiveType(typeId: 13)
enum ScoreQueryMode {
  @HiveField(0)
  DEFAULT, //默认入口
  @HiveField(1)
  ALTERNATIVE, //成绩替代入口
}

extension modeName on ScoreQueryMode {
  String name() {
    var name = '';
    switch (this.index) {
      case 0:
        name = '默认';
        break;
      case 1:
        name = '成绩替代';
        break;
      default:
        throw UnimplementedError();
    }
    return name;
  }
}
