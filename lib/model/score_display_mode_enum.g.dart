// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_display_mode_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreDisplayModeAdapter extends TypeAdapter<ScoreDisplayMode> {
  @override
  final int typeId = 12;

  @override
  ScoreDisplayMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScoreDisplayMode.ALL;
      case 1:
        return ScoreDisplayMode.MAX;
      default:
        return ScoreDisplayMode.ALL;
    }
  }

  @override
  void write(BinaryWriter writer, ScoreDisplayMode obj) {
    switch (obj) {
      case ScoreDisplayMode.ALL:
        writer.writeByte(0);
        break;
      case ScoreDisplayMode.MAX:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreDisplayModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
