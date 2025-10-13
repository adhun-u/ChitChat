import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Saving the JWT token
Future<void> saveToken(String token) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setString("token", token);
}

//Retrieving the saved token
Future<String?> getToken() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final String? token = pref.getString("token");
  return token;
}

//Deleting the saved token
Future<void> deleteToken() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.remove("token");
  printDebug("Token deleted");
}
