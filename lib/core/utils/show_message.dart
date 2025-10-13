import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:toastify_flutter/toastify_flutter.dart';

//To show success message
void showSuccessMessage(BuildContext context, String message) {
  ToastifyFlutter.success(
    context,
    message: message,
    animationCurve: Curves.fastLinearToSlowEaseIn,
    onClose: true,
    textStyle: getTitleMedium(context: context, color: blackColor),
    style: ToastStyle.flat,
  );
}

//To show error message
void showErrorMessage(BuildContext context, String message) {
  ToastifyFlutter.error(
    context,
    message: message,
    animationCurve: Curves.fastLinearToSlowEaseIn,
    onClose: true,
    textStyle: getTitleMedium(context: context, color: blackColor),
    style: ToastStyle.flat,
  );
}

//To show info message
void showInfoMessage(BuildContext context, String message) {
  ToastifyFlutter.info(
    context,
    message: message,
    animationCurve: Curves.fastLinearToSlowEaseIn,
    onClose: true,
    textStyle: getTitleMedium(context: context, color: blackColor),
    style: ToastStyle.flat,
  );
}

//To show warning message
void showWarningMessage(BuildContext context, String message) {
  ToastifyFlutter.warning(
    context,
    message: message,
    animationCurve: Curves.fastLinearToSlowEaseIn,
    onClose: true,
    textStyle: getTitleMedium(context: context, color: blackColor),
    style: ToastStyle.flat,
  );
}
