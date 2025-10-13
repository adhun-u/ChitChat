import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final String hintText;
  final Function(String text)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final Color? backgroudColor;
  final Color? textColor;
  const AppTextField({
    super.key,
    required this.controller,
    required this.prefix,
    required this.hintText,
    required this.obscureText,
    required this.suffix,
    this.onChanged,
    this.maxLines,
    this.maxLength,
    this.backgroudColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color:
            backgroudColor ??
            (context.read<ThemeProvider>().isDark ? greyColor : darkWhite),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: getTitleSmall(
          context: context,
          fontweight: FontWeight.w400,
          color: textColor,
        ),
        maxLines: maxLines ?? 1,
        minLines: 1,
        maxLength: maxLength,
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
        },
        onChanged: (text) {
          if (onChanged != null) {
            onChanged!(text);
          }
        },
        buildCounter: (
          _, {
          required currentLength,
          required isFocused,
          required maxLength,
        }) {
          return const SizedBox();
        },

        decoration: InputDecoration(
          prefixIcon: prefix,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,

          hintStyle: getTitleSmall(
            context: context,
            fontweight: FontWeight.w500,
            fontSize: 15.sp,
            color: lightGrey,
          ),
          suffixIcon: suffix,
          contentPadding: EdgeInsets.only(top: 15.h, right: 10.w, left: 10.w),
        ),
      ),
    );
  }
}
