import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color textColor;
  final bool showLoading;
  final double height;
  final double width;
  final double borderRadius;
  final Function() onTap;
  final double? fontSize;

  const AppButton({
    super.key,
    required this.text,
    required this.buttonColor,
    required this.textColor,
    required this.showLoading,
    required this.height,
    required this.width,
    required this.borderRadius,
    required this.onTap,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CupertinoButton(
        onPressed: () {
          onTap();
        },
        sizeStyle: CupertinoButtonSize.small,
        color: buttonColor,
        borderRadius: BorderRadius.circular(borderRadius),

        child:
            showLoading
                ? SizedBox(
                  height: 25.h,
                  width: 25.h,
                  child: LoadingIndicator(color: whiteColor),
                )
                : Text(
                  text,
                  style: getTitleSmall(
                    context: context,
                    fontweight: FontWeight.bold,
                    fontSize: fontSize,
                    color: textColor,
                  ),
                ),
      ),
    );
  }
}
