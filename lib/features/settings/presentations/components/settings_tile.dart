import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  const SettingsTile({
    super.key,
    required this.leading,
    required this.subtitle,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return ListTile(
          leading: leading,
          title: Text(
            title,
            style: getTitleMedium(
              context: context,
              fontweight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          subtitle:
              subtitle.isNotEmpty
                  ? Text(
                    subtitle,
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  )
                  : null,
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 20.h),
        );
      },
    );
  }
}
