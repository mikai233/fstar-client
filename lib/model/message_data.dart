import 'package:flutter/foundation.dart';

class MessageData {
  final int id;
  final String content;
  final String publishTime;
  final int maxVisibleBuildNumber;
  final int minVisibleBuildNumber;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const MessageData({
    @required this.id,
    @required this.content,
    @required this.publishTime,
    @required this.maxVisibleBuildNumber,
    @required this.minVisibleBuildNumber,
  });

  MessageData copyWith({
    int id,
    String content,
    String publishTime,
    int maxVisibleBuildNumber,
    int minVisibleBuildNumber,
  }) {
    if ((id == null || identical(id, this.id)) &&
        (content == null || identical(content, this.content)) &&
        (publishTime == null || identical(publishTime, this.publishTime)) &&
        (maxVisibleBuildNumber == null ||
            identical(maxVisibleBuildNumber, this.maxVisibleBuildNumber)) &&
        (minVisibleBuildNumber == null ||
            identical(minVisibleBuildNumber, this.minVisibleBuildNumber))) {
      return this;
    }

    return new MessageData(
      id: id ?? this.id,
      content: content ?? this.content,
      publishTime: publishTime ?? this.publishTime,
      maxVisibleBuildNumber:
          maxVisibleBuildNumber ?? this.maxVisibleBuildNumber,
      minVisibleBuildNumber:
          minVisibleBuildNumber ?? this.minVisibleBuildNumber,
    );
  }

  @override
  String toString() {
    return 'MessageData{id: $id, content: $content, publishTime: $publishTime, maxVisibleBuildNumber: $maxVisibleBuildNumber, minVisibleBuildNumber: $minVisibleBuildNumber}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          publishTime == other.publishTime &&
          maxVisibleBuildNumber == other.maxVisibleBuildNumber &&
          minVisibleBuildNumber == other.minVisibleBuildNumber);

  @override
  int get hashCode =>
      id.hashCode ^
      content.hashCode ^
      publishTime.hashCode ^
      maxVisibleBuildNumber.hashCode ^
      minVisibleBuildNumber.hashCode;

  factory MessageData.fromMap(Map<String, dynamic> map) {
    return new MessageData(
      id: map['id'] as int,
      content: map['content'] as String,
      publishTime: map['publishTime'] as String,
      maxVisibleBuildNumber: map['maxVisibleBuildNumber'] as int,
      minVisibleBuildNumber: map['minVisibleBuildNumber'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': this.id,
      'content': this.content,
      'publishTime': this.publishTime,
      'maxVisibleBuildNumber': this.maxVisibleBuildNumber,
      'minVisibleBuildNumber': this.minVisibleBuildNumber,
    } as Map<String, dynamic>;
  }

//</editor-fold>

}
