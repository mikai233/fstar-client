// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 0;

  @override
  UserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData()
      .._username = fields[0] as String
      .._userNumber = fields[1] as String
      .._jwAccount = fields[2] as String
      .._jwPassword = fields[3] as String
      .._tyAccount = fields[4] as String
      .._tyPassword = fields[5] as String
      .._syAccount = fields[6] as String
      .._syPassword = fields[7] as String
      .._vpnAccount = fields[8] as String
      .._vpnPassword = fields[9] as String
      .._serviceAccount = fields[10] as String
      .._servicePassword = fields[11] as String;
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj._username)
      ..writeByte(1)
      ..write(obj._userNumber)
      ..writeByte(2)
      ..write(obj._jwAccount)
      ..writeByte(3)
      ..write(obj._jwPassword)
      ..writeByte(4)
      ..write(obj._tyAccount)
      ..writeByte(5)
      ..write(obj._tyPassword)
      ..writeByte(6)
      ..write(obj._syAccount)
      ..writeByte(7)
      ..write(obj._syPassword)
      ..writeByte(8)
      ..write(obj._vpnAccount)
      ..writeByte(9)
      ..write(obj._vpnPassword)
      ..writeByte(10)
      ..write(obj._serviceAccount)
      ..writeByte(11)
      ..write(obj._servicePassword);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
