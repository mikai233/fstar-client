import 'package:flutter/foundation.dart';

class Changelog {
  final int id;
  final int buildNumber;
  final String version;
  final String description;
  final String downloadUrl;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Changelog({
    @required this.id,
    @required this.buildNumber,
    @required this.version,
    @required this.description,
    @required this.downloadUrl,
  });

  Changelog copyWith({
    int id,
    int buildNumber,
    String version,
    String description,
    String downloadUrl,
  }) {
    return new Changelog(
      id: id ?? this.id,
      buildNumber: buildNumber ?? this.buildNumber,
      version: version ?? this.version,
      description: description ?? this.description,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  @override
  String toString() {
    return 'Changelog{id: $id, buildNumber: $buildNumber, version: $version, description: $description, downloadUrl: $downloadUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Changelog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          buildNumber == other.buildNumber &&
          version == other.version &&
          description == other.description &&
          downloadUrl == other.downloadUrl);

  @override
  int get hashCode =>
      id.hashCode ^
      buildNumber.hashCode ^
      version.hashCode ^
      description.hashCode ^
      downloadUrl.hashCode;

  factory Changelog.fromMap(Map<String, dynamic> map) {
    return new Changelog(
      id: map['id'] as int,
      buildNumber: map['buildNumber'] as int,
      version: map['version'] as String,
      description: map['description'] as String,
      downloadUrl: map['downloadUrl'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': this.id,
      'buildNumber': this.buildNumber,
      'version': this.version,
      'description': this.description,
      'downloadUrl': this.downloadUrl,
    } as Map<String, dynamic>;
  }

//</editor-fold>

}
