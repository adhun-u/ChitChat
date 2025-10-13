import 'dart:convert';
import 'dart:developer';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/common/presentations/providers/time_provider.dart';
import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/home/presentations/blocs/call/call_bloc.dart';
import 'package:chitchat/features/home/presentations/providers/call_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AudioCallPrev extends StatefulWidget {
  final int callerId;
  final int calleeId;
  final String imageUrl;
  final String displayName;
  const AudioCallPrev({
    super.key,
    required this.calleeId,
    required this.callerId,
    required this.displayName,
    required this.imageUrl,
  });

  @override
  State<AudioCallPrev> createState() => _AudioCallPrevState();
}

class _AudioCallPrevState extends State<AudioCallPrev> {
  late final ValueNotifier<bool> muteMicNotifier = ValueNotifier(false);
  late final ValueNotifier<bool> speakerModeNotifier = ValueNotifier(false);

  @override
  void dispose() {
    muteMicNotifier.dispose();
    speakerModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: Image.asset(
            wallpaper1,
            fit: BoxFit.cover,
            width: double.infinity.w,
            height: double.infinity.w
            ,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocListener<CallBloc, CallState>(
              listenWhen: (_, current) {
                return (current is NewOfferState) ||
                    (current is CalleeAnsweredState) ||
                    (current is FetchCandidateState) ||
                    (current is CallConnectedState) ||
                    (current is CallEndedState) ||
                    (current is CallDeclinedState);
              },
              listener: (context, callState) async {
                if (callState is NewOfferState) {
                  //Answering the call if caller created new offer to call
                  await context.read<CallProvider>().answerOffer(
                    rtcSessionDes: callState.data,
                    onAnswerCreated: (answer) {
                      context.read<CallBloc>().add(
                        AnswerCallOfferEvent(
                          callerId: widget.callerId,
                          currentUserId: widget.calleeId,
                          data: jsonEncode(answer.toMap()),
                        ),
                      );
                    },
                  );
                }
                if (callState is CalleeAnsweredState) {
                  if (context.mounted) {
                    //Adding the answer that callee created
                    await context.read<CallProvider>().getAnswer(
                      rtcSessionDes: callState.data,
                    );
                  }
                }
                if (callState is FetchCandidateState) {
                  if (context.mounted) {
                    //Fetching ice candidate to complete webrtc connection
                    await context.read<CallProvider>().fetchICECandidates(
                      candidatesData: callState.candidates,
                    );
                  }
                }
                if (callState is CallConnectedState) {
                  //Then activating the timer to start recording time
                  if (context.mounted) {
                    context.read<TimeProvider>().setupRecorderTime();
                  }
                }
                if (callState is CallEndedState ||
                    callState is CallDeclinedState) {
                  log("Entered to dispose the source and navigate back");
                  //Navigating back after call ended
                  await Future.delayed(const Duration(seconds: 1), () async {
                    //Disposing the resources
                    if (context.mounted) {
                      await context
                          .read<CallProvider>()
                          .disposeRenderesAndStreams();
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                }
              },

              child: const SizedBox(),
            ),
            40.verticalSpace,
            Center(
              child: Consumer<ThemeProvider>(
                builder: (context, theme, _) {
                  return CircleAvatar(
                    radius: 65.r,
                    backgroundColor: theme.isDark ? greyColor : darkWhite,
                    backgroundImage:
                        widget.imageUrl.isNotEmpty
                            ? NetworkImage(widget.imageUrl)
                            : null,
                    child:
                        widget.imageUrl.isEmpty
                            ? Icon(Icons.person, size: 35.h)
                            : null,
                  );
                },
              ),
            ),
            10.verticalSpace,
            Text(
              widget.displayName,
              style: getTitleLarge(
                context: context,
                fontweight: FontWeight.bold,
              ),
            ),
            10.verticalSpace,
            BlocBuilder<CallBloc, CallState>(
              buildWhen: (_, current) {
                return current is CallEndedState ||
                    current is CallConnectingState ||
                    current is CallConnectedState ||
                    current is CallInitial ||
                    current is CallRingingState ||
                    current is CallDeclinedState;
              },
              builder: (context, callState) {
                log('Call State : $callState');
                if (callState is CallRingingState) {
                  return Text(
                    "Ringing...",
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.w400,
                      color: lightGrey,
                    ),
                  );
                }
                if (callState is CallConnectingState) {
                  return Text(
                    "Connecting...",
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.w400,
                      color: lightGrey,
                    ),
                  );
                }
                if (callState is CallConnectedState) {
                  return Selector<TimeProvider, String>(
                    selector: (context, timer) {
                      return timer.recordingTime;
                    },
                    builder: (context, time, _) {
                      return Text(
                        time,
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.w400,
                          color: lightGrey,
                        ),
                      );
                    },
                  );
                }
                if ((callState is CallEndedState) ||
                    (callState is CallDeclinedState)) {
                  return Text(
                    callState is CallEndedState ? "Call ended" : "Declined",
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.w400,
                      color: redColor,
                    ),
                  );
                }
                return Text(
                  "Calling",
                  style: getTitleSmall(
                    context: context,
                    fontweight: FontWeight.w400,
                    color: lightGrey,
                  ),
                );
              },
            ),
            520.verticalSpace,
            SizedBox(
              height: 100.h,
              width: 330.w,
              child: Padding(
                padding: EdgeInsets.only(left: 5.w, right: 5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: muteMicNotifier,
                      builder: (context, isMuted, _) {
                        return _BuildButton(
                          icon: isMuted ? Icons.mic_off : Icons.mic,
                          buttonColor: Colors.transparent,
                          onTap: () async {
                            muteMicNotifier.value = !muteMicNotifier.value;
                            //Muting the audio
                            await context.read<CallProvider>().micMuteAndUnmute(
                              mute: !isMuted,
                            );
                          },
                          showSelectedColor: isMuted,
                        );
                      },
                    ),
                    30.horizontalSpace,
                    _BuildButton(
                      icon: Icons.call_end,
                      buttonColor: redColor.withAlpha(200),
                      onTap: () async {
                        //Sending call ended indication
                        context.read<CallBloc>().add(
                          SendCallIndicationEvent(
                            callerId: widget.callerId,
                            calleeId: widget.calleeId,
                            type: "CALL-END",
                          ),
                        );
                        //Disposing the webrtc resources to end the call
                        await context
                            .read<CallProvider>()
                            .disposeRenderesAndStreams();

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      showSelectedColor: false,
                    ),
                    30.horizontalSpace,
                    ValueListenableBuilder(
                      valueListenable: speakerModeNotifier,
                      builder: (context, isSpeakeMode, _) {
                        return _BuildButton(
                          icon: Icons.volume_up,
                          buttonColor: Colors.transparent,
                          onTap: () async {
                            speakerModeNotifier.value =
                                !speakerModeNotifier.value;
                            //Switching specker mode
                            await context
                                .read<CallProvider>()
                                .switchSpeackerMode(speaker: isSpeakeMode);
                          },
                          showSelectedColor: isSpeakeMode,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BuildButton extends StatelessWidget {
  final IconData icon;
  final Color buttonColor;
  final Function() onTap;
  final bool showSelectedColor;
  const _BuildButton({
    required this.icon,
    required this.buttonColor,
    required this.onTap,
    required this.showSelectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return GestureDetector(
          onTap: () {
            onTap();
          },
          child: Container(
            height: 80.h,
            width: 80.h,
            decoration:
                showSelectedColor
                    ? BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: theme.isDark ? darkGrey : darkWhite,
                    )
                    : null,
            child: CircleAvatar(
              radius: 35.r,
              backgroundColor: buttonColor,
              child: Icon(icon, color: theme.isDark ? whiteColor : blackColor),
            ),
          ),
        );
      },
    );
  }
}
