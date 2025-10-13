import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/presentations/providers/audio_provider.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/common/presentations/providers/download_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/icons.dart';
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

class GroupAudioTile extends StatelessWidget {
  final String audioPath;
  final String audioDuration;
  final String audioTitle;
  final String time;
  final bool isMe;
  final bool isSeen;
  final bool isDownloaded;
  final String chatId;
  final String groupId;
  final int senderId;
  final String senderName;
  final int totalMembersCount;
  final bool repliedMessage;

  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;
  final String parentMessageSenderName;
  const GroupAudioTile({
    super.key,
    required this.audioPath,
    required this.audioDuration,
    required this.audioTitle,
    required this.time,
    required this.isMe,
    required this.isSeen,
    required this.isDownloaded,
    required this.chatId,
    required this.groupId,
    required this.senderId,
    required this.senderName,
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
    return Consumer<ChatStyleProvider>(
      builder: (context, chatStyle, child) {
        return Container(
          height: 75.h,
          width: 290.w,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          10.horizontalSpace,
          Consumer<ChatStyleProvider>(
            builder: (context, chatStyle, child) {
              return CircleAvatar(
                radius: 33.r,
                backgroundColor: isMe ? whiteColor : chatStyle.chatColor,
                child: child,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Selector<ChatStyleProvider, Color>(
                  selector: (context, chatStyle) {
                    return chatStyle.chatColor;
                  },
                  builder: (context, chatColor, _) {
                    return Image.asset(
                      audioIcon,
                      color: isMe ? chatColor : whiteColor,
                      height: 25.h,
                      width: 25.h,
                    );
                  },
                ),
                Selector<ChatStyleProvider, Color>(
                  selector: (context, chatStyle) {
                    return chatStyle.chatColor;
                  },
                  builder: (context, chatColor, _) {
                    return Consumer<AudioProvider>(
                      builder: (context, audio, _) {
                        return Text(
                          audio.currentPlayingAudioId == chatId
                              ? audio.currentPostion
                              : audioDuration,
                          style: getBodySmall(
                            context: context,
                            fontweight: FontWeight.w500,
                            fontSize: 10.sp,
                            color: isMe ? chatColor : whiteColor,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          10.horizontalSpace,
          Consumer2<DownloadProvider, AudioProvider>(
            builder: (context, downloader, audio, _) {
              return isDownloaded
                  ? audio.isPlaying && audio.currentPlayingAudioId == chatId
                      ? GestureDetector(
                        onTap: () async {
                          //Pausing the audio if it is playing
                          await context.read<AudioProvider>().pauseAudio();
                        },
                        child: Icon(Icons.pause),
                      )
                      : GestureDetector(
                        onTap: () async {
                          if (!audio.isPlaying &&
                              audio.currentPlayingAudioId == chatId) {
                            //Resuming the audio if it is paused
                            await context.read<AudioProvider>().playAudio();
                          } else {
                            //Playing the audio if the audio is not played
                            await context
                                .read<AudioProvider>()
                                .setupAudioPlayer(audioPath, chatId);
                            if (context.mounted) {
                              await context.read<AudioProvider>().playAudio();
                            }
                          }
                        },
                        child: Icon(Icons.play_arrow_rounded),
                      )
                  : GestureDetector(
                    onTap: () async {
                      //Downloading the audio
                      final Either<String?, ErrorMessageModel?> result =
                          await context
                              .read<DownloadProvider>()
                              .downloadAndSaveFile(
                                fileUrl: audioPath,
                                chatId: chatId,
                                fileType: "audio",
                              );

                      //Saving the downloaded file
                      result.fold(
                        (downloadedPath) {
                          if (downloadedPath != null) {
                            context.read<GroupChatBloc>().add(
                              SaveGroupChatFileEvent(
                                chatId: chatId,
                                filePath: downloadedPath,
                                imageText: "",
                                senderId: senderId,
                                senderName: senderName,
                                fileType: "audio",
                                time: time,
                                audioVideoDuration: audioDuration,
                                audioVideoTitle: audioTitle,
                                voiceDuration: "",
                                fileUrl: audioPath,
                                groupId: groupId,
                                totalMembersCount: totalMembersCount,
                                shouldSendToMembers: false,
                                groupImageUrl: "",
                                groupName: "",
                                parentAudioDuration: parentAudioDuration,
                                parentMessageSenderId: parentMessageSenderId,
                                parentMessageSenderName:
                                    parentMessageSenderName,

                                parentMessageType: parentMessageType,
                                parentText: parentText,
                                parentVoiceDuration: parentVoiceDuration,
                                repliedMessage: repliedMessage,
                                groupAdminUserId: 0,
                                groupBio: "",
                                groupCreatedAt: ""
                              ),
                            );
                          }
                        },
                        (error) {
                          if (error != null) {
                            showErrorMessage(context, 'Something went wrong');
                          }
                        },
                      );
                    },
                    child:
                        downloader.isDownloading &&
                                downloader.downloadingFileId == chatId
                            ? SizedBox(
                              height: 30.h,
                              width: 30.h,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: blueColor,
                                    value: downloader.indication,
                                    strokeWidth: 2,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      //Cancelling download process
                                      context
                                          .read<DownloadProvider>()
                                          .cancelDownloading();
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 20.h,
                                      color:
                                          context.read<ThemeProvider>().isDark
                                              ? lightGrey
                                              : darkWhite2,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : const Icon(CupertinoIcons.down_arrow),
                  );
            },
          ),
          8.horizontalSpace,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30.h,
                width: 150.w,
                child: Consumer<AudioProvider>(
                  builder: (context, audio, _) {
                    return ProgressBar(
                      progress:
                          audio.currentPlayingAudioId == chatId
                              ? audio.currentDuration
                              : const Duration(seconds: 0),
                      total:
                          audio.currentPlayingAudioId == chatId
                              ? audio.totalDuration
                              : const Duration(seconds: 10),
                      onSeek: (duration) async {
                        if (audio.currentPlayingAudioId == chatId) {
                          //Seeking to a specific postion of currently playing audio
                          context.read<AudioProvider>().seekAudio(duration);
                        }
                      },
                      timeLabelLocation: TimeLabelLocation.none,
                      thumbRadius: 10.r,
                      progressBarColor: whiteColor,
                      thumbGlowRadius: 12.r,
                      baseBarColor: const Color.fromARGB(255, 111, 111, 111),
                      thumbColor: darkWhite2,
                      barHeight: 4.h,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80.w,
                    height: 15.h,
                    child: Text(
                      audioTitle,
                      style: getBodySmall(
                        context: context,
                        fontweight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: isMe ? whiteColor : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  10.horizontalSpace,
                  Text(
                    formatTime(time),
                    style: getBodySmall(
                      context: context,
                      fontweight: FontWeight.w300,
                      fontSize: 12.sp,
                      color: isMe ? whiteColor : null,
                    ),
                  ),
                  if (isMe)
                    BlocListener<GroupChatBloc, GroupChatState>(
                      listenWhen: (_, current) {
                        return (current is MessageSeenIndicatorState);
                      },
                      listener: (context, groupChatState) {
                        if (groupChatState is MessageSeenIndicatorState) {
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
                  if (isMe) 5.horizontalSpace,
                  if (isMe)
                    BlocBuilder<GroupChatBloc, GroupChatState>(
                      buildWhen: (_, current) {
                        return current is MessageSeenIndicatorState && !isSeen;
                      },
                      builder: (context, groupChatState) {
                        if (groupChatState is MessageSeenIndicatorState &&
                            !isSeen) {
                          return Icon(
                            Icons.done_all,
                            size: 17.h,
                            color: whiteColor,
                          );
                        }
                        return Icon(Icons.done, size: 17.h, color: whiteColor);
                      },
                    ),
                  if (isMe) 5.horizontalSpace,
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GroupAudioUploadTile extends StatelessWidget {
  final String audioPath;
  final String audioDuration;
  final String audioTitle;
  final String currentUsername;
  final int currentUserId;
  final String chatId;
  final String groupId;
  final String time;
  final int totalMembersCount;
  final String groupName;
  final String groupImageUrl;
  final String groupBio;
    final String groupCreatedAt;
  final int groupAdminUserId;
  final int parentMessageSenderId;
  final String parentMessageType;
  final String parentText;
  final String parentVoiceDuration;
  final String parentAudioDuration;
  final String parentMessageSenderName;
  final bool repliedMessage;
  const GroupAudioUploadTile({
    super.key,
    required this.audioPath,
    required this.audioTitle,
    required this.audioDuration,
    required this.currentUsername,
    required this.currentUserId,
    required this.chatId,
    required this.groupId,
    required this.time,
    required this.totalMembersCount,
    required this.groupName,
    required this.groupImageUrl,
    required this.groupBio,
    required this.groupCreatedAt,
    required this.groupAdminUserId,
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
    return Consumer<ChatStyleProvider>(
      builder: (context, chatStyle, child) {
        return Container(
          height: 75.h,
          width: 290.w,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          10.horizontalSpace,
          CircleAvatar(
            radius: 33.r,
            backgroundColor: whiteColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Selector<ChatStyleProvider, Color>(
                  selector: (context, chatStyle) {
                    return chatStyle.chatColor;
                  },
                  builder: (context, chatColor, _) {
                    return Image.asset(
                      audioIcon,
                      color: chatColor,
                      height: 25.h,
                      width: 25.h,
                    );
                  },
                ),
                Text(
                  audioDuration,
                  style: getBodySmall(
                    context: context,
                    fontweight: FontWeight.w500,
                    fontSize: 10.sp,
                    color: blackColor,
                  ),
                ),
              ],
            ),
          ),
          10.horizontalSpace,
          BlocListener<GroupChatBloc, GroupChatState>(
            listenWhen: (_, current) {
              return (current is UploadGroupAudioErrorState &&
                      current.chatId == chatId) ||
                  (current is UploadGroupAudioSuccessState &&
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
                    imageText: "",
                    messageType: "audio",
                    textMessage: "",
                    time: time,
                  ),
                );
                //Changing last message time
                context.read<GroupBloc>().add(
                  ChangeLastGroupMessageTimeEvent(time: time, groupId: groupId),
                );
              }
              if (groupChatState is UploadGroupAudioSuccessState &&
                  groupChatState.chatId == chatId) {
                //Downloading the audio
                final Either<String?, ErrorMessageModel?> result = await context
                    .read<DownloadProvider>()
                    .downloadAndSaveFile(
                      fileUrl: groupChatState.audioUrl,
                      chatId: chatId,
                      fileType: "audio",
                    );

                result.fold(
                  (dowloadedAudioPath) {
                    if (dowloadedAudioPath != null) {
                      //Saving and sending to all members of this group except current user
                      context.read<GroupChatBloc>().add(
                        SaveGroupChatFileEvent(
                          chatId: chatId,
                          filePath: dowloadedAudioPath,
                          imageText: "",
                          senderId: currentUserId,
                          senderName: currentUsername,
                          fileType: "audio",
                          time: time,
                          audioVideoDuration: audioDuration,
                          audioVideoTitle: audioTitle,
                          voiceDuration: "",
                          fileUrl: groupChatState.audioUrl,
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
              if (groupChatState is UploadGroupAudioErrorState &&
                  groupChatState.chatId == chatId) {
                //Showing error message
                if (context.mounted) {
                  showErrorMessage(context, "Something went wrong");
                }
              }
            },
            child: const SizedBox(),
          ),
          Consumer<DownloadProvider>(
            builder: (context, downloader, _) {
              return BlocBuilder<GroupChatBloc, GroupChatState>(
                buildWhen: (_, current) {
                  return (current is UploadGroupAudioLoadingState &&
                          current.chatId == chatId) ||
                      (current is UploadGroupAudioErrorState &&
                          current.chatId == chatId) ||
                      (current is UploadGroupAudioSuccessState &&
                          current.chatId == chatId);
                },
                builder: (context, groupChatState) {
                  if (groupChatState is UploadGroupAudioLoadingState &&
                      groupChatState.chatId == chatId) {
                    return SizedBox(
                      height: 30.h,
                      width: 30.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: whiteColor,
                            strokeWidth: 2,
                          ),
                          GestureDetector(
                            onTap: () {
                              //Cancelling upload process
                              context.read<GroupChatBloc>().add(
                                CancelGroupMediaUploadProcess(chatId: chatId),
                              );
                            },
                            child: Icon(
                              Icons.close,
                              size: 20.h,
                              color: whiteColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return downloader.isDownloading &&
                          downloader.downloadingFileId == chatId
                      ? SizedBox(
                        height: 30.h,
                        width: 30.h,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: whiteColor,
                              strokeWidth: 2,
                              value: downloader.indication,
                            ),

                            GestureDetector(
                              onTap: () {
                                //Cancelling download process
                                context
                                    .read<DownloadProvider>()
                                    .cancelDownloading();
                              },
                              child: Icon(
                                Icons.close,
                                size: 20.h,
                                color: whiteColor,
                              ),
                            ),
                          ],
                        ),
                      )
                      : const Icon(CupertinoIcons.down_arrow);
                },
              );
            },
          ),
          10.horizontalSpace,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30.h,
                width: 150.w,
                child: ProgressBar(
                  progress: const Duration(seconds: 0),
                  total: const Duration(seconds: 10),
                  onSeek: (duration) async {},
                  timeLabelLocation: TimeLabelLocation.none,
                  thumbRadius: 10.r,
                  progressBarColor: whiteColor,
                  thumbGlowRadius: 12.r,
                  baseBarColor: const Color.fromARGB(255, 111, 111, 111),
                  thumbColor: darkWhite2,
                  barHeight: 4.h,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80.w,
                    height: 15.h,
                    child: Text(
                      audioTitle,
                      style: getBodySmall(
                        context: context,
                        fontweight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: whiteColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  10.horizontalSpace,
                  Text(
                    formatTime(time),
                    style: getBodySmall(
                      context: context,
                      fontweight: FontWeight.w300,
                      fontSize: 12.sp,
                      color: whiteColor,
                    ),
                  ),
                  5.horizontalSpace,
                  Icon(Icons.done, size: 17.h, color: whiteColor),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
