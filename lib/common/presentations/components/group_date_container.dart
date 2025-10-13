import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GroupDateContainer extends StatelessWidget {
  final String date;
  const GroupDateContainer({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 40.h,
              minWidth: 70.w,
              maxWidth: 140.w,
            ),
            child: Consumer<ChatStyleProvider>(
              builder: (context, chatStyle, _) {
                return Container(
                  decoration: BoxDecoration(
                    color:
                        context.read<ThemeProvider>().isDark
                            ? greyColor
                            : darkWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      date,
                      style: getBodySmall(
                        context: context,
                        fontweight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
