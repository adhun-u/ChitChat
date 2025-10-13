import 'package:chitchat/core/constants/icons.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/common/presentations/providers/chat_function_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: Text(
          'Notification settings',
          style: getTitleMedium(
            context: context,
            fontweight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _NotificationListTile(
            title: 'Sound',
            subtitle: "Sound when a new message comes",
            leading: Image.asset(
              waveIcon,
              color: const Color.fromARGB(255, 135, 135, 135),
              height: 25.h,
              width: 25.h,
            ),
            trailing: Consumer<ChatFunctionProvider>(
              builder: (context, chatFunctionProvider, _) {
                return CupertinoSwitch(
                  value: chatFunctionProvider.isSoundEnabled,
                  onChanged: (isEnabled) {
                    context.read<ChatFunctionProvider>().changeSoundMode(
                      isEnabled,
                    );
                  },
                  activeTrackColor: blueColor,
                );
              },
            ),
          ),
          _NotificationListTile(
            title: 'Vibration',
            subtitle: "Vibration when a new message comes",
            leading: Image.asset(
              vibrationIcon,
              color: const Color.fromARGB(255, 135, 135, 135),
              height: 25.h,
              width: 25.h,
            ),
            trailing: Consumer<ChatFunctionProvider>(
              builder: (context, chatFunctionProvider, _) {
                return CupertinoSwitch(
                  value: chatFunctionProvider.isVibratorOn,
                  onChanged: (isEnabled) {
                    context.read<ChatFunctionProvider>().changeVibrationMode(
                      isEnabled,
                    );
                  },
                  activeTrackColor: blueColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final Widget trailing;
  const _NotificationListTile({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: getTitleMedium(context: context, fontweight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: getTitleSmall(
          context: context,
          fontweight: FontWeight.w400,
          fontSize: 12.sp,
        ),
      ),
      trailing: trailing,
    );
  }
}
