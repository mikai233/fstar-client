// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreDataAdapter extends TypeAdapter<ScoreData> {
  @override
  final int typeId = 3;

  @override
  ScoreData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreData(
      no: fields[0] as String,
      semester: fields[1] as String,
      scoreNo: fields[2] as String,
      name: fields[3] as String,
      score: fields[4] as String,
      credit: fields[5] as String,
      period: fields[6] as String,
      evaluationMode: fields[7] as String,
      courseProperty: fields[8] as String,
      courseNature: fields[9] as String,
      alternativeCourseNumber: fields[10] as String,
      alternativeCourseName: fields[11] as String,
      scoreFlag: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ScoreData obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.no)
      ..writeByte(1)
      ..write(obj.semester)
      ..writeByte(2)
      ..write(obj.scoreNo)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.credit)
      ..writeByte(6)
      ..write(obj.period)
      ..writeByte(7)
      ..write(obj.evaluationMode)
      ..writeByte(8)
      ..write(obj.courseProperty)
      ..writeByte(9)
      ..write(obj.courseNature)
      ..writeByte(10)
      ..write(obj.alternativeCourseNumber)
      ..writeByte(11)
      ..write(obj.alternativeCourseName)
      ..writeByte(12)
      ..write(obj.scoreFlag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
