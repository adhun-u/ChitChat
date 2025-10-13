import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DialogLoadingIndicator extends StatelessWidget {
  final String loadingText;
  const DialogLoadingIndicator({super.key, required this.loadingText});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Consumer<ThemeProvider>(
        builder: (context, theme, child) {
          return Container(
            height: 150.h,
            width: 270.w,
            decoration: BoxDecoration(
              color: theme.isDark ? greyColor : darkWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 3, color: blueColor),
            10.verticalSpace,
            Text(
              loadingText,
              style: getBodySmall(
                context: context,
                fontweight: FontWeight.w500,
                color: lightGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
