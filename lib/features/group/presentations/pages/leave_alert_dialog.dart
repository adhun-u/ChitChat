import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LeaveAlertDialog extends StatelessWidget {
  final String groupId;
  final int currentGroupMembersCount;
  const LeaveAlertDialog({
    super.key,
    required this.groupId,
    required this.currentGroupMembersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 350.h,
        width: 430.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: context.read<ThemeProvider>().isDark ? greyColor : darkWhite,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15.h),
              child: Column(
                children: [
                  Text(
                    'Do you want to leave ?',
                    style: getTitleMedium(
                      context: context,
                      fontweight: FontWeight.bold,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      top: 10.h,
                    ),
                    child: Text(
                      'If you leave from this group , group admin will have to add you or you will have to request group admin to add',
                      style: getTitleSmall(context: context, color: lightGrey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: AppButton(
                    text: "Cancel",
                    buttonColor: Colors.transparent,
                    textColor: blueColor,
                    showLoading: false,
                    height: 40.h,
                    width: 90.w,
                    borderRadius: 0,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),

                Align(
                  alignment: Alignment.bottomRight,
                  child: AppButton(
                    text: "Leave",
                    buttonColor: Colors.transparent,
                    textColor: redColor.withAlpha(180),
                    showLoading: false,
                    height: 40.h,
                    width: 90.w,
                    borderRadius: 0,
                    onTap: () {
                      //Leaving from this group
                      context.read<GroupBloc>().add(
                        LeaveFromGroupEvent(
                          groupId: groupId,
                          currentGroupMembersCount: currentGroupMembersCount,
                          currentUserId:
                              context
                                  .read<CurrentUserProvider>()
                                  .currentUser
                                  .userId,
                        ),
                      );

                      Navigator.of(context).pop();
                    },
                  ),
                ),
                20.verticalSpace,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
