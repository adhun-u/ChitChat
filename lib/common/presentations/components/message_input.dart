import 'dart:io';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:chitchat/common/presentations/components/message_text_field.dart';
import 'package:chitchat/common/presentations/providers/audio_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/common/presentations/components/attach_container.dart';
import 'package:chitchat/features/home/presentations/components/custom_emoji_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final Function onMessageSend;
  final ScrollController scrollController;
  final Function(XFile image) onImageSend;
  final Function(
    PlatformFile audioFile,
    String audioDuration,
    String audioTitle,
  )
  onAudioSend;
  final Function(String voicePath, String voiceDuration) onVoiceSend;
  final Function() onTyping;
  final Function() onRecordingStarted;
  final Function() onRecordingCancelled;
  const MessageInput({
    super.key,
    required this.controller,
    required this.onMessageSend,
    required this.scrollController,
    required this.onImageSend,
    required this.onAudioSend,
    required this.onVoiceSend,
    required this.onTyping,
    required this.onRecordingStarted,
    required this.onRecordingCancelled,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late final ValueNotifier<bool> isNotEmojiKeyboardVisibleNotifier =
      ValueNotifier(true);
  late final ValueNotifier<String> inputNotifier = ValueNotifier('');
  late final ValueNotifier<bool> isAttachIconClickedNotifier = ValueNotifier(
    false,
  );
  late final ValueNotifier<PlatformFile?> audioFileNotifier = ValueNotifier(
    null,
  );
  late final ValueNotifier<XFile?> imageNotifier = ValueNotifier(null);

  @override
  void dispose() {
    isNotEmojiKeyboardVisibleNotifier.dispose();
    isAttachIconClickedNotifier.dispose();
    inputNotifier.dispose();
    imageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: imageNotifier,
          builder: (context, imageFile, _) {
            if (imageFile != null) {
              audioFileNotifier.value = null;
            }
            return imageFile != null
                ? Padding(
                  padding: EdgeInsets.only(left: 15.w, bottom: 10.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Consumer<ThemeProvider>(
                      builder: (context, theme, _) {
                        return Container(
                          height: 150.h,
                          width: 150.h,
                          decoration: BoxDecoration(
                            color: theme.isDark ? greyColor : darkWhite,
                            borderRadius: BorderRadius.circular(15.r),
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: FileImage(File(imageFile.path)),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {
                                imageNotifier.value = null;
                                isAttachIconClickedNotifier.value = false;
                              },
                              icon: const Icon(
                                CupertinoIcons.xmark_circle_fill,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
                : const SizedBox();
          },
        ),
        ValueListenableBuilder(
          valueListenable: isAttachIconClickedNotifier,
          builder: (context, isClicked, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child:
                  isClicked
                      ? Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Center(
                          child: AttachContainer(
                            key: ValueKey<bool>(isClicked),
                            icons: [
                              Icons.camera_alt,
                              Icons.image,
                              Icons.audiotrack,
                            ],
                            colors: [
                              Colors.green[400]!,
                              Colors.red[400]!,
                              Colors.blue[400]!,
                            ],
                            labels: ["Camera", "Gallery", "Audio"],
                            whenImageClicked: (file) {
                              isAttachIconClickedNotifier.value = false;
                              imageNotifier.value = file;
                            },
                            whenAudioClicked: (audioFile) async {
                              isAttachIconClickedNotifier.value = false;
                              await context
                                  .read<AudioProvider>()
                                  .setupAudioPlayer(
                                    audioFile.xFile.path,
                                    audioFile.name,
                                  );
                              audioFileNotifier.value = audioFile;
                            },
                          ),
                        ),
                      )
                      : SizedBox(key: ValueKey<bool>(isClicked)),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: audioFileNotifier,
          builder: (context, audioFile, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child:
                  audioFile != null
                      ? _AudioPrevContainer(
                        key: ValueKey<bool>(true),
                        audioFile: audioFile,
                        onSendButtonClicked: () {
                          audioFileNotifier.value = null;
                          widget.onAudioSend(
                            audioFile,
                            context.read<AudioProvider>().totalPostion,
                            audioFile.name,
                          );
                        },
                        onCloseButtonTap: () {
                          audioFileNotifier.value = null;
                          context.read<AudioProvider>().pauseAudio();
                        },
                      )
                      : Padding(
                        key: ValueKey<bool>(false),
                        padding: EdgeInsets.only(
                          left: 10.w,
                          right: 10.w,
                          bottom: 10.h,
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: isNotEmojiKeyboardVisibleNotifier,
                          builder: (context, isVisible, _) {
                            return ValueListenableBuilder(
                              valueListenable: isAttachIconClickedNotifier,
                              builder: (context, isAttachIconClicked, _) {
                                return ValueListenableBuilder(
                                  valueListenable: imageNotifier,
                                  builder: (context, imageFile, _) {
                                    return MessageTextField(
                                      controller: widget.controller,
                                      isImage: imageFile != null,
                                      onMessageSend: widget.onMessageSend,
                                      scrollController: widget.scrollController,
                                      inputNotifier: inputNotifier,
                                      isAttachIconClicked: isAttachIconClicked,
                                      isEmojiKeyboardVisible: isVisible,
                                      onChanged: () {
                                        widget.onTyping();
                                      },
                                      onEmojiKeyboardClicked: (
                                        isNotEmojiVisible,
                                      ) {
                                        isNotEmojiKeyboardVisibleNotifier
                                            .value = isNotEmojiVisible;
                                        if (widget
                                            .scrollController
                                            .hasClients) {
                                          widget.scrollController.jumpTo(
                                            widget
                                                .scrollController
                                                .position
                                                .maxScrollExtent,
                                          );
                                        }
                                      },
                                      onAttachClicked: (isClicked) {
                                        isAttachIconClickedNotifier.value =
                                            isClicked;
                                      },
                                      onImageSend: () {
                                        if (imageFile != null) {
                                          widget.onImageSend(imageFile);
                                          imageNotifier.value = null;
                                        }
                                      },
                                      onVoiceMessageSend: (
                                        voicPath,
                                        voiceDuration,
                                      ) {
                                        widget.onVoiceSend(
                                          voicPath,
                                          voiceDuration,
                                        );
                                      },
                                      onRecordingStarting: () {
                                        widget.onRecordingStarted();
                                      },
                                      onRecordCancelled: () {
                                        widget.onRecordingCancelled();
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: isNotEmojiKeyboardVisibleNotifier,
          builder: (context, isNotEmojiKeyboardVisible, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child:
                  !isNotEmojiKeyboardVisible
                      ? SizedBox(
                        key: ValueKey<bool>(!isNotEmojiKeyboardVisible),
                        height: 300.h,
                        child: CustomEmojiPicker(
                          controller: widget.controller,
                          notifier: inputNotifier,
                          onEmojiChanged: () {
                            widget.onTyping();
                          },
                        ),
                      )
                      : SizedBox(
                        key: ValueKey<bool>(!isNotEmojiKeyboardVisible),
                      ),
            );
          },
        ),
      ],
    );
  }
}

class _AudioPrevContainer extends StatelessWidget {
  final Function() onSendButtonClicked;
  final Function() onCloseButtonTap;
  final PlatformFile audioFile;

  const _AudioPrevContainer({
    required this.onSendButtonClicked,
    required this.onCloseButtonTap,
    required this.audioFile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.h, left: 10.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Consumer<ThemeProvider>(
              builder: (context, theme, _) {
                return Container(
                  height: 80.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    color: theme.isDark ? greyColor : darkWhite,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Consumer<AudioProvider>(
                            builder: (context, audio, _) {
                              return GestureDetector(
                                onTap: () async {
                                  if (audio.isPlaying &&
                                      audio.currentPlayingAudioId ==
                                          audioFile.name) {
                                    await context
                                        .read<AudioProvider>()
                                        .pauseAudio();
                                  } else {
                                    if (audio.currentPlayingAudioId ==
                                        audioFile.name) {
                                      await context
                                          .read<AudioProvider>()
                                          .playAudio();
                                    } else {
                                      await context
                                          .read<AudioProvider>()
                                          .setupAudioPlayer(
                                            audioFile.xFile.path,
                                            audioFile.name,
                                          );
                                      if (context.mounted) {
                                        await context
                                            .read<AudioProvider>()
                                            .playAudio();
                                      }
                                    }
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor: blueColor,
                                  child:
                                      audio.isPlaying &&
                                              audio.currentPlayingAudioId ==
                                                  audioFile.name
                                          ? const Icon(
                                            Icons.pause,
                                            color: whiteColor,
                                          )
                                          : const Icon(
                                            Icons.play_arrow_rounded,
                                            color: whiteColor,
                                          ),
                                ),
                              );
                            },
                          ),
                        ),
                        10.horizontalSpace,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20.h,
                              width: 220.w,
                              child: Text(
                                audioFile.xFile.name,
                                style: getBodySmall(
                                  context: context,
                                  fontweight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            10.verticalSpace,
                            SizedBox(
                              width: 210.w,
                              child: Consumer<AudioProvider>(
                                builder: (context, audio, _) {
                                  return ProgressBar(
                                    progress:
                                        audio.currentPlayingAudioId ==
                                                audioFile.xFile.name
                                            ? audio.currentDuration
                                            : const Duration(),
                                    total:
                                        audio.currentPlayingAudioId ==
                                                audioFile.xFile.name
                                            ? audio.totalDuration
                                            : const Duration(),
                                    onSeek: (duration) {
                                      context.read<AudioProvider>().seekAudio(
                                        duration,
                                      );
                                    },
                                    baseBarColor: darkWhite2,
                                    progressBarColor: blueColor,
                                    timeLabelLocation: TimeLabelLocation.none,
                                    barHeight: 3.h,
                                    thumbRadius: 8.r,
                                    thumbGlowRadius: 10.r,
                                    thumbColor: darkWhite2,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        10.horizontalSpace,
                        Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  onCloseButtonTap();
                                },
                                child: Icon(Icons.close, size: 20.h),
                              ),
                              10.verticalSpace,
                              Consumer<AudioProvider>(
                                builder: (context, audio, _) {
                                  return Text(
                                    audio.currentPlayingAudioId ==
                                            audioFile.xFile.name
                                        ? audio.currentPostion
                                        : "0.00",
                                    style: getBodySmall(
                                      context: context,
                                      fontSize: 12.sp,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        10.horizontalSpace,
        GestureDetector(
          onTap: () {
            onSendButtonClicked();
          },
          child: Container(
            height: 60.h,
            width: 60.h,
            decoration: BoxDecoration(
              color: blueColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.send, color: whiteColor),
          ),
        ),
      ],
    );
  }
}
