// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fstar_mode_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FStarModeAdapter extends TypeAdapter<FStarMode> {
  @override
  final int typeId = 6;

  @override
  FStarMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FStarMode.JUST;
      case 1:
        return FStarMode.ThirdParty;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, FStarMode obj) {
    switch (obj) {
      case FStarMode.JUST:
        writer.writeByte(0);
        break;
      case FStarMode.ThirdParty:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FStarModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
