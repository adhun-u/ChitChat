import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/presentations/providers/audio_provider.dart';
import 'package:chitchat/common/presentations/providers/download_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:chitchat/features/home/presentations/blocs/user/user_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class VoiceTile extends StatelessWidget {
  final String chatId;
  final int senderId;
  final int receiverId;
  final int currentUserId;
  final String receiverName;
  final bool isMe;
  final String voicePath;
  final String voiceDuration;
  final String time;
  final bool isDownloaded;
  final bool isSeen;
  final bool repliedMessage;
  final int parentMessageSenderId;
  final String parentMessageType;
  final String parentText;
  final String parentVoiceDuration;
  final String parentAudioDuration;

  const VoiceTile({
    super.key,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.currentUserId,
    required this.isMe,
    required this.voicePath,
    required this.voiceDuration,
    required this.time,
    required this.isDownloaded,
    required this.isSeen,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, ChatStyleProvider>(
      builder: (context, theme, chatStyle, child) {
        return Container(
          height: repliedMessage ? 140.h : 75.h,
          width: 290.w,
          decoration: BoxDecoration(
            color:
                isMe
                    ? chatStyle.chatColor
                    : theme.isDark
                    ? greyColor
                    : darkWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(chatStyle.borderRadius),
              topRight: Radius.circular(chatStyle.borderRadius),
              bottomRight:
                  isMe
                      ? Radius.circular(0)
                      : Radius.circular(chatStyle.borderRadius),
              bottomLeft:
                  isMe
                      ? Radius.circular(chatStyle.borderRadius)
                      : Radius.circular(0),
            ),
          ),
          child: child,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (repliedMessage)
            Container(
              height: 60.h,
              width: 270.w,
              decoration: BoxDecoration(
                color:
                    isMe
                        ? context.read<ThemeProvider>().isDark
                            ? greyColor
                            : darkWhite
                        : context.read<ThemeProvider>().isDark
                        ? darkGrey
                        : darkWhite2,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  10.horizontalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parentMessageSenderId == currentUserId
                            ? "You"
                            : receiverName,
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.bold,
                          color: context.read<ChatStyleProvider>().chatColor,
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
                            Icon(Icons.mic, size: 20.h, color: lightGrey),
                            5.horizontalSpace,
                            Text(
                              'Voice message ($parentVoiceDuration)',
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
                            Icon(
                              Icons.headphones,
                              size: 20.h,
                              color: lightGrey,
                            ),
                            5.horizontalSpace,
                            Text(
                              'Audio ($parentAudioDuration)',
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
                              'Photo',
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
                  10.horizontalSpace,
                ],
              ),
            ),
          if (repliedMessage) 10.verticalSpace,
          Row(
            children: [
              10.horizontalSpace,
              Consumer2<ThemeProvider, ChatStyleProvider>(
                builder: (context, theme, chatStyle, _) {
                  return CircleAvatar(
                    radius: 30.r,
                    backgroundColor: isMe ? whiteColor : chatStyle.chatColor,
                    child: Icon(
                      Icons.mic,
                      color: isMe ? chatStyle.chatColor : whiteColor,
                    ),
                  );
                },
              ),
              10.horizontalSpace,
              !isDownloaded && !isMe
                  ? Consumer<DownloadProvider>(
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
                                  color: blueColor,
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
                                    color:
                                        context.read<ThemeProvider>().isDark
                                            ? whiteColor
                                            : blackColor,
                                    size: 17.h,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : GestureDetector(
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
                                    if (!context.mounted) {
                                      return;
                                    }
                                    context.read<ChatBloc>().add(
                                      SaveFileEvent(
                                        senderName: "",
                                        senderProfilePic: "",
                                        chatId: chatId,
                                        imagePath: "",
                                        audioPath: "",
                                        voicePath: filePath,
                                        voiceDuration: voiceDuration,
                                        senderId: senderId,
                                        receiverId: receiverId,
                                        currentUserId: currentUserId,
                                        imageText: "",
                                        type: "voice",
                                        time: time,
                                        fileUrl: voicePath,
                                        audioVideoDuration: "",
                                        audioVideoTitle: "",
                                        isDownloaded: isDownloaded,
                                        publicId: "",
                                        parentAudioDuration:
                                            parentAudioDuration,
                                        parentMessageSenderId:
                                            parentMessageSenderId,
                                        parentMessageType: parentMessageType,
                                        parentText: parentText,
                                        parentVoiceDuration:
                                            parentVoiceDuration,
                                        repliedMessage: repliedMessage,
                                        senderBio: "",
                                      ),
                                    );
                                  }
                                },
                                (errorModel) {
                                  if (!context.mounted) {
                                    return;
                                  }
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
                                color: const Color.fromARGB(255, 108, 108, 108),
                              ),
                            ),
                          );
                    },
                  )
                  : Consumer<AudioProvider>(
                    builder: (context, audio, child) {
                      return audio.isPlaying &&
                              audio.currentPlayingAudioId == chatId
                          ? GestureDetector(
                            onTap: () async {
                              await context.read<AudioProvider>().pauseAudio();
                            },
                            child: Icon(
                              Icons.pause,
                              color:
                                  isMe
                                      ? whiteColor
                                      : const Color.fromARGB(
                                        255,
                                        108,
                                        108,
                                        108,
                                      ),
                            ),
                          )
                          : GestureDetector(
                            onTap: () async {
                              if (audio.currentPlayingAudioId != chatId) {
                                await context
                                    .read<AudioProvider>()
                                    .setupAudioPlayer(voicePath, chatId);
                              }
                              if (context.mounted) {
                                await context.read<AudioProvider>().playAudio();
                              }
                            },
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color:
                                  isMe
                                      ? whiteColor
                                      : const Color.fromARGB(
                                        255,
                                        108,
                                        108,
                                        108,
                                      ),
                            ),
                          );
                    },
                  ),
              10.horizontalSpace,
              SizedBox(
                width: 140,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    15.verticalSpace,
                    Consumer<AudioProvider>(
                      builder: (context, audio, _) {
                        return ProgressBar(
                          progress:
                              audio.currentPlayingAudioId == chatId
                                  ? audio.currentDuration
                                  : const Duration(seconds: 0),
                          total:
                              audio.currentPlayingAudioId == chatId
                                  ? audio.totalDuration
                                  : const Duration(seconds: 0),
                          onSeek: (duration) async {
                            if (audio.currentPlayingAudioId == chatId) {
                              await audio.seekAudio(duration);
                            }
                          },
                          timeLabelLocation: TimeLabelLocation.none,
                          barHeight: 5.h,
                          thumbColor: darkWhite2,
                          baseBarColor: const Color.fromARGB(
                            255,
                            111,
                            111,
                            111,
                          ),
                          progressBarColor: whiteColor,
                          thumbGlowRadius: 13.r,
                          thumbRadius: 11.r,
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer2<AudioProvider, ThemeProvider>(
                            builder: (context, audio, theme, _) {
                              return Text(
                                audio.currentPlayingAudioId == chatId
                                    ? audio.currentPostion
                                    : voiceDuration,
                                style: getBodySmall(
                                  context: context,
                                  fontweight: FontWeight.w500,
                                  fontSize: 12.sp,
                                  color:
                                      isMe
                                          ? whiteColor
                                          : theme.isDark
                                          ? darkWhite
                                          : greyColor,
                                ),
                              );
                            },
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Consumer<ThemeProvider>(
                                builder: (context, theme, _) {
                                  return Text(
                                    formatTime(time),
                                    style: getBodySmall(
                                      context: context,
                                      fontweight: FontWeight.w300,
                                      fontSize: 10.sp,
                                      color:
                                          isMe
                                              ? whiteColor
                                              : theme.isDark
                                              ? darkWhite
                                              : greyColor,
                                    ),
                                  );
                                },
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
                              if (isMe) 10.horizontalSpace,
                              if (isMe)
                                BlocBuilder<ChatBloc, ChatState>(
                                  buildWhen: (_, current) {
                                    return current is IndicateSeenState &&
                                        !isSeen;
                                  },
                                  builder: (context, chatState) {
                                    if (chatState is IndicateSeenState) {
                                      return Icon(
                                        Icons.done_all,
                                        size: 17.h,
                                        color: whiteColor,
                                      );
                                    }
                                    return isSeen
                                        ? Icon(
                                          Icons.done_all,
                                          size: 17.h,
                                          color: whiteColor,
                                        )
                                        : Icon(
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
        ],
      ),
    );
  }
}

class VoiceLoadingTile extends StatelessWidget {
  final String chatId;
  final int currentUserId;
  final String currentUserName;
  final String currentUserProfilePic;
  final String currentUserBio;
  final int receiverId;
  final String receiverName;
  final String voiceDuration;
  final String time;
  final bool repliedMessage;

  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;

  const VoiceLoadingTile({
    super.key,
    required this.chatId,
    required this.currentUserName,
    required this.currentUserProfilePic,
    required this.currentUserBio,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
    required this.voiceDuration,
    required this.time,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: repliedMessage ? 140.h : 75.h,
      width: 290.w,
      decoration: BoxDecoration(
        color: context.read<ChatStyleProvider>().chatColor,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (repliedMessage)
            Container(
              height: 60.h,
              width: 270.w,
              decoration: BoxDecoration(
                color:
                    context.read<ThemeProvider>().isDark
                        ? greyColor
                        : darkWhite,

                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  10.horizontalSpace,

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parentMessageSenderId == currentUserId
                            ? "You"
                            : receiverName,
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.bold,
                          color: context.read<ChatStyleProvider>().chatColor,
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
                            Icon(Icons.mic, size: 20.h, color: lightGrey),
                            5.horizontalSpace,
                            Text(
                              'Voice message ($parentVoiceDuration)',
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
                            Icon(
                              Icons.headphones,
                              size: 20.h,
                              color: lightGrey,
                            ),
                            5.horizontalSpace,
                            Text(
                              'Audio ($parentAudioDuration)',
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
                              'Photo',
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
                  10.horizontalSpace,
                ],
              ),
            ),
          if (repliedMessage) 10.verticalSpace,
          Row(
            children: [
              10.horizontalSpace,
              Consumer<ChatStyleProvider>(
                builder: (context, chatStyle, _) {
                  return CircleAvatar(
                    radius: 30.r,
                    backgroundColor: whiteColor,
                    child: Icon(Icons.mic, color: chatStyle.chatColor),
                  );
                },
              ),
              10.horizontalSpace,
              SizedBox(
                height: 33.h,
                width: 35.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BlocListener<ChatBloc, ChatState>(
                      listenWhen: (_, current) {
                        return (current is UploadVoiceSuccessState) ||
                            (current is SaveFileSuccessState &&
                                current.chatId == chatId);
                      },
                      listener: (context, chatState) async {
                        if (chatState is UploadVoiceSuccessState) {
                          //Downloading the voice using the url if the voice is upload successfully
                          final Either<String?, ErrorMessageModel?> result =
                              await context
                                  .read<DownloadProvider>()
                                  .downloadAndSaveFile(
                                    fileUrl: chatState.voiceUrl,
                                    chatId: chatId,
                                    fileType: "voice",
                                  );

                          result.fold(
                            (filePath) {
                              if (filePath != null && context.mounted) {
                                //If the voice is downloaded successfully , then saving it
                                context.read<ChatBloc>().add(
                                  SaveFileEvent(
                                    chatId: chatId,
                                    senderName: currentUserName,
                                    senderProfilePic: currentUserProfilePic,
                                    imagePath: "",
                                    audioPath: "",
                                    voicePath: filePath,
                                    voiceDuration: voiceDuration,
                                    senderId: currentUserId,
                                    receiverId: receiverId,
                                    currentUserId: currentUserId,
                                    imageText: "",
                                    type: "voice",
                                    time: time,
                                    fileUrl: chatState.voiceUrl,
                                    audioVideoDuration: "",
                                    audioVideoTitle: "",
                                    isDownloaded: true,
                                    publicId: chatState.publicId,
                                    parentAudioDuration: parentAudioDuration,
                                    parentMessageSenderId:
                                        parentMessageSenderId,
                                    parentMessageType: parentMessageType,
                                    parentText: parentText,
                                    parentVoiceDuration: parentVoiceDuration,
                                    repliedMessage: repliedMessage,
                                    senderBio: currentUserBio,
                                  ),
                                );
                              }
                            },
                            (errorModel) {
                              if (!context.mounted) {
                                return;
                              }
                              showErrorMessage(
                                context,
                                "An error occured while uploading",
                              );
                            },
                          );
                        }
                        if (chatState is SaveFileSuccessState &&
                            chatState.chatId == chatId) {
                          if (context.mounted) {
                            //Changing the position of the user that current was is sending this image
                            context.read<UserBloc>().add(
                              ChangePositionOfUserEvent(
                                userId: receiverId,
                                lastTextMessage: "",
                                lastMessageType: "voice",
                                lastAudioDuration: "",
                                lastVoiceDuration: voiceDuration,
                                lastImageText: "",
                                lastMessageTime: time,
                              ),
                            );

                            //Changing the last message
                            context.read<UserBloc>().add(
                              ChangeLastMessageTimeEvent(
                                lastMessageTime: time,
                                userId: receiverId,
                              ),
                            );
                          }
                        }
                      },
                      child: const SizedBox(),
                    ),
                    BlocBuilder<ChatBloc, ChatState>(
                      buildWhen: (_, current) {
                        return current is UploadVoiceLoadingState &&
                                current.chatId == chatId ||
                            current is SaveFileLoadingState &&
                                current.chatId == chatId;
                      },
                      builder: (context, chatState) {
                        if (chatState is UploadVoiceLoadingState ||
                            chatState is SaveFileLoadingState) {
                          return Consumer<DownloadProvider>(
                            builder: (context, downloader, _) {
                              return GestureDetector(
                                onTap: () {
                                  //Cancelling downloading
                                  context
                                      .read<DownloadProvider>()
                                      .cancelDownloading();
                                },
                                child: CircularProgressIndicator(
                                  color: whiteColor,
                                  value:
                                      downloader.isDownloading &&
                                              downloader.downloadingFileId ==
                                                  chatId
                                          ? downloader.indication
                                          : null,
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    BlocBuilder<ChatBloc, ChatState>(
                      buildWhen: (_, current) {
                        return current is UploadVoiceLoadingState &&
                                current.chatId == chatId ||
                            current is SaveFileLoadingState &&
                                current.chatId == chatId;
                      },
                      builder: (context, chatState) {
                        return GestureDetector(
                          onTap: () {
                            //Cancelling the uploading process
                            if (chatState is UploadVoiceLoadingState) {
                              context.read<ChatBloc>().add(
                                CancelUploadingProcess(chatId: chatId),
                              );
                            }
                          },
                          child: Icon(
                            Icons.close,
                            color: whiteColor,
                            size: 17.h,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              15.horizontalSpace,
              SizedBox(
                width: 140,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    15.verticalSpace,
                    ProgressBar(
                      progress: const Duration(minutes: 0),
                      total: const Duration(minutes: 0),
                      timeLabelLocation: TimeLabelLocation.none,
                      barHeight: 5.h,
                      thumbColor: darkWhite2,
                      baseBarColor: const Color.fromARGB(255, 111, 111, 111),
                      progressBarColor: whiteColor,
                      thumbGlowRadius: 13.r,
                      thumbRadius: 11.r,
                    ),
                    Row(
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
                          mainAxisSize: MainAxisSize.min,
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
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
