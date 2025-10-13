import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/device_size.dart';
import 'package:chitchat/features/group/presentations/blocs/group_chat/group_chat_bloc.dart';
import 'package:chitchat/features/group/presentations/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class GroupsTile extends StatelessWidget {
  final String groupId;
  final String groupName;
  final int groupAdminId;
  final String groupImageUrl;
  final String groupBio;
  final String lastMessage;
  final String lastImageText;
  final String lastMessageTime;
  final bool isSeenLastMessage;
  final String lastMessageType;
  final int unreadMessagesCount;
  final bool isMe;
  final String createdAt;
  final int groupMembersCount;

  const GroupsTile({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupImageUrl,
    required this.groupBio,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isSeenLastMessage,
    required this.lastImageText,
    required this.lastMessageType,
    required this.unreadMessagesCount,
    required this.isMe,
    required this.groupAdminId,
    required this.createdAt,
    required this.groupMembersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return InkWell(
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: GroupChatPage(
                groupName: groupName,
                groupImageUrl: groupImageUrl,
                groupBio: groupBio,
                groupAdminId: groupAdminId,
                groupId: groupId,
                createdAt: createdAt,
                groupMembersCount: groupMembersCount,
                unreadMessagesCount: unreadMessagesCount,
              ),
              pageTransitionAnimation: PageTransitionAnimation.slideUp,
            );
          },
          borderRadius: BorderRadius.circular(10),
          highlightColor: Colors.transparent,
          splashColor: theme.isDark ? greyColor : darkWhite2,
          child: child,
        );
      },
      child: SizedBox(
        height: 100.h,
        child: Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 75.h,
                width: 75.h,
                decoration: BoxDecoration(
                  border: Border.all(color: blueColor, width: 2),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(2.h),
                  child: CircleAvatar(
                    radius: 35.r,
                    backgroundImage:
                        groupImageUrl.isNotEmpty
                            ? NetworkImage(groupImageUrl)
                            : null,

                    backgroundColor:
                        context.read<ThemeProvider>().isDark
                            ? greyColor
                            : darkWhite,
                    child:
                        groupImageUrl.isEmpty
                            ? Icon(
                              Icons.group,
                              size: 35.h,
                              color:
                                  context.read<ThemeProvider>().isDark
                                      ? darkWhite
                                      : greyColor,
                            )
                            : null,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        groupName,
                        style: getTitleMedium(
                          context: context,
                          fontweight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: context.height() * 0.045,
                          maxWidth: context.width() - 130,
                        ),
                        child: BlocBuilder<GroupChatBloc, GroupChatState>(
                          buildWhen: (_, current) {
                            return (current is NewGroupMessageState &&
                                current.newChat.groupId == groupId);
                          },
                          builder: (context, groupChatState) {
                            if (groupChatState is NewGroupMessageState &&
                                groupChatState.newChat.groupId == groupId) {
                              return _ShowLastMessage(
                                imageText: groupChatState.newChat.imageText,
                                messageType: groupChatState.newChat.messageType,
                                text: groupChatState.newChat.textMessage,
                              );
                            }
                            return _ShowLastMessage(
                              imageText: lastImageText,
                              messageType: lastMessageType,
                              text: lastMessage,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BlocBuilder<GroupChatBloc, GroupChatState>(
                    buildWhen: (_, current) {
                      return (current is NewGroupMessageState &&
                          current.newChat.groupId == groupId);
                    },
                    builder: (context, groupChatState) {
                      if (groupChatState is NewGroupMessageState &&
                          groupChatState.newChat.groupId == groupId) {
                        return Text(
                          formatDate(groupChatState.newChat.time) == "Today"
                              ? formatTime(groupChatState.newChat.time)
                              : formatDate(groupChatState.newChat.time),
                          style: getBodySmall(
                            context: context,

                            fontweight: FontWeight.bold,
                            color: lightGrey,
                          ),
                        );
                      }
                      return Text(
                        formatDate(lastMessageTime) == "Today"
                            ? formatTime(lastMessageTime)
                            : formatDate(lastMessageTime),
                        style: getBodySmall(
                          context: context,
                          fontweight: FontWeight.bold,
                          color: lightGrey,
                        ),
                      );
                    },
                  ),
                  BlocBuilder<GroupChatBloc, GroupChatState>(
                    buildWhen: (_, current) {
                      return (current is UnreadGroupMessagesCountState &&
                          current.groupId == groupId &&
                          current.unreadMessagesCount <= 100);
                    },
                    builder: (context, groupChatState) {
                      if (groupChatState is UnreadGroupMessagesCountState &&
                          groupChatState.groupId == groupId &&
                          groupChatState.unreadMessagesCount <= 100) {
                        return CircleAvatar(
                          radius: 15.r,
                          backgroundColor:
                              groupChatState.unreadMessagesCount > 0
                                  ? blueColor
                                  : Colors.transparent,
                          child: Text(
                            groupChatState.unreadMessagesCount != 0 &&
                                    groupChatState.unreadMessagesCount <= 99
                                ? '${groupChatState.unreadMessagesCount}'
                                : groupChatState.unreadMessagesCount >= 100
                                ? "99+"
                                : "",
                            style: getBodySmall(
                              context: context,
                              fontweight: FontWeight.bold,
                              fontSize:
                                  unreadMessagesCount >= 100 ? 11.sp : null,
                            ),
                          ),
                        );
                      }
                      return CircleAvatar(
                        radius: 15.r,
                        backgroundColor:
                            unreadMessagesCount != 0
                                ? blueColor
                                : Colors.transparent,
                        child: Text(
                          unreadMessagesCount != 0 && unreadMessagesCount <= 99
                              ? '$unreadMessagesCount'
                              : unreadMessagesCount >= 100
                              ? "99+"
                              : "",
                          style: getBodySmall(
                            context: context,
                            fontweight: FontWeight.bold,
                            fontSize: unreadMessagesCount >= 100 ? 11.sp : null,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShowLastMessage extends StatelessWidget {
  final String imageText;
  final String text;
  final String messageType;
  const _ShowLastMessage({
    required this.imageText,
    required this.messageType,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return messageType == "text"
        ? Text(
          text,
          style: getTitleSmall(
            context: context,
            fontweight: FontWeight.bold,
            color: lightGrey,
          ),
        )
        : messageType == "image"
        ? Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.image, color: lightGrey, size: 19.h),
            5.horizontalSpace,
            if (imageText.isNotEmpty)
              Text(
                imageText,
                style: getTitleSmall(
                  context: context,
                  fontweight: FontWeight.bold,
                  color: lightGrey,
                ),
              )
            else
              Text(
                "Photo",
                style: getTitleSmall(
                  context: context,
                  fontweight: FontWeight.bold,
                  color: lightGrey,
                ),
              ),
          ],
        )
        : messageType == "audio"
        ? Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.headphones, color: lightGrey, size: 19.h),
            5.horizontalSpace,
            Text(
              "Audio",
              style: getTitleSmall(
                context: context,
                fontweight: FontWeight.bold,
                color: lightGrey,
              ),
            ),
          ],
        )
        : messageType == "voice"
        ? Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.mic, color: lightGrey, size: 19.h),
            5.horizontalSpace,
            Text(
              "Voice",
              style: getTitleSmall(
                context: context,
                fontweight: FontWeight.bold,
                color: lightGrey,
              ),
            ),
          ],
        )
        : Text(
          "No messages yet",
          style: getTitleSmall(
            context: context,
            fontweight: FontWeight.bold,
            color: lightGrey,
          ),
        );
  }
}
