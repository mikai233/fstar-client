import 'package:hive/hive.dart';

part 'identity_enum.g.dart';

//用户身份
@HiveType(typeId: 5)
enum IdentityType {
  @HiveField(0)
  undergraduate,
  @HiveField(1)
  graduate,
  // @HiveField(2)
  // teacher,
}

extension typeName on IdentityType {
  String name() {
    var name = '';
    switch (this.index) {
      case 0:
        name = '本科生';
        break;
      case 1:
        name = '研究生';
        break;
      case 2:
        name = '教师(未实现)';
        break;
      default:
        throw UnimplementedError();
    }
    return name;
  }
}
