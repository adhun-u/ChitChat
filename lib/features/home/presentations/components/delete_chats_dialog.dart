import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DeleteChatsDialog extends StatelessWidget {
  final int currentUserId;
  final int oppositeUserId;

  const DeleteChatsDialog({
    super.key,
    required this.currentUserId,
    required this.oppositeUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Consumer<ThemeProvider>(
        builder: (context, theme, child) {
          return Container(
            height: 350.h,
            width: 420.w,
            decoration: BoxDecoration(
              color: theme.isDark ? greyColor : darkWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, top: 20.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Clear chat ?',
                        style: getTitleMedium(
                          context: context,
                          fontweight: FontWeight.bold,
                        ),
                      ),
                      5.horizontalSpace,
                      Icon(
                        CupertinoIcons.delete,
                        size: 22,
                        color: redColor.withAlpha(180),
                      ),
                    ],
                  ),
                  10.horizontalSpace,
                  Text(
                    'Do you want to clear all chats . This chats cannot be recovered',
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.w400,
                      color: lightGrey,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(right: 10.w, bottom: 20.h),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppButton(
                      text: "Cancel",
                      buttonColor: Colors.transparent,
                      textColor: blueColor,
                      showLoading: false,
                      height: 35.h,
                      width: 90.w,
                      borderRadius: 0,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    AppButton(
                      text: "Remove",
                      buttonColor: Colors.transparent,
                      textColor: redColor.withAlpha(180),
                      showLoading: false,
                      height: 35.h,
                      width: 90.w,
                      borderRadius: 0,
                      onTap: () {
                        //Clearing all chats with this user
                        context.read<ChatBloc>().add(
                          ClearAllChatsEvent(
                            currentUserId: currentUserId,
                            oppositeUserId: oppositeUserId,
                          ),
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
