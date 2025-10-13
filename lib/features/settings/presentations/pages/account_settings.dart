import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/settings/presentations/components/settings_tile.dart';
import 'package:chitchat/features/settings/presentations/pages/change_password_page.dart';
import 'package:chitchat/features/settings/presentations/pages/edit_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: Text(
          'Account Settings',
          style: getTitleMedium(
            context: context,
            fontweight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return EditProfile();
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: const SettingsTile(
                leading: Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 135, 135, 135),
                ),
                subtitle: "To edit username,profile picture and bio",
                title: "Edit profile",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return ChangePasswordPage();
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: const SettingsTile(
                leading: Icon(
                  Icons.lock,
                  color: Color.fromARGB(255, 135, 135, 135),
                ),
                subtitle: "",
                title: "Change password",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
