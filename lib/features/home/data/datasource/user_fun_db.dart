import 'package:shared_preferences/shared_preferences.dart';

class UserFunctionDB {
  static late final SharedPreferences pref;

  //For muting a user to not get notifications
  Future<void> muteUser({required int userId}) async {
    pref.setBool("$userId", true);
  }

  //For unmuting a user to get notifications
  Future<void> unMuteUser({required int userId}) async {
    await pref.setBool("$userId", false);
  }

  //For getting mute info
  Future<bool> getUserMuteInfo({required int userId}) async {
    return pref.getBool("$userId") ?? false;
  }
}
