import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ListUserTile extends StatelessWidget {
  final String username;
  final int userId;
  final String profilePic;
  final String lastMessage;
  final String lastTime;
  final String messageType;
  final int unreadMessageCount;
  final bool isSeen;
  final bool isMe;
  const ListUserTile({
    super.key,
    required this.username,
    required this.userId,
    required this.profilePic,
    required this.lastMessage,
    required this.messageType,
    required this.lastTime,
    required this.unreadMessageCount,
    required this.isSeen,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 5.h),
      child: SizedBox(
        height: 90.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<ThemeProvider>(
              builder: (context, theme, _) {
                return CircleAvatar(
                  radius: 35.r,
                  backgroundColor: theme.isDark ? greyColor : darkWhite,
                  backgroundImage:
                      profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                  child:
                      profilePic.isEmpty
                          ? Icon(Icons.person, size: 35.h, color: lightGrey)
                          : null,
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 15.h, left: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: getTitleMedium(
                        context: context,
                        fontweight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    BlocBuilder<ChatBloc, ChatState>(
                      buildWhen: (_, current) {
                        return (current is SocketMessagesState &&
                                current.chat.senderId == userId) ||
                            (current is SocketMessagesState &&
                                current.chat.receiverId == userId);
                      },
                      builder: (context, chatState) {
                        if (chatState is SocketMessagesState &&
                            (chatState.chat.senderId == userId ||
                                chatState.chat.receiverId == userId)) {
                          return _ShowLastMessage(
                            subtitle:
                                chatState.chat.type == "text"
                                    ? chatState.chat.textMessage!
                                    : chatState.chat.type == "image"
                                    ? chatState.chat.imageText ?? ""
                                    : "",
                            type: chatState.chat.type,
                          );
                        }
                        return _ShowLastMessage(
                          subtitle: lastMessage,
                          type: messageType,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BlocBuilder<ChatBloc, ChatState>(
                  buildWhen: (_, current) {
                    return (current is SocketMessagesState &&
                        (current.chat.senderId == userId ||
                            (current.chat.receiverId == userId)));
                  },
                  builder: (context, chatState) {
                    if (chatState is SocketMessagesState &&
                        (chatState.chat.senderId == userId ||
                            chatState.chat.receiverId == userId)) {
                      return Text(
                        formatDate(chatState.chat.time) == "Today"
                            ? formatTime(chatState.chat.time)
                            : formatDate(chatState.chat.time),
                        style: getBodySmall(
                          context: context,
                          fontweight: FontWeight.bold,
                          color: lightGrey,
                        ),
                      );
                    }
                    return Text(
                      formatDate(lastTime) == "Today"
                          ? formatTime(lastTime)
                          : formatDate(lastTime),
                      style: getBodySmall(
                        context: context,
                        fontweight: FontWeight.bold,
                        color: lightGrey,
                      ),
                    );
                  },
                ),
                5.verticalSpace,
                if (!isMe)
                  BlocBuilder<ChatBloc, ChatState>(
                    buildWhen: (_, current) {
                      return current is UnreadMessageCountState &&
                          current.senderId == userId &&
                          current.unreadMessagesCount <= 100;
                    },
                    builder: (context, chatState) {
                      if (chatState is UnreadMessageCountState) {
                        return chatState.unreadMessagesCount != 0
                            ? CircleAvatar(
                              radius: 15.r,
                              backgroundColor: blueColor,
                              child: Center(
                                child: Text(
                                  chatState.unreadMessagesCount <= 99
                                      ? "${chatState.unreadMessagesCount}"
                                      : "99+",
                                  style: getBodySmall(
                                    context: context,
                                    fontweight: FontWeight.bold,
                                    color: whiteColor,
                                  ),
                                ),
                              ),
                            )
                            : CircleAvatar(
                              radius: 15.r,
                              backgroundColor: Colors.transparent,
                            );
                      }
                      return unreadMessageCount != 0
                          ? CircleAvatar(
                            radius: 15.r,
                            backgroundColor: blueColor,
                            child: Center(
                              child: Text(
                                unreadMessageCount <= 99
                                    ? "$unreadMessageCount"
                                    : "99+",
                                style: getBodySmall(
                                  context: context,
                                  fontweight: FontWeight.bold,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          )
                          : CircleAvatar(
                            radius: 15.r,
                            backgroundColor: Colors.transparent,
                          );
                    },
                  )
                else
                  BlocBuilder<ChatBloc, ChatState>(
                    buildWhen: (_, current) {
                      return (current is IndicateSeenState &&
                          !isSeen &&
                          current.userId == userId);
                    },
                    builder: (context, chatState) {
                      if (chatState is IndicateSeenState &&
                          chatState.userId == userId &&
                          !isSeen) {
                        return Icon(
                          Icons.done_all,
                          size: 20.h,
                          color: blueColor,
                        );
                      }
                      return Icon(
                        isSeen ? Icons.done_all : Icons.done,
                        size: 20.h,
                        color: isSeen ? blueColor : lightGrey,
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowLastMessage extends StatelessWidget {
  final String type;
  final String subtitle;
  const _ShowLastMessage({required this.subtitle, required this.type});

  @override
  Widget build(BuildContext context) {
    return type == "text"
        ? Text(
          subtitle,
          style: getTitleSmall(context: context, color: lightGrey),
        )
        : type == "image"
        ? Row(
          spacing: 5.w,
          children: [
            Icon(Icons.image, size: 19.h, color: lightGrey),
            subtitle.isNotEmpty
                ? Text(
                  subtitle,
                  style: getTitleSmall(
                    context: context,
                    fontweight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
                : Text(
                  "Photo",
                  style: getTitleSmall(
                    context: context,
                    color: const Color.fromARGB(255, 135, 135, 135),
                  ),
                ),
          ],
        )
        : type == "audio"
        ? Row(
          children: [
            Icon(Icons.headphones, size: 19.h, color: lightGrey),
            5.horizontalSpace,
            Text(
              'Audio',
              style: getTitleSmall(context: context, color: lightGrey),
            ),
          ],
        )
        : type == "voice"
        ? Row(
          children: [
            Icon(Icons.mic, size: 19.h, color: lightGrey),
            5.horizontalSpace,
            Text(
              'Voice message',
              style: getTitleSmall(context: context, color: lightGrey),
            ),
          ],
        )
        : Text(
          subtitle,
          style: getTitleSmall(context: context, color: lightGrey),
        );
  }
}
