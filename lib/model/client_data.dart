import 'package:flutter/foundation.dart';

class ClientData {
  final int id;
  final String appVersion;
  final int buildNumber;
  final String androidId;
  final String androidVersion;
  final String brand;
  final String device;
  final String model;
  final String product;
  final String platform;

//<editor-fold desc="Data Methods">

  ClientData({
    @required this.id,
    @required this.appVersion,
    @required this.buildNumber,
    @required this.androidId,
    @required this.androidVersion,
    @required this.brand,
    @required this.device,
    @required this.model,
    @required this.product,
    @required this.platform,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          appVersion == other.appVersion &&
          buildNumber == other.buildNumber &&
          androidId == other.androidId &&
          androidVersion == other.androidVersion &&
          brand == other.brand &&
          device == other.device &&
          model == other.model &&
          product == other.product &&
          platform == other.platform);

  @override
  int get hashCode =>
      id.hashCode ^
      appVersion.hashCode ^
      buildNumber.hashCode ^
      androidId.hashCode ^
      androidVersion.hashCode ^
      brand.hashCode ^
      device.hashCode ^
      model.hashCode ^
      product.hashCode ^
      platform.hashCode;

  @override
  String toString() {
    return 'ClientData{' +
        ' id: $id,' +
        ' appVersion: $appVersion,' +
        ' buildNumber: $buildNumber,' +
        ' androidId: $androidId,' +
        ' androidVersion: $androidVersion,' +
        ' brand: $brand,' +
        ' device: $device,' +
        ' model: $model,' +
        ' product: $product,' +
        ' platform: $platform,' +
        '}';
  }

  ClientData copyWith({
    int id,
    String appVersion,
    int buildNumber,
    String androidId,
    String androidVersion,
    String brand,
    String device,
    String model,
    String product,
    String platform,
  }) {
    return ClientData(
      id: id ?? this.id,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      androidId: androidId ?? this.androidId,
      androidVersion: androidVersion ?? this.androidVersion,
      brand: brand ?? this.brand,
      device: device ?? this.device,
      model: model ?? this.model,
      product: product ?? this.product,
      platform: platform ?? this.platform,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'appVersion': this.appVersion,
      'buildNumber': this.buildNumber,
      'androidId': this.androidId,
      'androidVersion': this.androidVersion,
      'brand': this.brand,
      'device': this.device,
      'model': this.model,
      'product': this.product,
      'platform': this.platform,
    };
  }

  factory ClientData.fromMap(Map<String, dynamic> map) {
    return ClientData(
      id: map['id'] as int,
      appVersion: map['appVersion'] as String,
      buildNumber: map['buildNumber'] as int,
      androidId: map['androidId'] as String,
      androidVersion: map['androidVersion'] as String,
      brand: map['brand'] as String,
      device: map['device'] as String,
      model: map['model'] as String,
      product: map['product'] as String,
      platform: map['platform'] as String,
    );
  }

//</editor-fold>
}
