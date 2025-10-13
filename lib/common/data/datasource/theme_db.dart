import 'package:shared_preferences/shared_preferences.dart';

//Saving the theme data whether it is dark or light
Future<void> saveThemeData(bool isDark) async {
  final pref = await SharedPreferences.getInstance();
  pref.setBool("isDark", isDark);
}

//Getting the saved theme data
Future<bool> getSavedThemeData() async {
  final pref = await SharedPreferences.getInstance();
  return pref.getBool("isDark") ?? false;
}
