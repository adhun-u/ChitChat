import 'dart:convert';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/common/presentations/providers/time_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/home/presentations/blocs/call/call_bloc.dart';
import 'package:chitchat/features/home/presentations/providers/call_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class VideoCallPre extends StatefulWidget {
  final int callerId;
  final int calleeId;
  final String oppositUserProfilePic;
  const VideoCallPre({
    super.key,
    required this.oppositUserProfilePic,
    required this.calleeId,
    required this.callerId,
  });

  @override
  State<VideoCallPre> createState() => _VideoCallPreState();
}

class _VideoCallPreState extends State<VideoCallPre> {
  late final ValueNotifier<bool> micMuteNotifier = ValueNotifier(false);
  late final ValueNotifier<bool> moreSectionVisibleNotifier = ValueNotifier(
    false,
  );

  @override
  void dispose() {
    micMuteNotifier.dispose();
    moreSectionVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 900.h,
          child: Consumer<CallProvider>(
            builder: (context, callProvider, _) {
              return RTCVideoView(
                callProvider.remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              );
            },
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            40.verticalSpace,
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
            BlocBuilder<CallBloc, CallState>(
              buildWhen: (_, current) {
                return current is CallEndedState ||
                    current is CallConnectingState ||
                    current is CallConnectedState ||
                    current is CallInitial ||
                    current is CallRingingState;
              },
              builder: (context, callState) {
                if (callState is! CallConnectedState) {
                  return Center(
                    child: Consumer<ThemeProvider>(
                      builder: (context, theme, _) {
                        return CircleAvatar(
                          radius: 60.r,
                          backgroundColor: theme.isDark ? greyColor : darkWhite,
                          backgroundImage:
                              widget.oppositUserProfilePic.isNotEmpty
                                  ? NetworkImage(widget.oppositUserProfilePic)
                                  : null,
                          child:
                              widget.oppositUserProfilePic.isEmpty
                                  ? Icon(Icons.person, size: 30.h)
                                  : null,
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            20.verticalSpace,
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
                  return const SizedBox();
                }
                if (callState is CallDeclinedState ||
                    callState is CallEndedState) {
                  return Text(
                    callState is CallEndedState
                        ? "Call ended"
                        : callState is CallDeclinedState
                        ? "Declined"
                        : "",
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.w400,
                      color: redColor.withAlpha(220),
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
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                moreSectionVisibleNotifier.value =
                    !moreSectionVisibleNotifier.value;
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 25.h, right: 10.w),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Consumer<ThemeProvider>(
                    builder: (context, theme, _) {
                      return Container(
                        height: 230.h,
                        width: 140.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: theme.isDark ? greyColor : darkWhite,
                        ),
                        child: Consumer<CallProvider>(
                          builder: (context, callProvider, _) {
                            return RTCVideoView(
                              callProvider.localRenderer,
                              objectFit:
                                  RTCVideoViewObjectFit
                                      .RTCVideoViewObjectFitCover,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: moreSectionVisibleNotifier,
              builder: (context, isVisible, child) {
                return isVisible ? child! : const SizedBox();
              },
              child: Column(
                children: [
                  Container(
                    height: 120.h,
                    width: 420.w,
                    decoration: BoxDecoration(
                      color: greyColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 35.r,
                          backgroundColor: Colors.transparent,
                          child: _BuildIcons(
                            icon: Icons.cameraswitch_sharp,
                            onTap: () async {
                              //Switching camera
                              await context.read<CallProvider>().switchCamera();
                            },
                          ),
                        ),
                        30.horizontalSpace,
                        GestureDetector(
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
                          child: CircleAvatar(
                            radius: 40.r,
                            backgroundColor: redColor.withAlpha(200),
                            child: Icon(Icons.call_end, color: whiteColor),
                          ),
                        ),
                        30.horizontalSpace,
                        ValueListenableBuilder(
                          valueListenable: micMuteNotifier,
                          builder: (context, isMuted, child) {
                            return CircleAvatar(
                              radius: 35,
                              backgroundColor:
                                  isMuted ? darkGrey : Colors.transparent,
                              child: _BuildIcons(
                                icon: isMuted ? Icons.mic_off : Icons.mic,

                                onTap: () async {
                                  //Muting mic
                                  micMuteNotifier.value =
                                      !micMuteNotifier.value;
                                  await context
                                      .read<CallProvider>()
                                      .micMuteAndUnmute(mute: !isMuted);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  20.verticalSpace,
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BuildIcons extends StatelessWidget {
  final IconData icon;
  final Function() onTap;
  const _BuildIcons({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Icon(
        icon,
        color: whiteColor,
        size: 35.h,
        shadows: const [
          BoxShadow(
            blurRadius: 1,
            blurStyle: BlurStyle.outer,
            color: blackColor,
            offset: Offset(-1, -1),
          ),
        ],
      ),
    );
  }
}
