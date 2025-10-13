import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/group/presentations/blocs/group_chat/group_chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GroupTextMessageTile extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool isSeen;
  final String chatId;
  final String groupId;
  const GroupTextMessageTile({
    super.key,
    required this.text,
    required this.isMe,
    required this.isSeen,
    required this.time,
    required this.chatId,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
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
                      color: isMe ? chatStyle.chatColor : Colors.transparent,
                    ),
                    child: child,
                  );
                },
              );
            },
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isMe ? 5.h : 0,
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                text,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    formatTime(time),
                                    style: getBodySmall(
                                      context: context,
                                      fontweight: FontWeight.w300,
                                      fontSize: 11.sp,
                                      color: isMe ? whiteColor : null,
                                    ),
                                  ),
                                ),
                                if (isMe) 5.horizontalSpace,
                                if (isMe)
                                  BlocListener<GroupChatBloc, GroupChatState>(
                                    listenWhen: (_, current) {
                                      return (current
                                          is MessageSeenIndicatorState);
                                    },
                                    listener: (context, groupChatState) {
                                      if (groupChatState
                                          is MessageSeenIndicatorState) {
                                        //Changing seen info in selected chats
                                        context.read<GroupChatBloc>().add(
                                          ChangeSeenInfoInGroupSelectedChatsEvent(
                                            chatId: chatId,
                                          ),
                                        );
                                      }
                                    },
                                    child: const SizedBox(),
                                  ),
                                isMe
                                    ? Padding(
                                      padding: EdgeInsets.only(bottom: 5.h),
                                      child: BlocBuilder<
                                        GroupChatBloc,
                                        GroupChatState
                                      >(
                                        buildWhen: (_, current) {
                                          return current
                                                  is MessageSeenIndicatorState &&
                                              !isSeen;
                                        },
                                        builder: (context, chatState) {
                                          if (chatState
                                                  is MessageSeenIndicatorState &&
                                              !isSeen) {
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
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Icon(
                                                  Icons.done_all,
                                                  size: 14.sp,
                                                  color: whiteColor,
                                                ),
                                              )
                                              : Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Icon(
                                                  Icons.done,
                                                  size: 14.sp,
                                                  color: Colors.white,
                                                ),
                                              );
                                        },
                                      ),
                                    )
                                    : const SizedBox(),
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
    );
  }
}
