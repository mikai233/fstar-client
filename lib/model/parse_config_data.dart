import 'package:flutter/foundation.dart';

class ParseConfigData {
  final int id;
  final String schoolName;
  final String schoolUrl;
  final String user;
  final String author;
  final String preUrl;
  final String codeUrl;
  final String publishTime;

  //<editor-fold desc="Data Methods" defaultstate="collapsed">

  const ParseConfigData({
    @required this.id,
    @required this.schoolName,
    @required this.schoolUrl,
    @required this.user,
    @required this.author,
    @required this.preUrl,
    @required this.codeUrl,
    @required this.publishTime,
    @required this.remark,
    @required this.download,
  });

  ParseConfigData copyWith({
    int id,
    String schoolName,
    String schoolUrl,
    String user,
    String author,
    String preUrl,
    String codeUrl,
    String publishTime,
    String remark,
    int download,
  }) {
    if ((id == null || identical(id, this.id)) &&
        (schoolName == null || identical(schoolName, this.schoolName)) &&
        (schoolUrl == null || identical(schoolUrl, this.schoolUrl)) &&
        (user == null || identical(user, this.user)) &&
        (author == null || identical(author, this.author)) &&
        (preUrl == null || identical(preUrl, this.preUrl)) &&
        (codeUrl == null || identical(codeUrl, this.codeUrl)) &&
        (publishTime == null || identical(publishTime, this.publishTime)) &&
        (remark == null || identical(remark, this.remark)) &&
        (download == null || identical(download, this.download))) {
      return this;
    }

    return new ParseConfigData(
      id: id ?? this.id,
      schoolName: schoolName ?? this.schoolName,
      schoolUrl: schoolUrl ?? this.schoolUrl,
      user: user ?? this.user,
      author: author ?? this.author,
      preUrl: preUrl ?? this.preUrl,
      codeUrl: codeUrl ?? this.codeUrl,
      publishTime: publishTime ?? this.publishTime,
      remark: remark ?? this.remark,
      download: download ?? this.download,
    );
  }

  @override
  String toString() {
    return 'ParseConfigData{id: $id, schoolName: $schoolName, schoolUrl: $schoolUrl, user: $user, author: $author, preUrl: $preUrl, codeUrl: $codeUrl, publishTime: $publishTime, remark: $remark, download: $download}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParseConfigData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          schoolName == other.schoolName &&
          schoolUrl == other.schoolUrl &&
          user == other.user &&
          author == other.author &&
          preUrl == other.preUrl &&
          codeUrl == other.codeUrl &&
          publishTime == other.publishTime &&
          remark == other.remark &&
          download == other.download);

  @override
  int get hashCode =>
      id.hashCode ^
      schoolName.hashCode ^
      schoolUrl.hashCode ^
      user.hashCode ^
      author.hashCode ^
      preUrl.hashCode ^
      codeUrl.hashCode ^
      publishTime.hashCode ^
      remark.hashCode ^
      download.hashCode;

  factory ParseConfigData.fromMap(Map<String, dynamic> map) {
    return new ParseConfigData(
      id: map['id'] as int,
      schoolName: map['schoolName'] as String,
      schoolUrl: map['schoolUrl'] as String,
      user: map['user'] as String,
      author: map['author'] as String,
      preUrl: map['preUrl'] as String,
      codeUrl: map['codeUrl'] as String,
      publishTime: map['publishTime'] as String,
      remark: map['remark'] as String,
      download: map['download'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': this.id,
      'schoolName': this.schoolName,
      'schoolUrl': this.schoolUrl,
      'user': this.user,
      'author': this.author,
      'preUrl': this.preUrl,
      'codeUrl': this.codeUrl,
      'publishTime': this.publishTime,
      'remark': this.remark,
      'download': this.download,
    } as Map<String, dynamic>;
  }

  //</editor-fold>

  final String remark;

  final int download;
}
