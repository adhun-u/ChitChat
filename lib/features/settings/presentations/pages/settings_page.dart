import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/presentations/components/custom_refresh_indicator.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/icons.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/settings/presentations/components/current_user_profile_tile.dart';
import 'package:chitchat/features/settings/presentations/components/logout_dialog.dart';
import 'package:chitchat/features/settings/presentations/components/settings_tile.dart';
import 'package:chitchat/features/settings/presentations/pages/account_settings.dart';
import 'package:chitchat/features/settings/presentations/pages/chat_settings.dart';
import 'package:chitchat/features/settings/presentations/pages/notification_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'Settings',
          style: getTitleLarge(context: context, fontweight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return CustomRefreshIndicator(
                    onRefresh: () async {
                      context.read<CurrentUserProvider>().fetchCurrentUser();
                    },
                    child: ListView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      children: [
                        Consumer<CurrentUserProvider>(
                          builder: (context, currentUserProvider, _) {
                            final CurrentUserModel currentUser =
                                currentUserProvider.currentUser;
                            return CurrentUserProfileTile(
                              currentUserProfilePic: currentUser.profilePic,
                              currentUserbio: currentUser.bio,
                              currentUsername: currentUser.username,
                            );
                          },
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 30.w, left: 20),
                          child: Row(
                            children: [
                              Text(
                                'Profile',
                                style: getTitleMedium(
                                  context: context,
                                  fontweight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            //Fetching current user's details
                            context
                                .read<CurrentUserProvider>()
                                .fetchCurrentUser();
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) {
                                  return AccountSettings();
                                },
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: SettingsTile(
                            leading: Image.asset(
                              accountSettingsIcon,
                              color: const Color.fromARGB(255, 135, 135, 135),
                              height: 25.h,
                              width: 25.h,
                            ),
                            subtitle: 'Edit profile,change password',
                            title: 'Account',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.h, left: 20),
                          child: Row(
                            children: [
                              Text(
                                'Customize',
                                style: getTitleMedium(
                                  context: context,
                                  fontweight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) {
                                  return ChatSettings();
                                },
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: SettingsTile(
                            leading: Image.asset(
                              chatIcon,
                              color: const Color.fromARGB(255, 135, 135, 135),
                              height: 25.h,
                              width: 25.h,
                            ),
                            subtitle: 'Theme,font',
                            title: 'Chat',
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) {
                                  return NotificationSettings();
                                },
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: SettingsTile(
                            leading: Image.asset(
                              notificationIcon,
                              color: const Color.fromARGB(255, 135, 135, 135),
                              height: 25.h,
                              width: 25.h,
                            ),
                            subtitle: 'Sound,vibration',
                            title: 'Notification',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.h, left: 20),
                          child: Row(
                            children: [
                              Text(
                                'Others',
                                style: getTitleMedium(
                                  context: context,
                                  fontweight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return LogoutDialog();
                              },
                            );
                          },
                          child: SettingsTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Color.fromARGB(255, 135, 135, 135),
                            ),
                            subtitle: "",
                            title: "Logout",
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
