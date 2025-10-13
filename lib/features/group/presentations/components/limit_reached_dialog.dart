import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupMemberLimitReadDialog extends StatelessWidget {
  const GroupMemberLimitReadDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 250.h,
        width: 400.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: context.read<ThemeProvider>().isDark ? greyColor : darkWhite,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, top: 20.h),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Group members limit reached',
                          style: getTitleMedium(
                            context: context,
                            fontweight: FontWeight.bold,
                            color: lightGrey,
                          ),
                        ),
                        10.horizontalSpace,

                        const Icon(Icons.info, color: Colors.orange),
                      ],
                    ),
                    10.verticalSpace,
                    Text(
                      'You can only add 100 members to a group',
                      style: getTitleSmall(
                        context: context,
                        fontweight: FontWeight.w400,
                        color: lightGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: AppButton(
                  text: "Ok",
                  buttonColor: Colors.transparent,
                  textColor: blueColor,
                  showLoading: false,
                  height: 50.h,
                  width: 80.w,
                  borderRadius: 0,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
