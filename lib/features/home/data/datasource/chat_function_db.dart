import 'package:shared_preferences/shared_preferences.dart';

//Saving the sound data whether it is enabled or disabled
Future<void> saveSoundData(bool isEnabled) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setBool('isSoundEnabled', isEnabled);
}

//Getting the sound data whether the sound is enabled or disbled
Future<bool?> getSoundData() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getBool('isSoundEnabled');
}

//Saving the vibration mode whether it is enabled or disabled
Future<void> saveVibrationData(bool isEnabled) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool('isVibrationEnabled', isEnabled);
}

//Getting the vibration mode whether the mode is enabled or disabled
Future<bool?> getVibrationData() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getBool('isVibrationEnabled');
}

