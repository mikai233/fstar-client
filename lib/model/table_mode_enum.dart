import 'package:hive/hive.dart';

part 'table_mode_enum.g.dart';

//课表展示风格
@HiveType(typeId: 11)
enum TableMode {
  @HiveField(0)
  A,
  @HiveField(1)
  B,
  @HiveField(2)
  C,
}

extension modeName on TableMode {
  String name() {
    var modeName = '';
    switch (this.index) {
      case 0:
        modeName = 'A';
        break;
      case 1:
        modeName = 'B';
        break;
      case 2:
        modeName = 'C';
        break;
      case 3:
        break;
      default:
        throw UnimplementedError();
    }
    return modeName;
  }
}
