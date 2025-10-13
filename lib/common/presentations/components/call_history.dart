import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallHistoryContainer extends StatelessWidget {
  final String callType;
  final bool isMe;
  final String callTime;
  const CallHistoryContainer({
    super.key,
    required this.callType,
    required this.isMe,
    required this.callTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      width: 210.w,
      decoration: BoxDecoration(
        color:
            isMe
                ? context.read<ChatStyleProvider>().chatColor
                : context.read<ThemeProvider>().isDark
                ? greyColor
                : darkWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            context.read<ChatStyleProvider>().borderRadius,
          ),
          topRight: Radius.circular(
            context.read<ChatStyleProvider>().borderRadius,
          ),
          bottomLeft:
              isMe
                  ? Radius.circular(
                    context.read<ChatStyleProvider>().borderRadius,
                  )
                  : Radius.circular(0),

          bottomRight:
              !isMe
                  ? Radius.circular(
                    context.read<ChatStyleProvider>().borderRadius,
                  )
                  : Radius.circular(0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 10.w, right: 5.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor:
                  isMe
                      ? whiteColor
                      : context.read<ChatStyleProvider>().chatColor,
              child: Icon(
                callType == "audioCall"
                    ? Icons.phone
                    : CupertinoIcons.video_camera_solid,
                color:
                    isMe
                        ? context.read<ChatStyleProvider>().chatColor
                        : whiteColor,
              ),
            ),
            10.horizontalSpace,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callType == "audioCall" ? 'Audio call' : "Video call",
                  style: getTitleSmall(
                    context: context,
                    fontweight: FontWeight.bold,
                    color: isMe ? whiteColor : null,
                  ),
                ),
                5.horizontalSpace,
                Text(
                  formatTime(callTime),
                  style: getBodySmall(
                    context: context,
                    fontweight: FontWeight.w400,
                    color: isMe ? whiteColor : lightGrey,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
