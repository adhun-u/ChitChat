import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/device_size.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TextMessageTile extends StatelessWidget {
  final String message;
  final int senderId;
  final int receiverId;
  final String messageDate;
  final String oppositeUsername;
  final bool isMe;
  final bool isSeen;
  final String chatId;
  final bool repliedMessage;
  final int currentUserId;
  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;

  const TextMessageTile({
    super.key,
    required this.message,
    required this.receiverId,
    required this.senderId,
    required this.isMe,
    required this.oppositeUsername,
    required this.messageDate,
    required this.isSeen,
    required this.chatId,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: context.height() * 0.03,
        minWidth: repliedMessage ? 100.w : 70.w,
        maxWidth: 200.w,
      ),
      child: IntrinsicWidth(
        stepWidth: 50.w,
        child: Column(
          children: [
            Consumer<ChatStyleProvider>(
              builder: (context, chatStyle, child) {
                return Consumer<ThemeProvider>(
                  builder: (context, theme, _) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(chatStyle.borderRadius),
                          topRight: Radius.circular(chatStyle.borderRadius),
                          bottomLeft: Radius.circular(
                            isMe ? chatStyle.borderRadius : 0,
                          ),
                          bottomRight: Radius.circular(
                            !isMe ? chatStyle.borderRadius : 0,
                          ),
                        ),
                        color:
                            isMe
                                ? chatStyle.chatColor
                                : theme.isDark
                                ? greyColor
                                : darkWhite,
                      ),
                      child: child,
                    );
                  },
                );
              },
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 10.h,
                  ),
                  child: Consumer<ChatStyleProvider>(
                    builder: (context, chatStyle, _) {
                      return Consumer<ThemeProvider>(
                        builder: (context, theme, _) {
                          return Column(
                            crossAxisAlignment:
                                isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              if (repliedMessage)
                                Container(
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    color:
                                        isMe
                                            ? context
                                                    .read<ThemeProvider>()
                                                    .isDark
                                                ? greyColor
                                                : darkWhite
                                            : context
                                                .read<ThemeProvider>()
                                                .isDark
                                            ? darkGrey
                                            : darkWhite2,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      10.horizontalSpace,
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: 10.w,
                                          top: 5.h,
                                          bottom: 5.h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              parentMessageSenderId ==
                                                      currentUserId
                                                  ? "You"
                                                  : oppositeUsername,
                                              style: getTitleSmall(
                                                context: context,
                                                fontweight: FontWeight.bold,
                                                color:
                                                    context
                                                        .read<
                                                          ChatStyleProvider
                                                        >()
                                                        .chatColor,
                                              ),
                                            ),
                                            if (parentMessageType == "text")
                                              Text(
                                                parentText,
                                                style: getTitleSmall(
                                                  context: context,
                                                  fontweight: FontWeight.w400,
                                                  color: lightGrey,
                                                ),
                                              ),
                                            if (parentMessageType == "voice")
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.mic,
                                                    size: 20.h,
                                                    color: lightGrey,
                                                  ),
                                                  5.horizontalSpace,
                                                  Text(
                                                    'Voice message ($parentVoiceDuration)',
                                                  ),
                                                ],
                                              ),
                                            if (parentMessageType == "audio")
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.headphones,
                                                    size: 20.h,
                                                    color: lightGrey,
                                                  ),
                                                  5.horizontalSpace,
                                                  Text(
                                                    'Audio ($parentAudioDuration)',
                                                  ),
                                                ],
                                              ),
                                            if (parentMessageType == "image")
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.photo,
                                                    size: 20.h,
                                                    color: lightGrey,
                                                  ),
                                                  5.horizontalSpace,
                                                  Text('Photo'),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (repliedMessage) 10.verticalSpace,
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  message,
                                  textAlign: TextAlign.left,
                                  style: getTitleMedium(
                                    context: context,
                                    color:
                                        isMe
                                            ? whiteColor
                                            : theme.isDark
                                            ? whiteColor
                                            : blackColor,
                                    fontweight: FontWeight.bold,
                                    fontSize: chatStyle.fontSize,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      formatTime(messageDate),
                                      style: getBodySmall(
                                        context: context,
                                        fontweight: FontWeight.w300,
                                        fontSize: 11.sp,
                                        color: isMe ? whiteColor : null,
                                      ),
                                    ),
                                  ),
                                  if (isMe)
                                    BlocListener<ChatBloc, ChatState>(
                                      listenWhen: (_, current) {
                                        return current is IndicateSeenState;
                                      },
                                      listener: (context, chatState) {
                                        //Changing seen info of selected chat as true
                                        context.read<ChatBloc>().add(
                                          ChangeSeenInfoInSelectedChatsEvent(),
                                        );
                                      },
                                      child: const SizedBox(),
                                    ),
                                  if (isMe)
                                    BlocBuilder<ChatBloc, ChatState>(
                                      buildWhen: (_, current) {
                                        return current is IndicateSeenState;
                                      },
                                      builder: (context, chatState) {
                                        if (chatState is IndicateSeenState) {
                                          return Align(
                                            alignment: Alignment.bottomRight,
                                            child: Icon(
                                              Icons.done_all,
                                              size: 14.sp,
                                              color: whiteColor,
                                            ),
                                          );
                                        }
                                        return isSeen
                                            ? Align(
                                              alignment: Alignment.bottomRight,
                                              child: Icon(
                                                Icons.done_all,
                                                size: 14.sp,
                                                color: whiteColor,
                                              ),
                                            )
                                            : Align(
                                              alignment: Alignment.bottomRight,
                                              child: Icon(
                                                Icons.done,
                                                size: 14.sp,
                                                color: Colors.white,
                                              ),
                                            );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
