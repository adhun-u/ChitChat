import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/device_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ErrorPage extends StatelessWidget {
  final bool? showTryAgain;
  final Function()? onTryAgain;
  const ErrorPage({super.key, this.onTryAgain, this.showTryAgain});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: context.height() * 0.35,
          width: context.width(),
          child: Image.asset(errorbackground),
        ),
        Text(
          'Something went wrong!',
          style: getTitleLarge(context: context, fontweight: FontWeight.bold),
        ),
        if (showTryAgain != null && showTryAgain!) 20.verticalSpace,
        if (showTryAgain != null && showTryAgain!)
          AppButton(
            text: "Retry",
            buttonColor: lightBlue,
            textColor: blueColor,
            showLoading: false,
            height: 50.h,
            width: 300.w,
            borderRadius: 10,
            onTap: () {
              if (onTryAgain != null) {
                onTryAgain!();
              }
            },
          ),
      ],
    );
  }
}
