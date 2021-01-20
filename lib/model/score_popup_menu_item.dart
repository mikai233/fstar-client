enum ScorePopupMenuItem {
  BX, //必修
  BXRX, //必修 任选
  ALL, //全部
  MANUAL1, //自选 分学期
  MANUAL2, //自选 跨学期
  INFO, //计算说明
  RANK, //排名
  EXPORT, //导出成绩
}

extension modeName on ScorePopupMenuItem {
  String name() {
    var name = '';
    switch (this.index) {
      case 0:
        name = '必修';
        break;
      case 1:
        name = '必修任选';
        break;
      case 2:
        name = '全部';
        break;
      case 3:
        name = '自选(分学期)';
        break;
      case 4:
        name = '自选(跨学期)';
        break;
      case 5:
        name = '计算说明';
        break;
      case 6:
        name = '排名';
        break;
      case 7:
        name = '导出成绩';
        break;
      default:
        throw UnimplementedError();
    }
    return name;
  }
}
