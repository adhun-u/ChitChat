import 'dart:developer';

import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ReplyContainer extends StatelessWidget {
  final String parentMessageSenderName;
  final String parentMessageType;
  final String? parentMessageVoiceDuration;
  final String? parentMessageAudioDuration;
  final String? parentMessage;
  final Function() onCloseButtonClicked;
  const ReplyContainer({
    super.key,
    required this.parentMessageSenderName,
    required this.parentMessageType,
    this.parentMessage,
    this.parentMessageAudioDuration,
    this.parentMessageVoiceDuration,
    required this.onCloseButtonClicked,
  });

  @override
  Widget build(BuildContext context) {
    log(parentMessageType);
    return Container(
      height: 65.h,
      width: 300.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.read<ThemeProvider>().isDark ? greyColor : darkWhite,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
            child: Container(
              width: 5.w,
              decoration: BoxDecoration(
                color: context.read<ChatStyleProvider>().chatColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
          ),
          10.horizontalSpace,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                5.verticalSpace,
                Text(
                  parentMessageSenderName,
                  style: getTitleSmall(
                    context: context,
                    fontweight: FontWeight.bold,
                    color: context.read<ChatStyleProvider>().chatColor,
                  ),
                ),
                if (parentMessageType == "text")
                  Text(
                    parentMessage ?? "",
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.w400,
                      color: lightGrey,
                    ),
                  ),

                if (parentMessageType == "voice")
                  Row(
                    children: [
                      Icon(Icons.mic, size: 20.h, color: lightGrey),
                      5.horizontalSpace,
                      Text(
                        'Voice message ($parentMessageVoiceDuration)',
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.w400,
                          color: lightGrey,
                        ),
                      ),
                    ],
                  ),
                if (parentMessageType == "audio")
                  Row(
                    children: [
                      Icon(Icons.headphones, size: 20.h, color: lightGrey),
                      5.horizontalSpace,
                      Text(
                        'Audio : ($parentMessageAudioDuration)',
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.w400,
                          color: lightGrey,
                        ),
                      ),
                    ],
                  ),
                if (parentMessageType == "image")
                  Row(
                    children: [
                      Icon(Icons.photo, size: 20.h, color: lightGrey),
                      5.horizontalSpace,
                      Text(
                        'Image',
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.w400,
                          color: lightGrey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 5.w, bottom: 25.h),
            child: GestureDetector(
              onTap: () {
                onCloseButtonClicked();
              },
              child: Icon(Icons.close, size: 20.h, color: lightGrey),
            ),
          ),
        ],
      ),
    );
  }
}
