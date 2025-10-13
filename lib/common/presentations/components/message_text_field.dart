import 'dart:io';
import 'package:chitchat/common/presentations/providers/audio_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/common/presentations/providers/time_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class MessageTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool isEmojiKeyboardVisible;
  final ScrollController scrollController;
  final ValueNotifier<String> inputNotifier;
  final Function(bool isEmojiKeyboardVisible) onEmojiKeyboardClicked;
  final Function(bool) onAttachClicked;
  final Function onMessageSend;
  final Function() onChanged;
  final bool isImage;
  final Function onImageSend;
  final Function(String voicPath, String voiceDuration) onVoiceMessageSend;
  final Function() onRecordingStarting;
  final Function() onRecordCancelled;
  final bool isAttachIconClicked;
  const MessageTextField({
    super.key,
    required this.controller,
    required this.onMessageSend,
    required this.onEmojiKeyboardClicked,
    required this.isEmojiKeyboardVisible,
    required this.scrollController,
    required this.inputNotifier,
    required this.onChanged,
    required this.onAttachClicked,
    required this.isImage,
    required this.onImageSend,
    required this.onVoiceMessageSend,
    required this.onRecordingStarting,
    required this.onRecordCancelled,
    required this.isAttachIconClicked,
  });

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  final AudioRecorder recorder = AudioRecorder();
  final ValueNotifier<bool> isRecordingNotifier = ValueNotifier(false);

  @override
  void dispose() {
    recorder.dispose();
    isRecordingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, theme, child) {
            return Container(
              width: 350.w,
              height: 65.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: theme.isDark ? greyColor : darkWhite,
              ),
              child: child,
            );
          },
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ValueListenableBuilder(
                  valueListenable: isRecordingNotifier,
                  builder: (context, isRecording, _) {
                    return isRecording
                        ? Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [Icon(Icons.mic, color: redColor)],
                          ),
                        )
                        : IconButton(
                          onPressed: () async {
                            //Checking if the emojiKeyboard is visible
                            if (!widget.isEmojiKeyboardVisible) {
                              widget.onEmojiKeyboardClicked(true);
                              //If the emoji keyboard is visible , then opening the normal keyboard
                              await Future.delayed(
                                const Duration(milliseconds: 10),
                              ).then((_) async {
                                await SystemChannels.textInput.invokeMethod(
                                  "TextInput.show",
                                );
                              });
                            }
                            //If it is not , then closing the normal keyboard
                            else {
                              widget.onEmojiKeyboardClicked(false);
                              await Future.delayed(
                                const Duration(milliseconds: 10),
                              ).then((_) async {
                                await SystemChannels.textInput.invokeMethod(
                                  "TextInput.hide",
                                );
                              });
                            }
                            if (widget.scrollController.hasClients) {
                              widget.scrollController.position.jumpTo(
                                widget
                                    .scrollController
                                    .position
                                    .maxScrollExtent,
                              );
                            }
                          },
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child:
                                widget.isEmojiKeyboardVisible
                                    ? Icon(
                                      Icons.emoji_emotions_outlined,
                                      key: ValueKey<bool>(
                                        widget.isEmojiKeyboardVisible,
                                      ),
                                    )
                                    : Icon(
                                      Icons.keyboard,
                                      key: ValueKey<bool>(
                                        widget.isEmojiKeyboardVisible,
                                      ),
                                    ),
                          ),
                        );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 50.w),
                child: Center(
                  child: ValueListenableBuilder(
                    valueListenable: isRecordingNotifier,
                    builder: (context, isRecording, _) {
                      return Consumer<TimeProvider>(
                        builder: (context, timer, _) {
                          return TextField(
                            controller: widget.controller,

                            onTap: () {
                              widget.onEmojiKeyboardClicked(true);
                              //Scrolling to the bottom when the keyboard appears
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    if (widget.scrollController.hasClients) {
                                      widget.scrollController.animateTo(
                                        widget
                                            .scrollController
                                            .position
                                            .maxScrollExtent,
                                        duration: const Duration(
                                          milliseconds: 100,
                                        ),
                                        curve: Curves.fastOutSlowIn,
                                      );
                                    }
                                  },
                                );
                              });
                            },
                            onChanged: (value) {
                              widget.inputNotifier.value = value.trim();
                              widget.onChanged();
                            },
                            textAlign: TextAlign.left,
                            showCursor: !isRecording,
                            maxLines: 4,
                            minLines: 1,
                            maxLength: 1000,
                            buildCounter: (
                              _, {
                              required currentLength,
                              required isFocused,
                              required maxLength,
                            }) {
                              return const SizedBox();
                            },
                            style: getTitleMedium(
                              context: context,
                              fontweight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  isRecording
                                      ? timer.recordingTime
                                      : "Type your message here",
                              enabled: !isRecording,
                              hintStyle: getTitleMedium(
                                context: context,
                                fontweight: FontWeight.w400,
                              ),
                              border: InputBorder.none,

                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(right: 45.w),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: isRecordingNotifier,
                      builder: (context, isRecording, _) {
                        return isRecording
                            ? Padding(
                              padding: EdgeInsets.only(right: 5.w),
                              child: TextButton(
                                onPressed: () async {
                                  final String? path = await recorder.stop();
                                  isRecordingNotifier.value = false;
                                  widget.onRecordCancelled();
                                  if (path != null) {
                                    await File(path).delete();
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: getTitleSmall(
                                    context: context,
                                    fontweight: FontWeight.bold,
                                    color: blueColor,
                                  ),
                                ),
                              ),
                            )
                            : IconButton(
                              onPressed: () {
                                widget.onAttachClicked(
                                  !widget.isAttachIconClicked,
                                );
                              },
                              icon:
                                  widget.isAttachIconClicked
                                      ? const Icon(
                                        CupertinoIcons.xmark_circle_fill,
                                      )
                                      : const Icon(Icons.attach_file_sharp),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        10.horizontalSpace,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child:
              widget.isImage
                  ? _CircleButtons(
                    key: ValueKey<bool>(widget.isImage),
                    icon: Icons.send,
                    onClicked: () {
                      widget.onImageSend();
                    },
                  )
                  : ValueListenableBuilder(
                    key: ValueKey<bool>(widget.isImage),
                    valueListenable: widget.inputNotifier,
                    builder: (context, text, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child:
                            text.isNotEmpty && text != ""
                                ? GestureDetector(
                                  onTap: () {},
                                  child: _CircleButtons(
                                    icon: Icons.send,
                                    key: ValueKey<bool>(
                                      text.isNotEmpty && text != "",
                                    ),
                                    onClicked: () {
                                      widget.onMessageSend();
                                      widget.inputNotifier.value = "";
                                    },
                                  ),
                                )
                                : ValueListenableBuilder(
                                  valueListenable: isRecordingNotifier,
                                  builder: (context, isRecording, _) {
                                    return _CircleButtons(
                                      icon:
                                          isRecording ? Icons.stop : Icons.mic,
                                      key: ValueKey<bool>(
                                        text.isNotEmpty && text != "",
                                      ),
                                      onClicked: () async {
                                        if (!isRecording) {
                                          //Asking permission for activating mic
                                          if (await recorder.hasPermission()) {
                                            isRecordingNotifier.value = true;
                                            widget.onRecordingStarting();
                                            //Getting a directory for saving the recording clip
                                            final Directory dir =
                                                await getTemporaryDirectory();
                                            //Starting the recorder
                                            await recorder.start(
                                              const RecordConfig(
                                                encoder: AudioEncoder.aacLc,
                                              ),
                                              path:
                                                  "${dir.path}/voice_message.m4a",
                                            );
                                            if (context.mounted) {
                                              //Starting the timer for showing curren time
                                              context
                                                  .read<TimeProvider>()
                                                  .setupRecorderTime();
                                            }
                                          }
                                        } else {
                                          final String? path =
                                              await recorder.stop();

                                          if (context.mounted) {
                                            context
                                                .read<TimeProvider>()
                                                .stopTimer();
                                          }
                                          isRecordingNotifier.value = false;
                                          widget.onRecordCancelled();
                                          if (path != null) {
                                            await Future.delayed(
                                              const Duration(milliseconds: 200),
                                            );
                                            if (context.mounted) {
                                              final String totalDuration =
                                                  await context
                                                      .read<AudioProvider>()
                                                      .getDuration(path);

                                              widget.onVoiceMessageSend(
                                                path,
                                                totalDuration,
                                              );
                                            }
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class _CircleButtons extends StatelessWidget {
  final IconData icon;
  final Function() onClicked;
  const _CircleButtons({
    super.key,
    required this.icon,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClicked();
      },
      child: Container(
        key: key,
        height: 60.h,
        width: 60.h,
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(icon, color: whiteColor),
      ),
    );
  }
}
