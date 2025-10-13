import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/device_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoResultsPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  const NoResultsPage({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.height() * 0.5,
        maxWidth: context.width() * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, color: lightBlue, size: 100.h),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 25.h, maxWidth: 200.w),
                  child: Text(
                    title,
                    style: getTitleMedium(
                      context: context,
                      fontweight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (subtitle != null) 8.verticalSpace,
              if (subtitle != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info, color: Colors.orange),
                    5.horizontalSpace,
                    Text(
                      subtitle ?? "",
                      style: getBodySmall(
                        context: context,
                        fontweight: FontWeight.w400,
                        color: lightGrey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
