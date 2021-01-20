import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'user_data.g.dart';

@HiveType(typeId: 0)
class UserData extends HiveObject with ChangeNotifier {
  @HiveField(0)
  String _username;
  @HiveField(1)
  String _userNumber;
  @HiveField(2)
  String _jwAccount;
  @HiveField(3)
  String _jwPassword;
  @HiveField(4)
  String _tyAccount;
  @HiveField(5)
  String _tyPassword;
  @HiveField(6)
  String _syAccount;
  @HiveField(7)
  String _syPassword;
  @HiveField(8)
  String _vpnAccount;
  @HiveField(9)
  String _vpnPassword;
  @HiveField(10)
  String _serviceAccount;
  @HiveField(11)
  String _servicePassword;

  String get vpnAccount => _vpnAccount;

  set vpnAccount(String value) {
    _vpnAccount = value;
    notifyListeners();
  }

  String get username => _username;

  set username(String value) {
    _username = value;
    notifyListeners();
  }

  String get userNumber => _userNumber;

  set userNumber(String value) {
    _userNumber = value;
    notifyListeners();
  }

  String get syPassword => _syPassword;

  set syPassword(String value) {
    _syPassword = value;
    notifyListeners();
  }

  String get syAccount => _syAccount;

  set syAccount(String value) {
    _syAccount = value;
    notifyListeners();
  }

  String get tyPassword => _tyPassword;

  set tyPassword(String value) {
    _tyPassword = value;
    notifyListeners();
  }

  String get tyAccount => _tyAccount;

  set tyAccount(String value) {
    _tyAccount = value;
    notifyListeners();
  }

  String get jwPassword => _jwPassword;

  set jwPassword(String value) {
    _jwPassword = value;
    notifyListeners();
  }

  String get jwAccount => _jwAccount;

  set jwAccount(String value) {
    _jwAccount = value;
    notifyListeners();
  }

  void clear() {
    _username = null;
    _userNumber = null;
    _jwAccount = null;
    _jwPassword = null;
    _tyAccount = null;
    _tyPassword = null;
    _syAccount = null;
    _syPassword = null;
    notifyListeners();
  }

  String get vpnPassword => _vpnPassword;

  set vpnPassword(String value) {
    _vpnPassword = value;
    notifyListeners();
  }

  String get serviceAccount => _serviceAccount;

  set serviceAccount(String value) {
    _serviceAccount = value;
    notifyListeners();
  }

  String get servicePassword => _servicePassword;

  set servicePassword(String value) {
    _servicePassword = value;
    notifyListeners();
  }
}
