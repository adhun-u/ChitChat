import 'package:shared_preferences/shared_preferences.dart';

//Saving the border radius for chat bubble
Future<void> saveBorderRadius(double borderRadius) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setDouble("borderRadius", borderRadius);
}

//Getting the saved border radius
Future<double> getBorderRadius() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getDouble("borderRadius") ?? 12;
}

//Saving the chat bubble color
Future<void> saveChatBubbleColor(int colorCode) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setInt("chatColor", colorCode);
}

//Getting the chat bubble color
Future<int> getChatBubbleColor() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt("chatColor") ?? 0xFF0F52BA;
}

//Saving the font size
Future<void> saveFontSize(double fontSize) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setDouble("fontSize", fontSize);
}

//Getting the saved font size
Future<double> getFontSize() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getDouble("fontSize") ?? 13;
}
