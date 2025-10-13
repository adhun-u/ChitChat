import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCupertinoButton extends StatelessWidget {
  final String label;
  final Function() onTap;
  final bool isLoading;
  const CustomCupertinoButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      width: 380.w,
      child: CupertinoButton(
        onPressed: () {
          onTap();
        },
        color: blueColor,
        borderRadius: BorderRadius.circular(30),
        child:
            isLoading
                ? SizedBox(
                  width: 25.w,
                  child: LoadingIndicator(color: whiteColor, strokeWidth: 1.5),
                )
                : Text(
                  label,
                  style: getTitleMedium(
                    context: context,
                    fontweight: FontWeight.bold,
                    color: whiteColor,
                    fontSize: 14.sp,
                  ),
                ),
      ),
    );
  }
}
