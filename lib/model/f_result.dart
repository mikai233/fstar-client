import 'package:flutter/foundation.dart';

class FResult {
  final int code;
  final String message;
  final dynamic data;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const FResult({
    @required this.code,
    @required this.message,
    @required this.data,
  });

  FResult copyWith({
    int code,
    String message,
    dynamic data,
  }) {
    if ((code == null || identical(code, this.code)) &&
        (message == null || identical(message, this.message)) &&
        (data == null || identical(data, this.data))) {
      return this;
    }

    return new FResult(
      code: code ?? this.code,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'FResult{code: $code, message: $message, data: $data}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FResult &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          data == other.data);

  @override
  int get hashCode => code.hashCode ^ message.hashCode ^ data.hashCode;

  factory FResult.fromMap(Map<String, dynamic> map) {
    return new FResult(
      code: map['code'] as int,
      message: map['message'] as String,
      data: map['data'] as dynamic,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'code': this.code,
      'message': this.message,
      'data': this.data,
    } as Map<String, dynamic>;
  }

//</editor-fold>

}
