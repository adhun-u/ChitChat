import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chitchat/features/auth/presentation/pages/login_page.dart';
import 'package:chitchat/features/group/presentations/blocs/group_chat/group_chat_bloc.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 10,
      insetAnimationCurve: Curves.fastOutSlowIn,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 350.h,
              width: 380.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: themeProvider.isDark ? greyColor : whiteColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  30.verticalSpace,
                  Image.asset(logoutBackground, height: 120.h, width: 130.w),
                  10.verticalSpace,
                  Text(
                    'Do you want to logout?',
                    style: getTitleMedium(
                      context: context,
                      fontweight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  10.verticalSpace,
                  SizedBox(
                    height: 70.h,
                    width: 270.w,
                    child: Text(
                      'If you are logged out,then you have to re-enter your email and password to login',
                      textAlign: TextAlign.center,
                      style: getTitleSmall(
                        context: context,
                        fontweight: FontWeight.w500,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  10.verticalSpace,
                  SizedBox(
                    height: 60.h,
                    width: 290.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          onPressed: () {
                            //Removing the logout dialog
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: getTitleMedium(
                              context: context,
                              fontweight: FontWeight.bold,
                              color: blueColor,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50.h,
                          width: 100.w,
                          child: CupertinoButton(
                            onPressed: () {
                              //Disconnecting the one to one chat socket connection
                              context.read<ChatBloc>().add(
                                DisconnectSocketEvent(),
                              );
                              //Disconnecting the group chat web socket connection
                              context.read<GroupChatBloc>().add(
                                CloseGroupChatSocketEvent(groupId: null),
                              );
                              //Removing the jwt token
                              context.read<AuthBloc>().add(LogoutEvent());
                              //Navigating to login screen
                              Navigator.of(context).pushAndRemoveUntil(
                                CupertinoPageRoute(
                                  builder: (context) {
                                    return LoginPage();
                                  },
                                ),
                                (route) => false,
                              );
                            },
                            sizeStyle: CupertinoButtonSize.small,
                            color: redColor,
                            borderRadius: BorderRadius.circular(10),
                            child: Text(
                              'Logout',
                              style: getTitleMedium(
                                context: context,
                                fontweight: FontWeight.bold,
                                color: whiteColor,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
