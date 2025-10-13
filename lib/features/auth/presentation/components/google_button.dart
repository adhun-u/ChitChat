import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/icons.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GoogleButton extends StatelessWidget {
  final String text;
  const GoogleButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          height: 60.h,
          width: 380.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: themeProvider.isDark ? darkWhite2 : greyColor,
              width: 1,
            ),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(googleIcon, height: 26.h, width: 26.h),
              10.horizontalSpace,
              Text(
                text,
                style: getTitleSmall(
                  context: context,
                  fontweight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
