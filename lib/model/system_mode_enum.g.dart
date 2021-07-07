// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_mode_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemModeAdapter extends TypeAdapter<SystemMode> {
  @override
  final int typeId = 9;

  @override
  SystemMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SystemMode.JUST;
      case 1:
        return SystemMode.VPN;
      case 2:
        return SystemMode.VPN2;
      case 3:
        return SystemMode.CLOUD;
      default:
        return SystemMode.JUST;
    }
  }

  @override
  void write(BinaryWriter writer, SystemMode obj) {
    switch (obj) {
      case SystemMode.JUST:
        writer.writeByte(0);
        break;
      case SystemMode.VPN:
        writer.writeByte(1);
        break;
      case SystemMode.VPN2:
        writer.writeByte(2);
        break;
      case SystemMode.CLOUD:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
