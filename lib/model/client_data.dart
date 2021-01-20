import 'package:flutter/foundation.dart';

class ClientData {
  final int id;
  final String appVersion;
  final int buildNumber;
  final String androidId;
  final String adnoridVersion;
  final String brand;
  final String device;
  final String model;
  final String platform;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const ClientData({
    @required this.id,
    @required this.appVersion,
    @required this.buildNumber,
    @required this.androidId,
    @required this.adnoridVersion,
    @required this.brand,
    @required this.device,
    @required this.model,
    @required this.platform,
  });

  ClientData copyWith({
    int id,
    String appVersion,
    int buildNumber,
    String androidId,
    String adnoridVersion,
    String brand,
    String device,
    String model,
    String platform,
  }) {
    if ((id == null || identical(id, this.id)) &&
        (appVersion == null || identical(appVersion, this.appVersion)) &&
        (buildNumber == null || identical(buildNumber, this.buildNumber)) &&
        (androidId == null || identical(androidId, this.androidId)) &&
        (adnoridVersion == null ||
            identical(adnoridVersion, this.adnoridVersion)) &&
        (brand == null || identical(brand, this.brand)) &&
        (device == null || identical(device, this.device)) &&
        (model == null || identical(model, this.model)) &&
        (platform == null || identical(platform, this.platform))) {
      return this;
    }

    return new ClientData(
      id: id ?? this.id,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      androidId: androidId ?? this.androidId,
      adnoridVersion: adnoridVersion ?? this.adnoridVersion,
      brand: brand ?? this.brand,
      device: device ?? this.device,
      model: model ?? this.model,
      platform: platform ?? this.platform,
    );
  }

  @override
  String toString() {
    return 'ClientData{id: $id, appVersion: $appVersion, buildNumber: $buildNumber, androidId: $androidId, adnoridVersion: $adnoridVersion, brand: $brand, device: $device, model: $model, platform: $platform}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          appVersion == other.appVersion &&
          buildNumber == other.buildNumber &&
          androidId == other.androidId &&
          adnoridVersion == other.adnoridVersion &&
          brand == other.brand &&
          device == other.device &&
          model == other.model &&
          platform == other.platform);

  @override
  int get hashCode =>
      id.hashCode ^
      appVersion.hashCode ^
      buildNumber.hashCode ^
      androidId.hashCode ^
      adnoridVersion.hashCode ^
      brand.hashCode ^
      device.hashCode ^
      model.hashCode ^
      platform.hashCode;

  factory ClientData.fromMap(Map<String, dynamic> map) {
    return new ClientData(
      id: map['id'] as int,
      appVersion: map['appVersion'] as String,
      buildNumber: map['buildNumber'] as int,
      androidId: map['androidId'] as String,
      adnoridVersion: map['adnoridVersion'] as String,
      brand: map['brand'] as String,
      device: map['device'] as String,
      model: map['model'] as String,
      platform: map['platform'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': this.id,
      'appVersion': this.appVersion,
      'buildNumber': this.buildNumber,
      'androidId': this.androidId,
      'adnoridVersion': this.adnoridVersion,
      'brand': this.brand,
      'device': this.device,
      'model': this.model,
      'platform': this.platform,
    } as Map<String, dynamic>;
  }

//</editor-fold>

}
