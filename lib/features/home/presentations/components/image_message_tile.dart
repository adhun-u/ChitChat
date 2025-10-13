import 'dart:io';
import 'dart:ui';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/presentations/pages/show_image_prev.dart';
import 'package:chitchat/common/presentations/providers/download_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:chitchat/features/home/presentations/blocs/user/user_bloc.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ImageMessageTile extends StatefulWidget {
  final String imagePath;
  final String imageText;
  final int senderId;
  final int receiverId;
  final int currentUserId;
  final String receiverName;
  final String chatId;
  final bool isMe;
  final String time;
  final bool isSeen;
  final bool isDownloaded;
  final bool repliedMessage;

  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;

  const ImageMessageTile({
    super.key,
    required this.isMe,
    required this.imageText,
    required this.imagePath,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.currentUserId,
    required this.receiverName,
    required this.isSeen,
    required this.time,
    required this.isDownloaded,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });

  @override
  State<ImageMessageTile> createState() => _ImageMessageTileState();
}

class _ImageMessageTileState extends State<ImageMessageTile> {
  final ValueNotifier<List<int>> sizeNotifier = ValueNotifier([0, 0]);

  //Using for getting height and width of an unknown file image
  void getSizeOfImage() async {
    if (!widget.isDownloaded) {
      final File imageFile = File(widget.imagePath);
      final decodedImage = await decodeImageFromList(
        imageFile.readAsBytesSync(),
      );
      sizeNotifier.value[0] = decodedImage.width;
      sizeNotifier.value[1] = decodedImage.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 270.h, maxWidth: 250.w),
      child: Consumer2<ChatStyleProvider, ThemeProvider>(
        builder: (context, chatStyle, theme, _) {
          return Container(
            decoration: BoxDecoration(
              color:
                  widget.isMe
                      ? chatStyle.chatColor
                      : theme.isDark
                      ? greyColor
                      : darkWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(chatStyle.borderRadius),
                topRight: Radius.circular(chatStyle.borderRadius),
                bottomLeft:
                    widget.isMe
                        ? Radius.circular(chatStyle.borderRadius)
                        : Radius.circular(0),
                bottomRight:
                    widget.isMe
                        ? Radius.circular(0)
                        : Radius.circular(chatStyle.borderRadius),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.repliedMessage)
                    Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        color:
                            widget.isMe
                                ? context.read<ThemeProvider>().isDark
                                    ? greyColor
                                    : darkWhite
                                : context.read<ThemeProvider>().isDark
                                ? darkGrey
                                : darkWhite2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          10.horizontalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.parentMessageSenderId ==
                                        widget.currentUserId
                                    ? "You"
                                    : widget.receiverName,
                                style: getTitleSmall(
                                  context: context,
                                  fontweight: FontWeight.bold,
                                  color:
                                      context
                                          .read<ChatStyleProvider>()
                                          .chatColor,
                                ),
                              ),
                              if (widget.parentMessageType == "text")
                                Text(
                                  widget.parentText,
                                  style: getTitleSmall(
                                    context: context,
                                    fontweight: FontWeight.w400,
                                    color: lightGrey,
                                  ),
                                ),
                              if (widget.parentMessageType == "voice")
                                Row(
                                  children: [
                                    Icon(
                                      Icons.mic,
                                      size: 20.h,
                                      color: lightGrey,
                                    ),
                                    5.horizontalSpace,
                                    Text(
                                      'Voice message (${widget.parentVoiceDuration})',
                                      style: getTitleSmall(
                                        context: context,
                                        fontweight: FontWeight.w400,
                                        color: lightGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              if (widget.parentMessageType == "audio")
                                Row(
                                  children: [
                                    Icon(
                                      Icons.headphones,
                                      size: 20.h,
                                      color: lightGrey,
                                    ),
                                    5.horizontalSpace,
                                    Text(
                                      'Audio (${widget.parentAudioDuration})',
                                      style: getTitleSmall(
                                        context: context,
                                        fontweight: FontWeight.w400,
                                        color: lightGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              if (widget.parentMessageType == "image")
                                Row(
                                  children: [
                                    Icon(
                                      Icons.photo,
                                      size: 20.h,
                                      color: lightGrey,
                                    ),
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
                  if (widget.repliedMessage) 10.verticalSpace,
                  Expanded(
                    child: Stack(
                      children: [
                        !widget.isDownloaded
                            ? ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 2,
                                sigmaY: 2,
                              ),
                              child: Consumer<ChatStyleProvider>(
                                builder: (context, chatStyle, _) {
                                  return Container(
                                    width: 250.w,
                                    constraints: BoxConstraints(
                                      maxHeight: 250.h,
                                      minHeight: 200.h,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fitWidth,
                                        image: NetworkImage(widget.imagePath),
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                          chatStyle.borderRadius,
                                        ),
                                        topRight: Radius.circular(
                                          chatStyle.borderRadius,
                                        ),
                                        bottomLeft:
                                            widget.isMe
                                                ? Radius.circular(
                                                  chatStyle.borderRadius,
                                                )
                                                : Radius.circular(0),
                                        bottomRight:
                                            widget.isMe
                                                ? Radius.circular(
                                                  chatStyle.borderRadius,
                                                )
                                                : Radius.circular(
                                                  chatStyle.borderRadius,
                                                ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                            : Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ShowImagePrev(
                                            imagePath: widget.imagePath,
                                            username: widget.receiverName,
                                            heroTag: widget.chatId,
                                            sentImageTime:
                                                "${formatDate(widget.time)} at ${formatTime(widget.time)}",
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Hero(
                                        tag: widget.chatId,
                                        child: Consumer<ChatStyleProvider>(
                                          builder: (context, chatStyle, _) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    chatStyle.borderRadius,
                                                  ),
                                              child: Image.file(
                                                width: 250.w,
                                                fit: BoxFit.fitWidth,
                                                File(widget.imagePath),
                                                frameBuilder: (
                                                  _,
                                                  child,
                                                  frame,
                                                  isLoaded,
                                                ) {
                                                  if (frame != null &&
                                                      isLoaded) {
                                                    sizeNotifier.value[0] = 0;
                                                    sizeNotifier.value[1] = 0;
                                                  }
                                                  return ValueListenableBuilder(
                                                    valueListenable:
                                                        sizeNotifier,
                                                    builder: (_, size, _) {
                                                      return sizeNotifier
                                                                      .value[0] !=
                                                                  0 &&
                                                              sizeNotifier
                                                                      .value[1] !=
                                                                  0
                                                          ? Container(
                                                            height:
                                                                sizeNotifier
                                                                    .value[1]
                                                                    .toDouble()
                                                                    .h,
                                                            width:
                                                                sizeNotifier
                                                                    .value[0]
                                                                    .toDouble()
                                                                    .w,
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    chatStyle
                                                                        .borderRadius,
                                                                  ),
                                                            ),
                                                            child: const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        3,
                                                                    color:
                                                                        blueColor,
                                                                  ),
                                                            ),
                                                          )
                                                          : child;
                                                    },
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        height: 25.h,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: blackColor.withAlpha(100),
                                              spreadRadius: 5,
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: 5.w,
                                                bottom: 5.h,
                                              ),
                                              child: Text(
                                                formatTime(widget.time),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: whiteColor,
                                                  fontWeight: FontWeight.w500,
                                                  shadows: [
                                                    BoxShadow(
                                                      color: blackColor
                                                          .withAlpha(100),
                                                      offset: const Offset(
                                                        1,
                                                        -1,
                                                      ),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                    ),
                                                    BoxShadow(
                                                      color: blackColor
                                                          .withAlpha(100),
                                                      offset: const Offset(
                                                        -1,
                                                        1,
                                                      ),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (widget.senderId ==
                                                widget.currentUserId)
                                              BlocListener<ChatBloc, ChatState>(
                                                listenWhen: (_, current) {
                                                  return current
                                                      is IndicateSeenState;
                                                },
                                                listener: (context, chatState) {
                                                  if (chatState
                                                      is IndicateSeenState) {
                                                    //Changing seen info of selected chat as true
                                                    context.read<ChatBloc>().add(
                                                      ChangeSeenInfoInSelectedChatsEvent(),
                                                    );
                                                  }
                                                },
                                                child: const SizedBox(),
                                              ),
                                            if (widget.senderId ==
                                                widget.currentUserId)
                                              BlocBuilder<ChatBloc, ChatState>(
                                                buildWhen: (_, current) {
                                                  return current
                                                      is IndicateSeenState;
                                                },
                                                builder: (context, chatState) {
                                                  if (chatState
                                                      is IndicateSeenState) {
                                                    return const _SeenMark(
                                                      isSeen: true,
                                                    );
                                                  }
                                                  return _SeenMark(
                                                    isSeen: widget.isSeen,
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                        if (!widget.isDownloaded)
                          GestureDetector(
                            onTap: () async {
                              //Downloading the image when user clicks download button
                              final dartz.Either<String?, ErrorMessageModel?>
                              result = await context
                                  .read<DownloadProvider>()
                                  .downloadAndSaveFile(
                                    fileUrl: widget.imagePath,
                                    chatId: widget.chatId,
                                    fileType: "image",
                                  );
                              result.fold(
                                (filePath) {
                                  //If downloading process was success, then saving the image path in local storage
                                  if (filePath != null) {
                                    context.read<ChatBloc>().add(
                                      SaveFileEvent(
                                        chatId: widget.chatId,
                                        senderName: "",
                                        senderProfilePic: "",
                                        imagePath: filePath,
                                        senderId: widget.senderId,
                                        receiverId: widget.receiverId,
                                        currentUserId: widget.currentUserId,
                                        imageText: widget.imageText,
                                        type: "image",
                                        time: widget.time,
                                        fileUrl: "",
                                        isDownloaded: true,
                                        audioPath: "",
                                        audioVideoDuration: "",
                                        audioVideoTitle: "",
                                        publicId: "",
                                        voiceDuration: "",
                                        voicePath: "",
                                        parentAudioDuration:
                                            widget.parentAudioDuration,
                                        parentMessageSenderId:
                                            widget.parentMessageSenderId,
                                        parentMessageType:
                                            widget.parentMessageType,
                                        parentText: widget.parentText,
                                        parentVoiceDuration:
                                            widget.parentVoiceDuration,
                                        repliedMessage: widget.repliedMessage,
                                        senderBio: "",
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
                            child: Consumer<DownloadProvider>(
                              builder: (context, downloader, _) {
                                return Center(
                                  child: CircleAvatar(
                                    radius: 30.r,
                                    backgroundColor:
                                        theme.isDark ? greyColor : darkWhite,
                                    child:
                                        downloader.isDownloading &&
                                                downloader.downloadingFileId ==
                                                    widget.chatId
                                            ? Padding(
                                              padding: EdgeInsets.all(3.h),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: blueColor,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      //Cancelling downloading process
                                                      context
                                                          .read<
                                                            DownloadProvider
                                                          >()
                                                          .cancelDownloading();
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 30.h,
                                                      color: lightGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            : downloader.indication != 0.0 &&
                                                downloader.downloadingFileId ==
                                                    widget.chatId
                                            ? Padding(
                                              padding: EdgeInsets.all(3.h),
                                              child: Stack(
                                                children: [
                                                  CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: blueColor,
                                                    value:
                                                        downloader.indication,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      //Cancelling downloading process
                                                      context
                                                          .read<
                                                            DownloadProvider
                                                          >()
                                                          .cancelDownloading();
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 30.h,
                                                      color: lightGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            : const Icon(
                                              CupertinoIcons.down_arrow,
                                            ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.imageText.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(5.h),
                      child: Text(
                        widget.imageText,
                        textAlign: TextAlign.left,
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.w700,
                          fontSize: 13.sp,
                          color:
                              widget.isMe
                                  ? whiteColor
                                  : theme.isDark
                                  ? whiteColor
                                  : blackColor,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageUploadingTile extends StatelessWidget {
  final String imagePath;
  final String imageText;
  final String time;
  final String chatId;
  final int senderId;
  final String currentUserProfilePic;
  final String currentUsername;
  final String currentUserBio;
  final int receiverId;
  final String receiverName;
  final int currentUserId;
  final bool repliedMessage;

  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;

  const ImageUploadingTile({
    super.key,
    required this.chatId,
    required this.currentUsername,
    required this.receiverName,
    required this.currentUserProfilePic,
    required this.currentUserBio,
    required this.imagePath,
    required this.imageText,
    required this.time,
    required this.senderId,
    required this.receiverId,
    required this.currentUserId,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return Consumer<ChatStyleProvider>(
          builder: (context, chatStyle, child) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 270.h, maxWidth: 250.w),
              child: Container(
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
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(5.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (repliedMessage)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 60.h,
                      // maxWidth: 250.w,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            context.read<ThemeProvider>().isDark
                                ? greyColor
                                : darkWhite,

                        borderRadius: BorderRadius.circular(10),
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
                                  color:
                                      context
                                          .read<ChatStyleProvider>()
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
                                    Icon(
                                      Icons.photo,
                                      size: 20.h,
                                      color: lightGrey,
                                    ),
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
                  ),
                if (repliedMessage) 10.verticalSpace,
                Expanded(
                  child: Stack(
                    children: [
                      BlocListener<ChatBloc, ChatState>(
                        listenWhen: (_, current) {
                          return (current is UploadImageSuccessState) ||
                              (current is UploadFileError) ||
                              (current is SaveFileSuccessState &&
                                  current.senderId == currentUserId &&
                                  current.chatId == chatId);
                        },
                        listener: (context, chatState) async {
                          if (chatState is UploadImageSuccessState) {
                            //If the image is uploaded successfully , then downloading the image using image url
                            final result = await context
                                .read<DownloadProvider>()
                                .downloadAndSaveFile(
                                  fileUrl: chatState.imageUrl,
                                  chatId: chatId,
                                  fileType: "image",
                                );
                            result.fold(
                              (imagePath) {
                                if (imagePath != null) {
                                  //If the image downloaded is success , then saving the image in local storage with the image path
                                  context.read<ChatBloc>().add(
                                    SaveFileEvent(
                                      chatId: chatId,
                                      senderName: currentUsername,
                                      senderProfilePic: currentUserProfilePic,
                                      imagePath: imagePath,
                                      senderId: senderId,
                                      receiverId: receiverId,
                                      currentUserId: currentUserId,
                                      imageText: chatState.imageText,
                                      type: "image",
                                      time: time,
                                      fileUrl: chatState.imageUrl,
                                      audioPath: "",
                                      audioVideoDuration: "",
                                      audioVideoTitle: "",
                                      isDownloaded: true,
                                      publicId: chatState.publicId,
                                      voiceDuration: "",
                                      voicePath: "",
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
                                  lastMessageType: "image",
                                  lastAudioDuration: "",
                                  lastVoiceDuration: "",
                                  lastImageText: imageText,
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
                      Selector<ChatStyleProvider, double>(
                        selector: (context, chatStyle) {
                          return chatStyle.borderRadius;
                        },
                        builder: (context, borderRadius, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(
                                  borderRadius,
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: 200.h,
                                    maxWidth: 250.w,
                                  ),
                                  child: Image.file(
                                    width: 250.w,
                                    fit: BoxFit.fitWidth,
                                    File(imagePath),
                                  ),
                                ),
                              ),
                              BlocBuilder<ChatBloc, ChatState>(
                                buildWhen: (_, current) {
                                  return current is UploadImageSuccessState ||
                                      current is UploadImageLoadingState &&
                                          current.chatId == chatId ||
                                      current is UploadFileError;
                                },
                                builder: (context, chatState) {
                                  if (chatState is UploadImageLoadingState) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30.r,
                                          backgroundColor:
                                              theme.isDark
                                                  ? greyColor
                                                  : darkWhite,
                                          child: Padding(
                                            padding: EdgeInsets.all(3.h),
                                            child: Consumer<DownloadProvider>(
                                              builder: (
                                                context,
                                                downloader,
                                                _,
                                              ) {
                                                return CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: blueColor,
                                                  value:
                                                      downloader.downloadingFileId ==
                                                                  chatId &&
                                                              downloader
                                                                  .isDownloading
                                                          ? downloader
                                                              .indication
                                                          : null,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            //Cancelling the process to send
                                            context.read<ChatBloc>().add(
                                              CancelUploadingProcess(
                                                chatId: chatId,
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: 30.h,
                                            color: lightGrey,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (imageText.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(5.h),
                    child: Text(
                      imageText,
                      textAlign: TextAlign.left,
                      style: getBodySmall(
                        context: context,
                        fontweight: FontWeight.w700,
                        color: whiteColor,
                        fontSize: 13.sp,
                      ),
                      overflow: TextOverflow.clip,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
            shadows: [
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
