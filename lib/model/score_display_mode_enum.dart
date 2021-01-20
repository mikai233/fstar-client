import 'package:hive/hive.dart';

part 'score_display_mode_enum.g.dart';

@HiveType(typeId: 12)
enum ScoreDisplayMode {
  @HiveField(0)
  ALL,
  @HiveField(1)
  MAX,
}

extension displayProperty on ScoreDisplayMode {
  String property() {
    var propertyValue = '';
    switch (this.index) {
      case 0:
        propertyValue = 'all';
        break;
      case 1:
        propertyValue = 'max';
        break;
      default:
        throw UnimplementedError();
    }
    return propertyValue;
  }

  String description() {
    var descriptionValue = '';
    switch (this.index) {
      case 0:
        descriptionValue = '全部成绩';
        break;
      case 1:
        descriptionValue = '最好成绩';
        break;
      default:
        throw UnimplementedError();
    }
    return descriptionValue;
  }
}
