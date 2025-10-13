import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  const OtpInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Pinput(
          controller: controller,
          animationDuration: const Duration(milliseconds: 150),
          animationCurve: Curves.linear,
          separatorBuilder: (index) {
            return SizedBox(width: 15.w);
          },
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
          },
          showCursor: true,
          cursor: Padding(
            padding: EdgeInsets.all(20.h),
            child: VerticalDivider(color: blueColor),
          ),
        
          focusedPinTheme: PinTheme(
            height: 60.h,
            width: 60.h,
            textStyle: getTitleMedium(
              context: context,
              fontweight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: themeProvider.isDark ? darkGrey : darkWhite2,
            ),
          ),
          defaultPinTheme: PinTheme(
            height: 60.h,
            width: 60.h,
            textStyle: getTitleMedium(
              context: context,
              fontweight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: themeProvider.isDark ? darkGrey : darkWhite2,
            ),
          ),
        );
      },
    );
  }
}
