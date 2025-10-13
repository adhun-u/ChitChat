import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/home/presentations/blocs/user/user_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RemoveUserDialog extends StatelessWidget {
  final int userId;
  const RemoveUserDialog({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:
          context.read<ThemeProvider>().isDark ? greyColor : darkWhite,
      child: Container(
        height: 300.h,
        width: 400.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20.h, left: 30.w),
                  child: Row(
                    children: [
                      Text(
                        'Remove ?',
                        style: getTitleMedium(
                          context: context,
                          fontweight: FontWeight.bold,
                        ),
                      ),
                      10.horizontalSpace,
                      Icon(
                        CupertinoIcons.delete,
                        color: redColor.withAlpha(180),
                        size: 25.h,
                      ),
                    ],
                  ),
                ),
                5.verticalSpace,
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.w),
                    child: Text(
                      'Do you want to remove this user ?',
                      style: getTitleSmall(
                        context: context,
                        fontweight: FontWeight.w400,
                        color: lightGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.h, right: 10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppButton(
                      text: "Cancel",
                      buttonColor: Colors.transparent,
                      textColor: blueColor,
                      showLoading: false,
                      height: 40.h,
                      width: 80.w,
                      borderRadius: 0,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    5.horizontalSpace,
                    AppButton(
                      text: "Remove",
                      buttonColor: Colors.transparent,
                      textColor: redColor.withAlpha(180),
                      showLoading: false,
                      height: 40.h,
                      width: 90.w,
                      borderRadius: 0,
                      onTap: () {
                        //Removing the user
                        context.read<UserBloc>().add(
                          RemoveUserEvent(userId: userId),
                        );

                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
