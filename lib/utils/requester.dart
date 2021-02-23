import 'package:fstar/model/score_display_mode_enum.dart';
import 'package:fstar/utils/utils.dart';
import 'package:just/just.dart';

abstract class Requester {
  Future<String> action();
}

class DefaultCourseRequester implements Requester {
  @override
  Future<String> action() {
    final user = getUserData();
    final settings = getSettingsData();
    return JUST.instance.getCourse(
        username: user.jwAccount,
        password: user.jwPassword,
        kksj: settings.currentSemester);
  }
}

class GraduateCourseRequester extends DefaultCourseRequester {
  @override
  Future<String> action() {
    final user = getUserData();
    return YJS.instance
        .getCourse(username: user.jwAccount, password: user.jwPassword);
  }
}

class GraduateVPNCourseRequester extends DefaultCourseRequester {
  @override
  Future<String> action() {
    final user = getUserData();
    return YJS_VPN.instance.getCourse(
        username: user.jwAccount,
        password: user.jwPassword,
        vpnUsername: user.vpnAccount,
        vpnPassword: user.vpnPassword);
  }
}

class VPNCourseRequester extends DefaultCourseRequester {
  @override
  Future<String> action() {
    final user = getUserData();
    final settings = getSettingsData();
    return VPN.instance.getCourse(
        username: user.jwAccount,
        password: user.jwPassword,
        vpnUsername: user.vpnAccount,
        vpnPassword: user.vpnPassword,
        kksj: settings.currentSemester);
  }
}

class DefaultScoreRequester implements Requester {
  @override
  Future<String> action() {
    final user = getUserData();
    final settings = getSettingsData();
    return JUST.instance.getScore(
        username: user.jwAccount,
        password: user.jwPassword,
        kksj: settings.scoreQuerySemester,
        xsfs: settings.scoreDisplayMode.property());
  }
}

class AlternativeScoreRequester extends DefaultScoreRequester {
  @override
  Future<String> action() {
    final user = getUserData();
    final settings = getSettingsData();
    return JUST.instance.getScore2(
        username: user.jwAccount,
        password: user.jwPassword,
        kksj: settings.scoreQuerySemester);
  }
}

class VPNScoreRequester extends DefaultScoreRequester {
  @override
  Future<String> action() {
    final user = getUserData();
    final settings = getSettingsData();
    return VPN.instance.getScore(
        username: user.jwAccount,
        password: user.jwPassword,
        vpnUsername: user.vpnAccount,
        vpnPassword: user.vpnPassword,
        kksj: settings.scoreQuerySemester,
        xsfs: settings.scoreDisplayMode.property());
  }
}

class VPNAlternativeScoreRequester extends DefaultScoreRequester {
  @override
  Future<String> action() {
    final user = getUserData();
    final settings = getSettingsData();
    return VPN.instance.getScore2(
        username: user.jwAccount,
        password: user.jwPassword,
        vpnUsername: user.vpnAccount,
        vpnPassword: user.vpnPassword,
        kksj: settings.scoreQuerySemester);
  }
}

class SportScoreRequester implements DefaultScoreRequester {
  @override
  Future<String> action() {
    final user = getUserData();
    return JUST.instance
        .getSportScore(username: user.tyAccount, password: user.tyPassword);
  }
}

class VPNSportScoreRequester implements DefaultScoreRequester {
  @override
  Future<String> action() {
    final user = getUserData();
    return VPN.instance.getSportScore(
        username: user.tyAccount,
        password: user.tyPassword,
        vpnUsername: user.vpnAccount,
        vpnPassword: user.vpnPassword);
  }
}

class GraduateScoreRequester implements DefaultScoreRequester {
  @override
  Future<String> action() {
    final user = getUserData();
    return YJS.instance
        .getScore(username: user.jwAccount, password: user.jwPassword);
  }
}

class GraduateVPNScoreRequester implements DefaultScoreRequester {
  @override
  Future<String> action() {
    final user = getUserData();
    return YJS_VPN.instance.getScore(
        username: user.jwAccount,
        password: user.jwPassword,
        vpnUsername: user.vpnAccount,
        vpnPassword: user.vpnPassword);
  }
}
