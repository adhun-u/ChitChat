import 'package:flutter/material.dart';

//For setting the elements for text theme
TextTheme customTextThemes(BuildContext context) {
  return TextTheme(
    bodySmall: getBodySmall(context: context),
    titleSmall: getTitleSmall(context: context),
    titleMedium: getTitleMedium(context: context),
    titleLarge: getTitleLarge(context: context),
  );
}

//Body small text theme
TextStyle getBodySmall({
  required BuildContext context,
  double? fontSize,
  Color? color,
  FontWeight? fontweight,
}) {
  return TextStyle(
    fontSize: fontSize ?? Theme.of(context).textTheme.bodySmall!.fontSize,
    color: color,
    fontWeight: fontweight,
  );
}

//Title small text theme
TextStyle getTitleSmall({
  required BuildContext context,
  double? fontSize,
  Color? color,
  FontWeight? fontweight,
}) {
  return TextStyle(
    fontSize: fontSize ?? Theme.of(context).textTheme.titleSmall!.fontSize,
    color: color,
    fontWeight: fontweight,
  );
}

//Title medium text theme
TextStyle getTitleMedium({
  required BuildContext context,
  double? fontSize,
  Color? color,
  FontWeight? fontweight,
}) {
  return TextStyle(
    fontSize: fontSize ?? Theme.of(context).textTheme.titleMedium!.fontSize,
    color: color,
    fontWeight: fontweight,
  );
}

//Title large text theme
TextStyle getTitleLarge({
  required BuildContext context,
  double? fontSize,
  Color? color,
  FontWeight? fontweight,
}) {
  return TextStyle(
    fontSize: fontSize ?? Theme.of(context).textTheme.titleLarge!.fontSize,
    color: color,
    fontWeight: fontweight,
  );
}
