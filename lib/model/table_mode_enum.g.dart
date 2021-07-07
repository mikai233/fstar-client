// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_mode_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TableModeAdapter extends TypeAdapter<TableMode> {
  @override
  final int typeId = 11;

  @override
  TableMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TableMode.A;
      case 1:
        return TableMode.B;
      case 2:
        return TableMode.C;
      default:
        return TableMode.A;
    }
  }

  @override
  void write(BinaryWriter writer, TableMode obj) {
    switch (obj) {
      case TableMode.A:
        writer.writeByte(0);
        break;
      case TableMode.B:
        writer.writeByte(1);
        break;
      case TableMode.C:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
