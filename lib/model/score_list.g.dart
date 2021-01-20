// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreListAdapter extends TypeAdapter<ScoreList> {
  @override
  final int typeId = 14;

  @override
  ScoreList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreList().._list = (fields[0] as List)?.cast<ScoreData>();
  }

  @override
  void write(BinaryWriter writer, ScoreList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj._list);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
