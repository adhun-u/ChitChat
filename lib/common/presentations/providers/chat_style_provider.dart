import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/features/home/data/datasource/chat_style_db.dart';
import 'package:flutter/material.dart';

class ChatStyleProvider extends ChangeNotifier {
  Color chatColor = const Color.fromARGB(255, 28, 108, 173);
  double fontSize = 13;
  double borderRadius = 10;
  List<Color> colors = [
    const Color.fromARGB(255, 28, 108, 173),
    const Color.fromARGB(255, 50, 116, 52),
    const Color.fromARGB(255, 177, 107, 2),
    const Color.fromARGB(255, 165, 42, 33),
    const Color.fromARGB(255, 82, 7, 96),
    const Color.fromARGB(255, 95, 86, 5),
    const Color.fromARGB(255, 109, 81, 192),
  ];

  List<String> wallpapers = [wallpaper1];

  ChatStyleProvider() {
    _getChatColor();
    _getRadius();
    _getFontSize();
  }

  //For changing color
  void changeColor(int colorCode) async {
    chatColor = Color(colorCode);
    notifyListeners();
    saveChatBubbleColor(colorCode);
  }

  //Getting the chat bubble color from database
  void _getChatColor() async {
    int colorCode = await getChatBubbleColor();
    chatColor = Color(colorCode);
    notifyListeners();
  }

  //Getting the saved border radius from database
  void _getRadius() async {
    borderRadius = await getBorderRadius();
    notifyListeners();
  }

  //Getting the saved font size from database
  void _getFontSize() async {
    final double savedFontSize = await getFontSize();
    fontSize = savedFontSize;
    notifyListeners();
  }

  void changeBorderRadius(double borderRadius) {
    this.borderRadius = borderRadius;
    notifyListeners();
    saveBorderRadius(borderRadius);
  }

  //For changing the font size
  void changeFontSize(double fontSize) {
    this.fontSize = fontSize;
    notifyListeners();
  }
}
