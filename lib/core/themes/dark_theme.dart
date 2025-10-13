import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';

//For setting the elements for dark theme
ThemeData darkTheme(BuildContext context) {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: blackColor,

    textTheme: customTextThemes(context),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: blueColor,
      selectionHandleColor: blueColor,
      cursorColor: blueColor,
    ),
  );
}
