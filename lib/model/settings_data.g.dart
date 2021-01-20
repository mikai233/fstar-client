// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsDataAdapter extends TypeAdapter<SettingsData> {
  @override
  final int typeId = 1;

  @override
  SettingsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsData()
      .._onlyShowThisWeek = fields[0] as bool
      .._showCourseBackground = fields[1] as bool
      .._courseBackgroundPath = fields[2] as String
      .._showScoreBackground = fields[3] as bool
      .._scoreBackgroundPath = fields[4] as String
      .._showToolBackground = fields[5] as bool
      .._toolBackgroundPath = fields[6] as String
      .._reverseScore = fields[7] as bool
      .._autoCheckUpdate = fields[8] as bool
      .._tableScrollable = fields[9] as bool
      .._semesterList = (fields[10] as List)?.cast<String>()
      .._currentSemester = fields[11] as String
      .._refreshTablePerDay = fields[12] as bool
      .._semesterWeek = fields[13] as int
      .._avatarPath = fields[14] as String
      .._lastRefreshAt = fields[15] as DateTime
      .._scoreDisplayMode = fields[16] as ScoreDisplayMode
      .._saveScoreCloud = fields[17] as bool
      .._systemMode = fields[18] as SystemMode
      .._campus = fields[19] as String
      .._timeTable = (fields[20] as List)?.cast<String>()
      .._initHeight = fields[21] as double
      .._initSelectionNumber = fields[22] as int
      .._showSaturday = fields[23] as bool
      .._showSunday = fields[24] as bool
      .._courseCircular = fields[25] as double
      .._appWidgetOpacity = fields[26] as int
      .._courseMargin = fields[27] as double
      .._coursePadding = fields[28] as double
      .._courseFontSize = fields[29] as double
      .._fStarMode = fields[30] as FStarMode
      .._unusedCourseColorIndex = fields[31] as int
      .._boxColor = fields[32] as Color
      .._tableBackgroundColor = fields[33] as Color
      .._shadow = fields[34] as bool
      .._identityType = fields[35] as IdentityType
      .._tableMode = fields[36] as TableMode
      .._beginTime = fields[37] as DateTime
      .._scoreQueryMode = fields[38] as ScoreQueryMode
      .._scoreQuerySemester = fields[39] as String
      .._isNewUser = fields[40] as bool
      .._dayFlag = fields[41] as DateTime;
  }

  @override
  void write(BinaryWriter writer, SettingsData obj) {
    writer
      ..writeByte(42)
      ..writeByte(0)
      ..write(obj._onlyShowThisWeek)
      ..writeByte(1)
      ..write(obj._showCourseBackground)
      ..writeByte(2)
      ..write(obj._courseBackgroundPath)
      ..writeByte(3)
      ..write(obj._showScoreBackground)
      ..writeByte(4)
      ..write(obj._scoreBackgroundPath)
      ..writeByte(5)
      ..write(obj._showToolBackground)
      ..writeByte(6)
      ..write(obj._toolBackgroundPath)
      ..writeByte(7)
      ..write(obj._reverseScore)
      ..writeByte(8)
      ..write(obj._autoCheckUpdate)
      ..writeByte(9)
      ..write(obj._tableScrollable)
      ..writeByte(10)
      ..write(obj._semesterList)
      ..writeByte(11)
      ..write(obj._currentSemester)
      ..writeByte(12)
      ..write(obj._refreshTablePerDay)
      ..writeByte(13)
      ..write(obj._semesterWeek)
      ..writeByte(14)
      ..write(obj._avatarPath)
      ..writeByte(15)
      ..write(obj._lastRefreshAt)
      ..writeByte(16)
      ..write(obj._scoreDisplayMode)
      ..writeByte(17)
      ..write(obj._saveScoreCloud)
      ..writeByte(18)
      ..write(obj._systemMode)
      ..writeByte(19)
      ..write(obj._campus)
      ..writeByte(20)
      ..write(obj._timeTable)
      ..writeByte(21)
      ..write(obj._initHeight)
      ..writeByte(22)
      ..write(obj._initSelectionNumber)
      ..writeByte(23)
      ..write(obj._showSaturday)
      ..writeByte(24)
      ..write(obj._showSunday)
      ..writeByte(25)
      ..write(obj._courseCircular)
      ..writeByte(26)
      ..write(obj._appWidgetOpacity)
      ..writeByte(27)
      ..write(obj._courseMargin)
      ..writeByte(28)
      ..write(obj._coursePadding)
      ..writeByte(29)
      ..write(obj._courseFontSize)
      ..writeByte(30)
      ..write(obj._fStarMode)
      ..writeByte(31)
      ..write(obj._unusedCourseColorIndex)
      ..writeByte(32)
      ..write(obj._boxColor)
      ..writeByte(33)
      ..write(obj._tableBackgroundColor)
      ..writeByte(34)
      ..write(obj._shadow)
      ..writeByte(35)
      ..write(obj._identityType)
      ..writeByte(36)
      ..write(obj._tableMode)
      ..writeByte(37)
      ..write(obj._beginTime)
      ..writeByte(38)
      ..write(obj._scoreQueryMode)
      ..writeByte(39)
      ..write(obj._scoreQuerySemester)
      ..writeByte(40)
      ..write(obj._isNewUser)
      ..writeByte(41)
      ..write(obj._dayFlag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
