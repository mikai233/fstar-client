import 'package:hive/hive.dart';

part 'fstar_mode_enum.g.dart';

//课表模式
@HiveType(typeId: 6)
enum FStarMode {
  @HiveField(0)
  JUST, //江苏科技大学
  @HiveField(1)
  ThirdParty, //通用课表模式
}

extension modeName on FStarMode {
  String name() {
    var modeName = '';
    switch (this.index) {
      case 0:
        modeName = 'JUST模式';
        break;
      case 1:
        modeName = '通用模式';
        break;
      default:
        throw UnimplementedError();
    }
    return modeName;
  }
}
