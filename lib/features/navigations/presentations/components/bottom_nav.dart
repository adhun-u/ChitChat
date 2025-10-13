import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

final ValueNotifier<int> bottomNavIndexNotifier = ValueNotifier(0);

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return ValueListenableBuilder(
          valueListenable: bottomNavIndexNotifier,
          builder: (context, bottomNavIndex, _) {
            return GNav(
              selectedIndex: bottomNavIndex,

              onTabChange: (index) {
                bottomNavIndexNotifier.value = index;
              },
              duration: const Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              activeColor: themeProvider.isDark ? whiteColor : blackColor,
              style: GnavStyle.google,
              tabBackgroundColor: themeProvider.isDark ? greyColor : darkWhite,
              textStyle: getTitleSmall(
                context: context,
                fontweight: FontWeight.bold,
                fontSize: 13.sp,
              ),
              padding: EdgeInsets.only(
                top: 15.h,
                left: 10.h,
                right: 10.h,
                bottom: 15.h,
              ),
              tabBorderRadius: 15.r,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              tabMargin: EdgeInsets.only(bottom: 10.h, top: 10.h),

              tabs: [
                GButton(icon: Icons.home, text: "Home", gap: 10.w),
                GButton(icon: CupertinoIcons.search, text: "Search", gap: 10.w),
                GButton(icon: Icons.group, text: "Group", gap: 10.w),
                GButton(icon: Icons.settings, text: "Settings", gap: 10.w),
              ],
            );
          },
        );
      },
    );
  }
}
