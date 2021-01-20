// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_color_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeColorDataAdapter extends TypeAdapter<ThemeColorData> {
  @override
  final int typeId = 4;

  @override
  ThemeColorData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeColorData().._index = fields[0] as int;
  }

  @override
  void write(BinaryWriter writer, ThemeColorData obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj._index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeColorDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
