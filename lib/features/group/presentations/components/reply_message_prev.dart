import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ReplyMessagePrev extends StatelessWidget {
  final String message;
  final String messageType;
  final String senderName;
  final int senderId;
  final String audioDuration;
  final String voiceDuration;
  const ReplyMessagePrev({
    super.key,
    required this.message,
    required this.messageType,
    required this.senderId,
    required this.senderName,
    required this.audioDuration,
    required this.voiceDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.read<ThemeProvider>().isDark ? darkGrey : darkWhite2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          10.horizontalSpace,
          Padding(
            padding: EdgeInsets.only(right: 10.w, top: 5.h, bottom: 5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderId ==
                          context.read<CurrentUserProvider>().currentUser.userId
                      ? "You"
                      : senderName,
                  style: getTitleSmall(
                    context: context,
                    fontweight: FontWeight.bold,
                    color: context.read<ChatStyleProvider>().chatColor,
                  ),
                ),
                if (messageType == "text")
                  Text(
                    message,
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.w400,
                      color: lightGrey,
                    ),
                  ),
                if (messageType == "voice")
                  Row(
                    children: [
                      Icon(Icons.mic, size: 20.h, color: lightGrey),
                      5.horizontalSpace,
                      Text('Voice message ($voiceDuration)'),
                    ],
                  ),
                if (messageType == "audio")
                  Row(
                    children: [
                      Icon(Icons.headphones, size: 20.h, color: lightGrey),
                      5.horizontalSpace,
                      Text('Audio ($audioDuration)'),
                    ],
                  ),
                if (messageType == "image")
                  Row(
                    children: [
                      Icon(Icons.photo, size: 20.h, color: lightGrey),
                      5.horizontalSpace,
                      Text('Photo'),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
