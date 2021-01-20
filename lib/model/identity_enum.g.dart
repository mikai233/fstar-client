// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdentityTypeAdapter extends TypeAdapter<IdentityType> {
  @override
  final int typeId = 5;

  @override
  IdentityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IdentityType.undergraduate;
      case 1:
        return IdentityType.graduate;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, IdentityType obj) {
    switch (obj) {
      case IdentityType.undergraduate:
        writer.writeByte(0);
        break;
      case IdentityType.graduate:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
