import 'dart:io';
import 'dart:ui';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/presentations/pages/show_image_prev.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/common/presentations/providers/download_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:chitchat/features/group/presentations/blocs/group_chat/group_chat_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GroupImageTile extends StatelessWidget {
  final String groupId;
  final String chatId;
  final int senderId;
  final String senderName;
  final String imagePath;
  final String imageText;
  final String time;
  final bool isMe;
  final bool isSeen;
  final bool isDownloaded;
  final int totalMembersCount;
  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;
  final String parentMessageSenderName;
  final bool repliedMessage;
  const GroupImageTile({
    super.key,
    required this.groupId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.imagePath,
    required this.imageText,
    required this.time,
    required this.isMe,
    required this.isSeen,
    required this.isDownloaded,
    required this.totalMembersCount,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
    required this.parentMessageSenderName,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 600.h, maxWidth: 300.w),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Consumer2<ThemeProvider, ChatStyleProvider>(
                builder: (context, theme, chatStyle, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isMe ? chatStyle.chatColor : Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(chatStyle.borderRadius),
                        topRight: Radius.circular(chatStyle.borderRadius),
                        bottomLeft:
                            isMe
                                ? Radius.circular(chatStyle.borderRadius)
                                : Radius.circular(0),

                        bottomRight:
                            isMe
                                ? Radius.circular(0)
                                : Radius.circular(chatStyle.borderRadius),
                      ),
                    ),
                    child: child,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(5.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ShowImagePrev(
                                  imagePath: imagePath,
                                  username: senderName,
                                  sentImageTime:
                                      "${formatDate(time)} at ${formatTime(time)}",
                                  heroTag: chatId,
                                );
                              },
                            ),
                          );
                        },
                        child: Hero(
                          tag: chatId,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              isDownloaded
                                  ? Selector<ChatStyleProvider, double>(
                                    selector: (context, chatStyle) {
                                      return chatStyle.borderRadius;
                                    },
                                    builder: (context, borderRadius, child) {
                                      return ClipRRect(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(
                                              borderRadius,
                                            ),
                                        child: child,
                                      );
                                    },
                                    child: Image.file(
                                      File(imagePath),
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                  : ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                      sigmaX: 2,
                                      sigmaY: 2,
                                    ),
                                    child: Selector<ChatStyleProvider, double>(
                                      selector: (context, chatStyle) {
                                        return chatStyle.borderRadius;
                                      },
                                      builder: (context, borderRadius, child) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(
                                                borderRadius,
                                              ),
                                          child: child,
                                        );
                                      },
                                      child: Image.network(
                                        imagePath,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 10.w,
                                  right: 10.w,
                                  bottom: 3.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatTime(time),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: whiteColor,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          BoxShadow(
                                            color: blackColor.withAlpha(100),
                                            offset: const Offset(1, -1),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                          ),
                                          BoxShadow(
                                            color: blackColor.withAlpha(100),
                                            offset: const Offset(-1, 1),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isMe)
                                      BlocListener<
                                        GroupChatBloc,
                                        GroupChatState
                                      >(
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
                                    if (isMe)
                                      BlocBuilder<
                                        GroupChatBloc,
                                        GroupChatState
                                      >(
                                        buildWhen: (_, current) {
                                          return current
                                                  is MessageSeenIndicatorState &&
                                              !isSeen;
                                        },
                                        builder: (context, groupChatState) {
                                          if (groupChatState
                                                  is MessageSeenIndicatorState &&
                                              !isSeen) {
                                            return const _SeenMark(
                                              isSeen: true,
                                            );
                                          }
                                          return _SeenMark(isSeen: isSeen);
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (imageText.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            top: 7.h,
                            left: 3.w,
                            right: 3.w,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              imageText,
                              textAlign: TextAlign.left,
                              style: getTitleSmall(
                                context: context,
                                fontweight: FontWeight.w700,
                                fontSize: 13.sp,
                                color: isMe ? whiteColor : null,
                              ),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (!isDownloaded)
                Consumer2<ThemeProvider, DownloadProvider>(
                  builder: (context, theme, downloader, _) {
                    return GestureDetector(
                      onTap: () async {
                        if (!isDownloaded &&
                            !downloader.isDownloading &&
                            downloader.downloadingFileId != chatId) {
                          //Downloading the image
                          final Either<String?, ErrorMessageModel?> result =
                              await context
                                  .read<DownloadProvider>()
                                  .downloadAndSaveFile(
                                    fileUrl: imagePath,
                                    chatId: chatId,
                                    fileType: "image",
                                  );
                          result.fold(
                            (downloadedImagePath) {
                              if (downloadedImagePath != null) {
                                context.read<GroupChatBloc>().add(
                                  SaveGroupChatFileEvent(
                                    chatId: chatId,
                                    filePath: downloadedImagePath,
                                    imageText: imageText,
                                    senderId: senderId,
                                    senderName: senderName,
                                    fileType: "image",
                                    time: time,
                                    audioVideoDuration: "",
                                    audioVideoTitle: "",
                                    voiceDuration: "",
                                    fileUrl: "",
                                    groupId: groupId,
                                    totalMembersCount: totalMembersCount,
                                    shouldSendToMembers: false,
                                    groupImageUrl: "",
                                    groupName: "",
                                    parentAudioDuration: parentAudioDuration,
                                    parentMessageSenderId:
                                        parentMessageSenderId,
                                    parentMessageSenderName:
                                        parentMessageSenderName,

                                    parentMessageType: parentMessageType,
                                    parentText: parentText,
                                    parentVoiceDuration: parentVoiceDuration,
                                    repliedMessage: repliedMessage,
                                    groupAdminUserId: 0,
                                    groupBio: "",
                                    groupCreatedAt: '',
                                  ),
                                );
                              }
                            },
                            (error) {
                              if (error != null) {
                                //Showing an error message if downloading process was failed
                                showErrorMessage(
                                  context,
                                  "Something went wrong",
                                );
                              }
                            },
                          );
                        }
                      },
                      child: Center(
                        child: CircleAvatar(
                          radius: 30.r,
                          backgroundColor: theme.isDark ? greyColor : darkWhite,
                          child:
                              downloader.downloadingFileId == chatId &&
                                      downloader.isDownloading
                                  ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: blueColor,
                                        strokeWidth: 2,
                                        value: downloader.indication,
                                      ),

                                      Icon(
                                        Icons.close,
                                        color:
                                            theme.isDark
                                                ? whiteColor
                                                : blackColor,
                                        size: 30.h,
                                      ),
                                    ],
                                  )
                                  : Icon(
                                    CupertinoIcons.down_arrow,
                                    color: theme.isDark ? darkWhite : greyColor,
                                  ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupImageUploadingTile extends StatelessWidget {
  final String imagePath;
  final String imageText;
  final String groupId;
  final String chatId;
  final int currentUserId;
  final String currentUsername;
  final String time;
  final int totalMembersCount;
  final String groupName;
  final String groupImageUrl;
  final int groupAdminUserId;
  final String groupBio;
  final String groupCreatedAt;
  final int parentMessageSenderId;
  final String parentMessageType;
  final String parentText;
  final String parentVoiceDuration;
  final String parentAudioDuration;
  final String parentMessageSenderName;
  final bool repliedMessage;
  const GroupImageUploadingTile({
    super.key,
    required this.imagePath,
    required this.imageText,
    required this.chatId,
    required this.groupId,
    required this.currentUserId,
    required this.currentUsername,
    required this.time,
    required this.totalMembersCount,
    required this.groupImageUrl,
    required this.groupName,
    required this.groupAdminUserId,
    required this.groupBio,
    required this.groupCreatedAt,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
    required this.parentMessageSenderName,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 600.h, maxWidth: 300.w),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Stack(
            children: [
              BlocListener<GroupChatBloc, GroupChatState>(
                listenWhen: (_, current) {
                  return (current is UploadGroupChatImageErrorState &&
                          current.chatId == chatId) ||
                      (current is UploadGroupChatImageSuccessState &&
                          current.chatId == chatId) ||
                      (current is SaveGroupChatFileErrorState &&
                          current.chatId == chatId) ||
                      (current is SaveGroupChatFileSuccessState &&
                          current.chatId == chatId);
                },
                listener: (context, groupChatState) async {
                  if (groupChatState is SaveGroupChatFileErrorState &&
                      groupChatState.chatId == chatId) {
                    showErrorMessage(context, "Something went wrong");
                  }
                  if (groupChatState is SaveGroupChatFileSuccessState &&
                      groupChatState.chatId == chatId) {
                    //changing the position of this group from the tile
                    context.read<GroupBloc>().add(
                      ChangeGroupPositionEvent(
                        groupId: groupId,
                        imageText: imageText,
                        messageType: "image",
                        textMessage: "",
                        time: time,
                      ),
                    );
                    //Changing last message time
                    context.read<GroupBloc>().add(
                      ChangeLastGroupMessageTimeEvent(
                        time: time,
                        groupId: groupId,
                      ),
                    );
                  }
                  if (groupChatState is UploadGroupChatImageErrorState) {
                    //Showing upload image error
                    showErrorMessage(context, "Something went wrong");
                  }
                  if (groupChatState is UploadGroupChatImageSuccessState) {
                    //Downloading the image
                    Either<String?, ErrorMessageModel?> result = await context
                        .read<DownloadProvider>()
                        .downloadAndSaveFile(
                          fileUrl: groupChatState.imageUrl,
                          chatId: chatId,
                          fileType: "image",
                        );
                    result.fold(
                      (imagePath) {
                        if (imagePath != null) {
                          //Saving and sending the file to all members of this group except current user
                          context.read<GroupChatBloc>().add(
                            SaveGroupChatFileEvent(
                              chatId: chatId,
                              filePath: imagePath,
                              imageText: imageText,
                              senderId: currentUserId,
                              senderName: currentUsername,
                              fileType: "image",
                              time: time,
                              audioVideoDuration: "",
                              audioVideoTitle: "",
                              voiceDuration: "",
                              fileUrl: groupChatState.imageUrl,
                              groupId: groupId,
                              totalMembersCount: totalMembersCount,
                              shouldSendToMembers: true,
                              groupImageUrl: groupImageUrl,
                              groupName: groupName,
                              parentAudioDuration: parentAudioDuration,
                              parentMessageSenderId: parentMessageSenderId,
                              parentMessageSenderName: parentMessageSenderName,
                              parentMessageType: parentMessageType,
                              parentText: parentText,
                              parentVoiceDuration: parentVoiceDuration,
                              repliedMessage: repliedMessage,
                              groupAdminUserId: groupAdminUserId,
                              groupBio: groupBio,
                              groupCreatedAt: groupCreatedAt,
                            ),
                          );
                        }
                      },
                      (error) {
                        if (error != null) {
                          showErrorMessage(context, "Something went wrong");
                        }
                      },
                    );
                  }
                },
                child: const SizedBox(),
              ),
              Consumer2<ThemeProvider, ChatStyleProvider>(
                builder: (context, theme, chatStyle, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: chatStyle.chatColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(chatStyle.borderRadius),
                        topRight: Radius.circular(chatStyle.borderRadius),
                        bottomLeft: Radius.circular(chatStyle.borderRadius),

                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: child,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(5.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.contain,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10.w,
                              right: 10.w,
                              bottom: 7.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatTime(time),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: whiteColor,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      BoxShadow(
                                        color: blackColor.withAlpha(100),
                                        offset: const Offset(1, -1),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                      ),
                                      BoxShadow(
                                        color: blackColor.withAlpha(100),
                                        offset: const Offset(-1, 1),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                const _SeenMark(isSeen: false),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (imageText.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            top: 7.h,
                            left: 3.w,
                            right: 3.w,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              imageText,
                              textAlign: TextAlign.left,
                              style: getTitleSmall(
                                context: context,
                                fontweight: FontWeight.w700,
                                fontSize: 13.sp,
                                color: whiteColor,
                              ),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<GroupChatBloc, GroupChatState>(
                buildWhen: (_, current) {
                  return (current is UploadGroupChatImageErrorState &&
                          current.chatId == chatId) ||
                      (current is UploadGroupChatImageLoadingState &&
                          current.chatId == chatId) ||
                      (current is UploadGroupChatImageSuccessState &&
                          current.chatId == chatId);
                },
                builder: (context, groupChatState) {
                  return Consumer2<ThemeProvider, DownloadProvider>(
                    builder: (context, theme, downloader, _) {
                      return Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30.r,
                              backgroundColor:
                                  theme.isDark ? greyColor : darkWhite,
                              child:
                                  downloader.downloadingFileId == chatId &&
                                          downloader.isDownloading
                                      ? CircularProgressIndicator(
                                        color: blueColor,
                                        strokeWidth: 2,
                                        value: downloader.indication,
                                      )
                                      : const CircularProgressIndicator(
                                        color: blueColor,
                                        strokeWidth: 2,
                                      ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (!downloader.isDownloading &&
                                    downloader.downloadingFileId != chatId) {
                                  //Cancelling uploading proccess
                                  context.read<GroupChatBloc>().add(
                                    CancelGroupMediaUploadProcess(
                                      chatId: chatId,
                                    ),
                                  );
                                } else if (downloader.isDownloading &&
                                    downloader.downloadingFileId == chatId) {
                                  //Cancelling downloading process
                                  context
                                      .read<DownloadProvider>()
                                      .cancelDownloading();
                                }
                              },
                              child: Icon(
                                Icons.close,
                                color: lightGrey,
                                size: 32.h,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeenMark extends StatelessWidget {
  final bool isSeen;
  const _SeenMark({required this.isSeen});

  @override
  Widget build(BuildContext context) {
    return isSeen
        ? Padding(
          padding: EdgeInsets.only(bottom: 10.h, right: 5.w),
          child: Icon(
            Icons.done_all,
            size: 17.h,
            color: whiteColor,
            shadows: const [
              BoxShadow(
                color: blackColor,
                offset: Offset(1, -1),
                spreadRadius: 5,
                blurRadius: 5,
              ),
              BoxShadow(
                color: blackColor,
                offset: Offset(-1, 1),
                spreadRadius: 5,
                blurRadius: 5,
              ),
            ],
          ),
        )
        : Padding(
          padding: EdgeInsets.only(bottom: 5.h, right: 5.w),
          child: Icon(
            Icons.done,
            size: 17.h,
            color: whiteColor,
            shadows: const [
              BoxShadow(
                color: blackColor,
                offset: Offset(1, -1),
                spreadRadius: 5,
                blurRadius: 5,
              ),
              BoxShadow(
                color: blackColor,
                offset: Offset(-1, 1),
                spreadRadius: 5,
                blurRadius: 5,
              ),
            ],
          ),
        );
  }
}
