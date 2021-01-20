import 'package:hive/hive.dart';

part 'system_mode_enum.g.dart';

//江苏科技大学教务系统访问模式
@HiveType(typeId: 9)
enum SystemMode {
  @HiveField(0)
  JUST,
  @HiveField(1)
  VPN,
  @HiveField(2)
  VPN2,
  @HiveField(3)
  CLOUD,
}

extension modeName on SystemMode {
  String name() {
    var modeName = '';
    switch (this.index) {
      case 0:
        modeName = '常规模式';
        break;
      case 1:
        modeName = 'VPN模式';
        break;
      case 2:
        modeName = 'VPN2模式(未实现)';
        break;
      case 3:
        modeName = '云模式(未实现)';
        break;
      default:
        throw UnimplementedError();
    }
    return modeName;
  }
}
