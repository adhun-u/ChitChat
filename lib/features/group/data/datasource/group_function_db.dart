import 'package:shared_preferences/shared_preferences.dart';

class GroupFunctionDb {
  static late final SharedPreferences pref;
  //For muting specific group
  Future<void> muteGroup({required String groupId}) async {
    await pref.setBool(groupId, true);
  }

  //For getting muted info of specific group
  Future<bool> getMuteInfo({required String groupId}) async {
    return pref.getBool(groupId) ?? false;
  }

  //For unmuting specific group
  Future<void> unMuteGroup({required String groupId}) async {
    await pref.setBool(groupId, false);
  }
}
