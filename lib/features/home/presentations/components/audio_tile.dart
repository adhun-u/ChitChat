import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/presentations/providers/audio_provider.dart';
import 'package:chitchat/common/presentations/providers/download_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/icons.dart';
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

class AudioTile extends StatelessWidget {
  final String audioPath;
  final String audioDuration;
  final String audioTitle;
  final String chatId;
  final int senderId;
  final String receiverName;
  final int receiverId;
  final int currentUserId;
  final String time;
  final bool isMe;
  final bool isSeen;
  final bool isDownloaded;

  final bool repliedMessage;

  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;

  const AudioTile({
    required this.audioPath,
    required this.audioDuration,
    required this.audioTitle,
    required this.chatId,
    required this.time,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.currentUserId,
    required this.isMe,
    required this.isSeen,
    required this.isDownloaded,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, ChatStyleProvider>(
      builder: (context, theme, chatStyle, child) {
        return Container(
          height: repliedMessage ? 145.h : 75.h,
          width: 290.w,
          decoration: BoxDecoration(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              10.horizontalSpace,
              Consumer<ChatStyleProvider>(
                builder: (context, chatStyle, _) {
                  return CircleAvatar(
                    radius: 30.r,
                    backgroundColor: isMe ? whiteColor : chatStyle.chatColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Consumer<ChatStyleProvider>(
                          builder: (context, chatStyle, _) {
                            return Image.asset(
                              audioIcon,
                              color: isMe ? chatStyle.chatColor : whiteColor,
                              height: 25.h,
                              width: 25.h,
                            );
                          },
                        ),
                        Consumer<AudioProvider>(
                          builder: (context, audio, _) {
                            return Text(
                              audio.currentPlayingAudioId == chatId
                                  ? audio.currentPostion
                                  : audioDuration,
                              style: getBodySmall(
                                context: context,
                                fontweight: FontWeight.w500,
                                fontSize: 10.sp,
                                color: isMe ? blackColor : whiteColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              10.horizontalSpace,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer2<AudioProvider, DownloadProvider>(
                        builder: (context, audio, downloader, _) {
                          return GestureDetector(
                            onTap: () async {
                              if (!isDownloaded) {
                                //Downloading the audio file
                                final Either<String?, ErrorMessageModel?>
                                result = await context
                                    .read<DownloadProvider>()
                                    .downloadAndSaveFile(
                                      fileUrl: audioPath,
                                      chatId: chatId,
                                      fileType: "audio",
                                    );
                                //Checking whether the audio downloaded or not
                                result.fold(
                                  (downloadedPath) {
                                    if (downloadedPath != null) {
                                      context.read<ChatBloc>().add(
                                        SaveFileEvent(
                                          chatId: chatId,
                                          senderName: "",
                                          senderProfilePic: "",
                                          imagePath: "",
                                          audioPath: downloadedPath,
                                          senderId: senderId,
                                          receiverId: receiverId,
                                          currentUserId: currentUserId,
                                          imageText: "",
                                          type: "audio",
                                          time: time,
                                          fileUrl: audioPath,
                                          audioVideoDuration: audioDuration,
                                          audioVideoTitle: audioTitle,
                                          isDownloaded: true,
                                          publicId: "",
                                          voiceDuration: "",
                                          voicePath: "",
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
                              } else if (!audio.isPlaying && isDownloaded) {
                                //Setting a source to play the audio
                                if (audio.currentPlayingAudioId != chatId) {
                                  if (!context.mounted) {
                                    return;
                                  }
                                  await context
                                      .read<AudioProvider>()
                                      .setupAudioPlayer(audioPath, chatId);
                                }
                                if (context.mounted) {
                                  //Playing the audio
                                  await context
                                      .read<AudioProvider>()
                                      .playAudio();
                                }
                              } else {
                                if (!isDownloaded) {
                                  return;
                                }
                                if (!context.mounted) {
                                  return;
                                }
                                //Pausing the playing audio
                                await context
                                    .read<AudioProvider>()
                                    .pauseAudio();
                              }
                            },
                            child:
                                downloader.isDownloading &&
                                        downloader.downloadingFileId == chatId
                                    ? Consumer<ThemeProvider>(
                                      builder: (context, theme, _) {
                                        return Padding(
                                          padding: EdgeInsets.only(right: 5.w),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: whiteColor,
                                                value: downloader.indication,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  //Cancelling download
                                                  context
                                                      .read<DownloadProvider>()
                                                      .cancelDownloading();
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  size: 19.h,
                                                  color:
                                                      context
                                                              .read<
                                                                ThemeProvider
                                                              >()
                                                              .isDark
                                                          ? whiteColor
                                                          : blackColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                    : !isDownloaded &&
                                        !downloader.isDownloading &&
                                        downloader.downloadingFileId != chatId
                                    ? const Icon(
                                      CupertinoIcons.down_arrow,
                                      color: Color.fromARGB(255, 108, 108, 108),
                                    )
                                    : audio.isPlaying &&
                                        chatId == audio.currentPlayingAudioId
                                    ? const Icon(Icons.pause, color: whiteColor)
                                    : const Icon(
                                      Icons.play_arrow,
                                      color: whiteColor,
                                    ),
                          );
                        },
                      ),
                      15.horizontalSpace,
                      15.verticalSpace,
                      SizedBox(
                        height: 30.h,
                        width: 150.w,
                        child: Center(
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
                                  if (!context.mounted) {
                                    return;
                                  }
                                  if (audio.currentPlayingAudioId != chatId) {
                                    return;
                                  }
                                  await context.read<AudioProvider>().seekAudio(
                                    duration,
                                  );
                                },
                                timeLabelLocation: TimeLabelLocation.none,
                                thumbRadius: 10.r,
                                progressBarColor: whiteColor,
                                thumbGlowRadius: 12.r,
                                baseBarColor: const Color.fromARGB(
                                  255,
                                  111,
                                  111,
                                  111,
                                ),
                                thumbColor: darkWhite2,
                                barHeight: 4.h,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: isMe ? 110.w : 125.w,
                        height: 15.h,
                        child: Consumer<ThemeProvider>(
                          builder: (context, theme, _) {
                            return Text(
                              audioTitle,
                              style: getBodySmall(
                                context: context,
                                fontweight: FontWeight.w500,
                                fontSize: 12.sp,
                                color:
                                    isMe
                                        ? whiteColor
                                        : theme.isDark
                                        ? whiteColor
                                        : blackColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                      10.horizontalSpace,
                      Consumer<ThemeProvider>(
                        builder: (context, theme, _) {
                          return Text(
                            formatTime(time),
                            style: getBodySmall(
                              context: context,
                              fontweight: FontWeight.w300,
                              fontSize: 12.sp,
                              color:
                                  isMe
                                      ? whiteColor
                                      : theme.isDark
                                      ? darkWhite2
                                      : greyColor,
                            ),
                          );
                        },
                      ),
                      if (isMe) 5.horizontalSpace,
                      if (isMe)
                        BlocBuilder<ChatBloc, ChatState>(
                          buildWhen: (_, current) {
                            return current is IndicateSeenState && isMe;
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
            ],
          ),
        ],
      ),
    );
  }
}

class AudioUploadingTile extends StatelessWidget {
  final String audioPath;
  final String audioDuration;
  final String audioTitle;
  final String time;
  final String chatId;
  final int senderId;
  final int receiverId;
  final String receiverName;
  final int currentUserId;
  final String currentUsername;
  final String currentUserProfilePic;
  final String currentUserBio;
  final bool repliedMessage;

  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;

  const AudioUploadingTile({
    required this.audioPath,
    required this.audioDuration,
    required this.audioTitle,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.currentUsername,
    required this.currentUserProfilePic,
    required this.currentUserBio,
    required this.currentUserId,
    required this.time,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatStyleProvider>(
      builder: (context, chatStyle, child) {
        return Container(
          height: repliedMessage ? 145.h : 75.h,
          width: 290.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(chatStyle.borderRadius),
              topRight: Radius.circular(chatStyle.borderRadius),
              bottomLeft: Radius.circular(chatStyle.borderRadius),
              bottomRight: Radius.circular(0),
            ),
            color: chatStyle.chatColor,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              10.horizontalSpace,
              CircleAvatar(
                radius: 30.r,
                backgroundColor: whiteColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<ChatStyleProvider>(
                      builder: (context, chatStyle, _) {
                        return Image.asset(
                          audioIcon,
                          color: chatStyle.chatColor,
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
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              BlocListener<ChatBloc, ChatState>(
                listenWhen: (_, current) {
                  return (current is UploadAudioSuccessState) ||
                      (current is SaveFileSuccessState &&
                          current.senderId == currentUserId &&
                          current.chatId == chatId) ||
                      (current is UploadFileError);
                },
                listener: (context, chatState) async {
                  if (chatState is UploadAudioSuccessState) {
                    final Either<String?, ErrorMessageModel?> result =
                        await context
                            .read<DownloadProvider>()
                            .downloadAndSaveFile(
                              fileUrl: chatState.audioUrl,
                              chatId: chatId,
                              fileType: "audio",
                            );
                    //Checking whether the audio downloaded or not
                    result.fold(
                      //Success state
                      (downloadedPath) {
                        if (downloadedPath != null && context.mounted) {
                          context.read<ChatBloc>().add(
                            SaveFileEvent(
                              chatId: chatId,
                              imagePath: "",
                              senderName: currentUsername,
                              senderProfilePic: currentUserProfilePic,
                              audioPath: downloadedPath,
                              senderId: senderId,
                              receiverId: receiverId,
                              currentUserId: currentUserId,
                              imageText: "",
                              type: "audio",
                              time: time,
                              fileUrl: chatState.audioUrl,
                              audioVideoDuration: audioDuration,
                              audioVideoTitle: audioTitle,
                              isDownloaded: true,
                              publicId: chatState.publicId,
                              voiceDuration: "",
                              voicePath: "",
                              parentAudioDuration: parentAudioDuration,
                              parentMessageSenderId: parentMessageSenderId,
                              parentMessageType: parentMessageType,
                              parentText: parentText,
                              parentVoiceDuration: parentVoiceDuration,
                              repliedMessage: repliedMessage,
                              senderBio: currentUserBio,
                            ),
                          );
                        }
                      },
                      //Error state
                      (errorModel) {
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
                      context.read<UserBloc>().add(
                        ChangePositionOfUserEvent(
                          userId: receiverId,
                          lastTextMessage: "",
                          lastMessageType: "audio",
                          lastAudioDuration: audioDuration,
                          lastVoiceDuration: "",
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
              10.horizontalSpace,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer<DownloadProvider>(
                        builder: (context, downloader, _) {
                          return BlocBuilder<ChatBloc, ChatState>(
                            buildWhen: (_, current) {
                              return current is UploadAudioLoadingState &&
                                  current.chatId == chatId;
                            },
                            builder: (context, chatState) {
                              return chatState is UploadAudioLoadingState ||
                                      downloader.isDownloading &&
                                          downloader.downloadingFileId == chatId
                                  ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        constraints: BoxConstraints(
                                          minHeight: 30.h,
                                          minWidth: 30.h,
                                        ),
                                        value:
                                            downloader.isDownloading &&
                                                    downloader
                                                            .downloadingFileId ==
                                                        chatId &&
                                                    downloader.indication != 0.0
                                                ? downloader.indication
                                                : null,
                                        strokeWidth: 3,
                                        color: whiteColor,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (chatState
                                                  is UploadAudioLoadingState &&
                                              chatState.chatId == chatId) {
                                            //Cancelling uploading process
                                            context.read<ChatBloc>().add(
                                              CancelUploadingProcess(
                                                chatId: chatId,
                                              ),
                                            );
                                          } else {
                                            //Cancelling the downloading process
                                            context
                                                .read<DownloadProvider>()
                                                .cancelDownloading();
                                          }
                                        },
                                        child: Consumer<ThemeProvider>(
                                          builder: (context, theme, _) {
                                            return Icon(
                                              Icons.close,
                                              size: 20.h,
                                              color:
                                                  theme.isDark
                                                      ? darkGrey
                                                      : darkWhite2,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                  : const SizedBox();
                            },
                          );
                        },
                      ),
                      15.horizontalSpace,
                      15.verticalSpace,
                      SizedBox(
                        height: 30.h,
                        width: 140.w,
                        child: Center(
                          child: ProgressBar(
                            progress: const Duration(seconds: 0),
                            total: const Duration(seconds: 30),
                            timeLabelLocation: TimeLabelLocation.none,
                            thumbRadius: 10.r,
                            progressBarColor: whiteColor,
                            thumbGlowRadius: 12.r,
                            baseBarColor: const Color.fromARGB(255, 96, 96, 96),
                            thumbColor: darkWhite2,
                            barHeight: 4.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                  10.horizontalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110.w,
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
                          fontweight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
