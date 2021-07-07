// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_query_mode_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreQueryModeAdapter extends TypeAdapter<ScoreQueryMode> {
  @override
  final int typeId = 13;

  @override
  ScoreQueryMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScoreQueryMode.DEFAULT;
      case 1:
        return ScoreQueryMode.ALTERNATIVE;
      default:
        return ScoreQueryMode.DEFAULT;
    }
  }

  @override
  void write(BinaryWriter writer, ScoreQueryMode obj) {
    switch (obj) {
      case ScoreQueryMode.DEFAULT:
        writer.writeByte(0);
        break;
      case ScoreQueryMode.ALTERNATIVE:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreQueryModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
