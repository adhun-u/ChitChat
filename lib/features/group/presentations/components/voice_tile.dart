import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/presentations/providers/audio_provider.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/common/presentations/providers/download_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:chitchat/features/group/presentations/blocs/group_chat/group_chat_bloc.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GroupVoiceTile extends StatelessWidget {
  final String chatId;
  final String groupId;
  final int senderId;
  final String senderName;
  final String voicePath;
  final String voiceDuration;
  final String time;
  final bool isSeen;
  final bool isMe;
  final bool isDownloaded;
  final int totalMembersCount;
  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;
  final String parentMessageSenderName;
  final bool repliedMessage;
  const GroupVoiceTile({
    super.key,
    required this.chatId,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.voicePath,
    required this.voiceDuration,
    required this.time,
    required this.isSeen,
    required this.isMe,
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
    return SizedBox(
      height: 70.h,
      width: 280.w,
      child: Row(
        children: [
          10.horizontalSpace,
          CircleAvatar(
            radius: 30.r,
            backgroundColor:
                isMe ? whiteColor : context.read<ChatStyleProvider>().chatColor,

            child: Icon(
              Icons.mic,
              color:
                  isMe
                      ? context.read<ChatStyleProvider>().chatColor
                      : whiteColor,
            ),
          ),
          10.horizontalSpace,
          Consumer<DownloadProvider>(
            builder: (context, downloader, _) {
              return downloader.isDownloading &&
                      downloader.downloadingFileId == chatId &&
                      downloader.indication != 0.0
                  ? Padding(
                    padding: EdgeInsets.only(right: 5.w),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: darkWhite2,
                          value: downloader.indication,
                        ),
                        GestureDetector(
                          onTap: () {
                            //Cancelling downloading process
                            context
                                .read<DownloadProvider>()
                                .cancelDownloading();
                          },
                          child: Icon(
                            Icons.close,
                            color: whiteColor,
                            size: 17.h,
                          ),
                        ),
                      ],
                    ),
                  )
                  : !isDownloaded
                  ? GestureDetector(
                    onTap: () async {
                      final Either<String?, ErrorMessageModel?> result =
                          await context
                              .read<DownloadProvider>()
                              .downloadAndSaveFile(
                                fileUrl: voicePath,
                                chatId: chatId,
                                fileType: "voice",
                              );
                      result.fold(
                        (filePath) {
                          if (filePath != null) {
                            context.read<GroupChatBloc>().add(
                              SaveGroupChatFileEvent(
                                senderName: senderName,
                                chatId: chatId,
                                voiceDuration: voiceDuration,
                                senderId: senderId,
                                imageText: "",
                                fileType: "voice",
                                filePath: filePath,
                                groupId: groupId,
                                groupImageUrl: "",
                                groupName: "",
                                parentMessageSenderName:
                                    parentMessageSenderName,
                                shouldSendToMembers: false,
                                totalMembersCount: totalMembersCount,
                                time: time,
                                fileUrl: voicePath,
                                audioVideoDuration: "",
                                audioVideoTitle: "",
                                parentAudioDuration: parentAudioDuration,
                                parentMessageSenderId: parentMessageSenderId,
                                parentMessageType: parentMessageType,
                                parentText: parentText,
                                parentVoiceDuration: parentVoiceDuration,
                                repliedMessage: repliedMessage,
                                groupAdminUserId: 0,
                                groupBio: "",
                                groupCreatedAt: "",
                              ),
                            );
                          }
                        },
                        (errorModel) {
                          showErrorMessage(
                            context,
                            "An error occured while downloading",
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 5.w),
                      child: Icon(
                        CupertinoIcons.down_arrow,
                        color: isMe ? whiteColor : null,
                      ),
                    ),
                  )
                  : Consumer<AudioProvider>(
                    builder: (context, audio, _) {
                      return audio.currentPlayingAudioId == chatId &&
                              !audio.isPlaying
                          ? GestureDetector(
                            onTap: () async {
                              //Playing the voice message
                              context.read<AudioProvider>().playAudio();
                            },
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: isMe ? whiteColor : null,
                            ),
                          )
                          : audio.currentPlayingAudioId == chatId &&
                              audio.isPlaying
                          ? GestureDetector(
                            onTap: () async {
                              //Pausing the voice message
                              await context.read<AudioProvider>().pauseAudio();
                            },
                            child: Icon(
                              Icons.pause,
                              color: isMe ? whiteColor : null,
                            ),
                          )
                          : GestureDetector(
                            onTap: () async {
                              //Setting this voice as source and playing it
                              await context
                                  .read<AudioProvider>()
                                  .setupAudioPlayer(voicePath, chatId);
                              if (context.mounted) {
                                await context.read<AudioProvider>().playAudio();
                              }
                            },
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: isMe ? whiteColor : null,
                            ),
                          );
                    },
                  );
            },
          ),
          10.horizontalSpace,
          SizedBox(
            width: 150.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                10.horizontalSpace,
                Padding(
                  padding: EdgeInsets.only(left: 5.w),
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
                          //Seeking audio to specific position
                          if (audio.currentPlayingAudioId == chatId) {
                            await context.read<AudioProvider>().seekAudio(
                              duration,
                            );
                          }
                        },
                        timeLabelLocation: TimeLabelLocation.none,
                        barHeight: 5.h,
                        thumbColor: darkWhite2,
                        baseBarColor: const Color.fromARGB(255, 111, 111, 111),
                        progressBarColor: whiteColor,
                        thumbGlowRadius: 11.r,
                        thumbRadius: 9.r,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Selector<AudioProvider, String>(
                        selector: (_, audio) {
                          return audio.currentPlayingAudioId == chatId
                              ? audio.currentPostion
                              : voiceDuration;
                        },
                        shouldRebuild: (_, _) {
                          return context
                                  .watch<AudioProvider>()
                                  .currentPlayingAudioId ==
                              chatId;
                        },
                        builder: (context, currentDur, _) {
                          return Text(
                            currentDur,
                            style: getBodySmall(
                              context: context,
                              fontweight: FontWeight.w500,
                              fontSize: 12.sp,
                              color: isMe ? whiteColor : null,
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          Text(
                            formatTime(time),
                            style: getBodySmall(
                              context: context,
                              fontweight: FontWeight.w300,
                              fontSize: 10.sp,
                              color: isMe ? whiteColor : null,
                            ),
                          ),
                          10.horizontalSpace,
                          if (isMe)
                            BlocListener<GroupChatBloc, GroupChatState>(
                              listenWhen: (_, current) {
                                return (current is MessageSeenIndicatorState);
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
                            BlocBuilder<GroupChatBloc, GroupChatState>(
                              buildWhen: (_, current) {
                                return current is MessageSeenIndicatorState &&
                                    !isSeen;
                              },
                              builder: (context, groupChatState) {
                                if (groupChatState
                                        is MessageSeenIndicatorState &&
                                    !isSeen) {
                                  return Icon(
                                    Icons.done_all,
                                    size: 17.h,
                                    color: whiteColor,
                                  );
                                }
                                return Icon(
                                  Icons.done,
                                  size: 17.h,
                                  color: whiteColor,
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GroupVoiceUploadTile extends StatelessWidget {
  final String time;
  final String voiceDuration;
  final int currentUserId;
  final String currentUsername;
  final int totalMembersCount;
  final String chatId;
  final String groupId;
  final String groupName;
  final String groupImageUrl;
  final String groupBio;
  final int groupAdminUserId;
  final String groupCreatedAt;
  final int parentMessageSenderId;
  final String parentMessageType;
  final String parentText;
  final String parentVoiceDuration;
  final String parentAudioDuration;
  final String parentMessageSenderName;
  final bool repliedMessage;
  const GroupVoiceUploadTile({
    super.key,
    required this.time,
    required this.voiceDuration,
    required this.currentUserId,
    required this.currentUsername,
    required this.totalMembersCount,
    required this.chatId,
    required this.groupId,
    required this.groupName,
    required this.groupImageUrl,
    required this.groupAdminUserId,
    required this.groupCreatedAt,
    required this.groupBio,
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
    return SizedBox(
      height: 70.h,
      width: 280.w,
      child: Row(
        children: [
          10.horizontalSpace,
          CircleAvatar(
            radius: 30.r,
            backgroundColor: whiteColor,
            child: Selector<ChatStyleProvider, Color>(
              selector: (context, chatStyle) {
                return chatStyle.chatColor;
              },
              builder: (context, color, _) {
                return Icon(Icons.mic, color: color);
              },
            ),
          ),
          15.horizontalSpace,
          BlocListener<GroupChatBloc, GroupChatState>(
            listenWhen: (_, current) {
              return (current is UploadGroupVoiceErrorState &&
                      current.chatId == chatId) ||
                  (current is UploadGroupVoiceSuccessState &&
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
              if (groupChatState is SaveGroupChatFileSuccessState) {
                //changing the position of this group from the tile
                context.read<GroupBloc>().add(
                  ChangeGroupPositionEvent(
                    groupId: groupId,
                    imageText: "",
                    messageType: "voice",
                    textMessage: "",
                    time: time,
                  ),
                );
                //Changing last message time
                context.read<GroupBloc>().add(
                  ChangeLastGroupMessageTimeEvent(time: time, groupId: groupId),
                );
              }

              if (groupChatState is UploadGroupVoiceSuccessState &&
                  groupChatState.chatId == chatId) {
                //Downloading the voice message that current user sent
                final Either<String?, ErrorMessageModel?> result = await context
                    .read<DownloadProvider>()
                    .downloadAndSaveFile(
                      fileUrl: groupChatState.voiceUrl,
                      chatId: chatId,
                      fileType: "voice",
                    );

                result.fold(
                  (downloadVoicePath) {
                    if (downloadVoicePath != null) {
                      //Saving the voice path to local storage and sending to group members
                      if (context.mounted) {
                        context.read<GroupChatBloc>().add(
                          SaveGroupChatFileEvent(
                            chatId: chatId,
                            filePath: downloadVoicePath,
                            imageText: "",
                            senderId: currentUserId,
                            senderName: currentUsername,
                            fileType: "voice",
                            time: time,
                            audioVideoDuration: "",
                            audioVideoTitle: "",
                            voiceDuration: voiceDuration,
                            fileUrl: groupChatState.voiceUrl,
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
                    }
                  },
                  (error) {
                    if (error != null) {
                      showErrorMessage(context, "Something went wrong");
                    }
                  },
                );
              }
              if (groupChatState is UploadGroupVoiceErrorState &&
                  groupChatState.chatId == chatId) {
                if (context.mounted) {
                  showErrorMessage(context, "Something went wrong");
                }
              }
            },
            child: const SizedBox.shrink(),
          ),
          SizedBox(
            height: 33.h,
            width: 33.h,
            child: Consumer<DownloadProvider>(
              builder: (context, downloader, _) {
                return BlocBuilder<GroupChatBloc, GroupChatState>(
                  buildWhen: (_, current) {
                    return (current is UploadGroupVoiceErrorState &&
                            current.chatId == chatId) ||
                        (current is UploadGroupVoiceLoadingState &&
                            current.chatId == chatId) ||
                        (current is UploadGroupVoiceSuccessState &&
                            current.chatId == chatId);
                  },
                  builder: (context, groupChatState) {
                    if (groupChatState is UploadGroupVoiceLoadingState &&
                        groupChatState.chatId == chatId) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          const CircularProgressIndicator(color: whiteColor),
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
                      );
                    }
                    if (downloader.isDownloading &&
                        downloader.downloadingFileId == chatId) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: whiteColor,
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
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
          20.horizontalSpace,
          SizedBox(
            width: 140.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                10.horizontalSpace,
                ProgressBar(
                  progress: const Duration(seconds: 0),
                  total: const Duration(seconds: 0),
                  onSeek: (duration) async {},
                  timeLabelLocation: TimeLabelLocation.none,
                  barHeight: 5.h,
                  thumbColor: darkWhite2,
                  baseBarColor: const Color.fromARGB(255, 111, 111, 111),
                  progressBarColor: whiteColor,
                  thumbGlowRadius: 13.r,
                  thumbRadius: 11.r,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        voiceDuration,
                        style: getBodySmall(
                          context: context,
                          fontweight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: whiteColor,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            formatTime(time),
                            style: getBodySmall(
                              context: context,
                              fontweight: FontWeight.w300,
                              fontSize: 10.sp,
                              color: whiteColor,
                            ),
                          ),
                          10.horizontalSpace,
                          Icon(Icons.done, size: 17.h, color: whiteColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
