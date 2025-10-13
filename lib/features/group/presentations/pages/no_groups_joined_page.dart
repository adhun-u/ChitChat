import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/group/presentations/pages/create_group_page.dart';
import 'package:chitchat/features/group/presentations/pages/search_group_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class NoGroupsJoinedPage extends StatelessWidget {
  const NoGroupsJoinedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),

      child: Column(
        children: [
          Center(
            child: Image.asset(
              createGroupBackground,
              fit: BoxFit.fill,
              height: 300.h,
              width: 400.h,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Create group',
                style: getTitleLarge(
                  context: context,
                  fontweight: FontWeight.bold,
                  fontSize: 30.sp,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'You did not join any group currently',
                style: getTitleSmall(
                  context: context,
                  fontweight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ),
          30.verticalSpace,
          SizedBox(
            height: 60.h,
            width: 390.w,
            child: CupertinoButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: CreateGroupPage(),
                  pageTransitionAnimation: PageTransitionAnimation.slideUp,
                );
              },
              borderRadius: BorderRadius.circular(30.r),
              color: blueColor,
              child: Text(
                'Create own group',
                style: getBodySmall(
                  context: context,
                  fontweight: FontWeight.bold,
                  color: whiteColor,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ),
          10.verticalSpace,
          Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              return OutlinedButton(
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: SearchGroupPage(),
                    pageTransitionAnimation: PageTransitionAnimation.slideUp,
                  );
                },
                style: ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(Size(390.w, 60.h)),
                  overlayColor: WidgetStatePropertyAll(
                    theme.isDark ? darkGrey : darkWhite2,
                  ),
                ),
                child: Text(
                  'Join an existing group',
                  style: getTitleSmall(
                    context: context,
                    fontweight: FontWeight.bold,
                    color: blueColor,
                    fontSize: 15.sp,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
