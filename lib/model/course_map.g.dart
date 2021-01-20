// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_map.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseMapAdapter extends TypeAdapter<CourseMap> {
  @override
  final int typeId = 10;

  @override
  CourseMap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseMap()
      .._dataMap = (fields[0] as Map)?.map((dynamic k, dynamic v) =>
          MapEntry(k as int, (v as List)?.cast<CourseData>()))
      .._remark = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, CourseMap obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj._dataMap)
      ..writeByte(1)
      ..write(obj._remark);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseMapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
