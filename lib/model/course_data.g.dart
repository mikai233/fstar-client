// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseDataAdapter extends TypeAdapter<CourseData> {
  @override
  final int typeId = 2;

  @override
  CourseData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseData(
      id: fields[0] as String,
      name: fields[1] as String,
      classroom: fields[2] as String,
      week: (fields[3] as List)?.cast<int>(),
      row: fields[4] as int,
      rowSpan: fields[5] as int,
      column: fields[6] as int,
      teacher: fields[7] as String,
      defaultColor: fields[8] as Color,
      customColor: fields[9] as Color,
      top: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CourseData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.classroom)
      ..writeByte(3)
      ..write(obj.week)
      ..writeByte(4)
      ..write(obj.row)
      ..writeByte(5)
      ..write(obj.rowSpan)
      ..writeByte(6)
      ..write(obj.column)
      ..writeByte(7)
      ..write(obj.teacher)
      ..writeByte(8)
      ..write(obj.defaultColor)
      ..writeByte(9)
      ..write(obj.customColor)
      ..writeByte(10)
      ..write(obj.top);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
