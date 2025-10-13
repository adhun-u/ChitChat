import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CustomTextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefix,
    required this.suffix,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          height: 70.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: themeProvider.isDark ? greyColor : darkWhite,
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 10.w, right: 10.w),
            child: Center(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: getTitleSmall(
                    context: context,
                    color: themeProvider.isDark ? darkWhite : greyColor,
                    fontSize: 14.sp,
                  ),
                  suffixIcon: suffix,
                  prefixIcon: prefix,
                  contentPadding: EdgeInsets.only(top: 12.h),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
