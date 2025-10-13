import 'package:chitchat/common/data/datasource/theme_db.dart';
import 'package:flutter/material.dart';

//Change theme according to light theme and dark theme
class ThemeProvider extends ChangeNotifier {
  bool isDark = true;

  ThemeProvider() {
    getTheme();
  }

  void changeTheme(bool isDark) {
    this.isDark = isDark;
    notifyListeners();
    //Saving the theme data
    saveThemeData(isDark);
  }

  //Getting the saved theme data to notify
  void getTheme() async {
    final isDark = await getSavedThemeData();
    this.isDark = isDark;
    notifyListeners();
  }
}
