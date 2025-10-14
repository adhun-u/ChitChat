import 'dart:convert';
import 'package:chitchat/common/presentations/providers/chat_function_provider.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/group/presentations/blocs/group_call/group_call_bloc.dart';
import 'package:chitchat/features/group/presentations/blocs/group_chat/group_chat_bloc.dart';
import 'package:chitchat/features/group/presentations/components/dialog_loading_indicator.dart';
import 'package:chitchat/features/group/presentations/providers/call_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

class GroupCallPage extends StatefulWidget {
  final String groupName;
  final String groupId;
  final bool isAudioCall;
  final String groupProfilePic;
  final String callType;
  final bool isFromNotification;
  const GroupCallPage({
    super.key,
    required this.groupName,
    required this.groupId,
    required this.isAudioCall,
    required this.groupProfilePic,
    required this.callType,
    required this.isFromNotification,
  });

  @override
  State<GroupCallPage> createState() => _GroupCallPageState();
}

class _GroupCallPageState extends State<GroupCallPage> {
  late final ValueNotifier<bool> _moreSectionVisibleNotifier = ValueNotifier(
    false,
  );
  late final ValueNotifier<bool> _micMuteNotifier = ValueNotifier(false);
  bool _isAnyoneJoined = false;
  @override
  void initState() {
    super.initState();
    //Joining a group call
    context.read<GroupCallBloc>().add(
      JoinGroupCallEvent(
        groupName: widget.groupName,
        currentUserId: context.read<CurrentUserProvider>().currentUser.userId,
        profilePic: context.read<CurrentUserProvider>().currentUser.profilePic,
        username: context.read<CurrentUserProvider>().currentUser.username,
        groupId: widget.groupId,
        groupProfilePic: widget.groupProfilePic,
        callType: widget.callType,
      ),
    );

    if (!widget.isFromNotification) {
      //Starting the timer
      context.read<GroupCallBloc>().add(StartGroupCallTimer());
    }
    //Connecting the group socket if the user is coming from notification
    context.read<GroupChatBloc>().add(
      ConnectGroupChatSocketEvent(
        userId: context.read<CurrentUserProvider>().currentUser.userId,
        groupId: widget.groupId,
      ),
    );
  }

  @override
  void dispose() {
    _moreSectionVisibleNotifier.dispose();
    _micMuteNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BlocListener<GroupCallBloc, GroupCallState>(
            listenWhen: (_, current) {
              return (current is JoinGroupCallErrorState) ||
                  (current is JoinGroupCallLoadingState) ||
                  (current is JoinGroupCallSuccessState) ||
                  (current is GroupCallTimeOutState);
            },
            listener: (context, groupCallState) async {
              if (groupCallState is GroupCallTimeOutState) {
                //Sending to socket to change call state (calling to ended)
                context.read<GroupChatBloc>().add(
                  SendIndicationEvent(
                    indication: "close",
                    groupId: widget.groupId,
                    userId:
                        context.read<CurrentUserProvider>().currentUser.userId,
                  ),
                );
                //Clearing the resources and leaving from call page
                context.read<GroupCallProvider>().disposeResource();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Call ended"),
                    backgroundColor:
                        context.read<ThemeProvider>().isDark
                            ? whiteColor
                            : blackColor,
                  ),
                );
                //Stopping the timer
                context.read<GroupCallBloc>().add(StopGroupCallTimer());
                Navigator.of(context).pop();
              }
              if (groupCallState is JoinGroupCallSuccessState) {
                //Connecting to the group call
                await context.read<GroupCallProvider>().connect(
                  token: groupCallState.token,
                  isAudioCall: widget.isAudioCall,
                  onMemberJoined: (username) {
                    if (!_isAnyoneJoined) {
                      //Stopping the timer
                      context.read<GroupCallBloc>().add(StopGroupCallTimer());
                      _isAnyoneJoined = true;
                    }
                    //Playing a sound when a user enters in group call
                    context
                        .read<ChatFunctionProvider>()
                        .playMemberJoinedSound();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$username is joined"),
                        backgroundColor:
                            context.read<ThemeProvider>().isDark
                                ? whiteColor
                                : blackColor,
                      ),
                    );
                  },
                  onMemberLeft: (username) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$username is left"),
                        backgroundColor:
                            context.read<ThemeProvider>().isDark
                                ? whiteColor
                                : blackColor,
                      ),
                    );
                  },
                  whenEveryOneLeaves: () {
                    //Sending to socket to change call state (calling to ended)
                    context.read<GroupChatBloc>().add(
                      SendIndicationEvent(
                        indication: "close",
                        groupId: widget.groupId,
                        userId:
                            context
                                .read<CurrentUserProvider>()
                                .currentUser
                                .userId,
                      ),
                    );
                    //If everyone leaves from the call , clearing resources and leaving from call page
                    context.read<GroupCallProvider>().disposeResource();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Call ended"),
                        backgroundColor:
                            context.read<ThemeProvider>().isDark
                                ? whiteColor
                                : blackColor,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                );
              }
            },
            child: const SizedBox(),
          ),
          Padding(
            padding: EdgeInsets.all(3.h),
            child: BlocBuilder<GroupCallBloc, GroupCallState>(
              buildWhen: (_, current) {
                return (current is JoinGroupCallErrorState) ||
                    (current is JoinGroupCallLoadingState) ||
                    (current is JoinGroupCallSuccessState);
              },
              builder: (context, groupCallState) {
                if (groupCallState is JoinGroupCallLoadingState) {
                  return SizedBox(
                    height: 925.h,
                    child: Center(
                      child: DialogLoadingIndicator(
                        loadingText: "Connecting group call...",
                      ),
                    ),
                  );
                }
                if (groupCallState is JoinGroupCallSuccessState) {
                  return Stack(
                    children: [
                      SizedBox(
                        height: 925.h,
                        width: double.infinity.w,
                        child: Center(
                          child: Consumer<GroupCallProvider>(
                            builder: (context, groupCall, _) {
                              return groupCall.room.remoteParticipants.isEmpty
                                  ? _NoParticipantsJoinedInfo(
                                    isAudioCall: widget.isAudioCall,
                                  )
                                  : GridView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1.4 / 2.5,
                                        ),
                                    itemCount:
                                        groupCall.remoteParticipants.length,
                                    itemBuilder: (context, index) {
                                      final String? jsonMetaData =
                                          groupCall.remoteParticipants.values
                                              .toList()[index]
                                              .metadata;
                                      final Map<String, dynamic>?
                                      partcipantMetaData =
                                          jsonMetaData != null
                                              ? jsonDecode(jsonMetaData)
                                              : null;
                                      final RemoteParticipant
                                      remoteParticipant =
                                          groupCall.remoteParticipants.values
                                              .toList()[index];
                                      return Padding(
                                        padding: EdgeInsets.all(3.h),
                                        child: _ParticipantWidget(
                                          isAudioCall: widget.isAudioCall,
                                          imageUrl:
                                              partcipantMetaData != null
                                                  ? partcipantMetaData['profilePic']
                                                  : "",
                                          username:
                                              partcipantMetaData != null
                                                  ? partcipantMetaData['username']
                                                  : "Unknown",
                                          isSpeaking:
                                              remoteParticipant.isSpeaking,
                                          videoTrack:
                                              remoteParticipant
                                                  .videoTrackPublications
                                                  .firstOrNull
                                                  ?.track,
                                        ),
                                      );
                                    },
                                  );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10.w,
                        bottom: 10.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                onTap: () {
                                  _moreSectionVisibleNotifier.value =
                                      !_moreSectionVisibleNotifier.value;
                                },
                                child: Consumer<ThemeProvider>(
                                  builder: (context, theme, child) {
                                    return Container(
                                      height: 280.h,
                                      width: 170.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        color:
                                            theme.isDark
                                                ? greyColor
                                                : darkWhite,
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      !widget.isAudioCall &&
                                              context
                                                      .watch<
                                                        GroupCallProvider
                                                      >()
                                                      .room
                                                      .localParticipant
                                                      ?.videoTrackPublications
                                                      .firstOrNull !=
                                                  null
                                          ? IgnorePointer(
                                            child: VideoTrackRenderer(
                                              context
                                                      .watch<
                                                        GroupCallProvider
                                                      >()
                                                      .room
                                                      .localParticipant
                                                      ?.videoTrackPublications
                                                      .firstOrNull!
                                                      .track
                                                  as VideoTrack,
                                              fit: VideoViewFit.cover,
                                              mirrorMode:
                                                  VideoViewMirrorMode.mirror,
                                            ),
                                          )
                                          : Center(
                                            child: CircleAvatar(
                                              radius: 45.r,
                                              backgroundColor: lightGrey,
                                              backgroundImage:
                                                  context
                                                          .read<
                                                            CurrentUserProvider
                                                          >()
                                                          .currentUser
                                                          .profilePic
                                                          .isNotEmpty
                                                      ? NetworkImage(
                                                        context
                                                            .read<
                                                              CurrentUserProvider
                                                            >()
                                                            .currentUser
                                                            .profilePic,
                                                      )
                                                      : null,
                                              child:
                                                  context
                                                          .read<
                                                            CurrentUserProvider
                                                          >()
                                                          .currentUser
                                                          .profilePic
                                                          .isEmpty
                                                      ? Icon(
                                                        Icons.person,
                                                        size: 35.h,
                                                      )
                                                      : null,
                                            ),
                                          ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 10.h,
                                          left: 10.w,
                                          right: 10.w,
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(
                                            context
                                                .read<CurrentUserProvider>()
                                                .currentUser
                                                .username,
                                            style: TextStyle(
                                              fontSize:
                                                  getTitleSmall(
                                                    context: context,
                                                  ).fontSize,
                                              fontWeight: FontWeight.bold,
                                              color: whiteColor,
                                              shadows: const [
                                                Shadow(
                                                  offset: Offset(-0.5, -0.5),
                                                  color: blackColor,
                                                ),
                                                Shadow(
                                                  offset: Offset(0.5, -0.5),
                                                  color: blackColor,
                                                ),
                                                Shadow(
                                                  offset: Offset(0.5, 0.5),
                                                  color: blackColor,
                                                ),
                                                Shadow(
                                                  offset: Offset(-0.5, 0.5),
                                                  color: blackColor,
                                                ),
                                              ],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: _moreSectionVisibleNotifier,
                              builder: (context, isVisible, _) {
                                return isVisible
                                    ? 10.verticalSpace
                                    : const SizedBox.shrink();
                              },
                            ),
                            Consumer<ThemeProvider>(
                              builder: (context, theme, _) {
                                return ValueListenableBuilder(
                                  valueListenable: _moreSectionVisibleNotifier,
                                  builder: (context, isVisible, child) {
                                    return isVisible
                                        ? Container(
                                          height: 100.h,
                                          width:
                                              widget.isAudioCall
                                                  ? 170.w
                                                  : 310.w,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                            color:
                                                theme.isDark
                                                    ? greyColor
                                                    : darkWhite,
                                          ),
                                          child: child,
                                        )
                                        : const SizedBox();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!widget.isAudioCall)
                                        GestureDetector(
                                          onTap: () async {
                                            //Turning off and on the camera
                                            await context
                                                .read<GroupCallProvider>()
                                                .turnOffAndOnCamera();
                                          },
                                          child: Consumer<ThemeProvider>(
                                            builder: (context, theme, _) {
                                              return CircleAvatar(
                                                radius: 38.r,
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Selector<
                                                  GroupCallProvider,
                                                  bool
                                                >(
                                                  selector: (_, groupCall) {
                                                    return groupCall
                                                        .isCameraTurnedOff;
                                                  },
                                                  builder: (
                                                    context,
                                                    isTurnedOff,
                                                    _,
                                                  ) {
                                                    return Icon(
                                                      isTurnedOff
                                                          ? Icons.videocam
                                                          : Icons.videocam_off,
                                                      color:
                                                          theme.isDark
                                                              ? whiteColor
                                                              : blackColor,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      if (!widget.isAudioCall)
                                        GestureDetector(
                                          onTap: () async {
                                            //Flipping the camera from front to back or back to front
                                            await context
                                                .read<GroupCallProvider>()
                                                .switchCamera();
                                          },
                                          child: Consumer<ThemeProvider>(
                                            builder: (context, theme, _) {
                                              return CircleAvatar(
                                                radius: 38.r,
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Icon(
                                                  Icons.flip_camera_ios,
                                                  color:
                                                      theme.isDark
                                                          ? whiteColor
                                                          : blackColor,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ValueListenableBuilder(
                                        valueListenable: _micMuteNotifier,
                                        builder: (context, isMicMuted, _) {
                                          return GestureDetector(
                                            onTap: () async {
                                              _micMuteNotifier.value =
                                                  !_micMuteNotifier.value;
                                              //Muting and unmuting current user's mic
                                              await context
                                                  .read<GroupCallProvider>()
                                                  .micMuteAndUnmute();
                                            },
                                            child: CircleAvatar(
                                              radius: 38.r,
                                              backgroundColor:
                                                  isMicMuted
                                                      ? theme.isDark
                                                          ? lightGrey
                                                          : darkWhite2
                                                      : Colors.transparent,
                                              child:
                                                  isMicMuted
                                                      ? Icon(
                                                        Icons.mic,
                                                        color:
                                                            theme.isDark
                                                                ? whiteColor
                                                                : blackColor,
                                                      )
                                                      : Icon(
                                                        Icons.mic_off,
                                                        color:
                                                            theme.isDark
                                                                ? whiteColor
                                                                : blackColor,
                                                      ),
                                            ),
                                          );
                                        },
                                      ),
                                      10.horizontalSpace,
                                      GestureDetector(
                                        onTap: () {
                                          if (!widget.isFromNotification) {
                                            //Stopping the timer
                                            context.read<GroupCallBloc>().add(
                                              StopGroupCallTimer(),
                                            );
                                          }
                                          //Sending to socket to change call state (calling to ended)
                                          context.read<GroupChatBloc>().add(
                                            SendIndicationEvent(
                                              indication: "close",
                                              groupId: widget.groupId,
                                              userId:
                                                  context
                                                      .read<
                                                        CurrentUserProvider
                                                      >()
                                                      .currentUser
                                                      .userId,
                                            ),
                                          );
                                          //Disposing the all resources to exist the call
                                          context
                                              .read<GroupCallProvider>()
                                              .disposeResource();
                                          Navigator.of(context).pop();
                                        },
                                        child: CircleAvatar(
                                          radius: 38.r,
                                          backgroundColor: redColor.withAlpha(
                                            200,
                                          ),
                                          child: const Icon(
                                            Icons.call_end,
                                            color: whiteColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantWidget extends StatelessWidget {
  final String imageUrl;
  final String username;
  final bool isSpeaking;
  final bool isAudioCall;
  final VideoTrack? videoTrack;
  const _ParticipantWidget({
    required this.imageUrl,
    required this.username,
    required this.isSpeaking,
    required this.isAudioCall,
    required this.videoTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Container(
          width: 120.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: theme.isDark ? greyColor : darkWhite,
            border: Border.all(width: isSpeaking ? 2 : 0, color: blueColor),
          ),
          child: child,
        );
      },
      child: Stack(
        children: [
          if (isSpeaking)
            Padding(
              padding: EdgeInsets.only(right: 5.w, top: 10.h),
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 17.r,
                  backgroundColor: blueColor,
                  child: Padding(
                    padding: EdgeInsets.all(8.h),
                    child: AnimatedWaveList(
                      stream: createRandomAmplitudeStream(),
                      barBuilder: (animation, amplitude) {
                        return WaveFormBar(
                          amplitude: amplitude,
                          animation: animation,
                          color: whiteColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          isAudioCall || videoTrack == null
              ? Center(
                child: CircleAvatar(
                  radius: 45.r,
                  backgroundColor: lightGrey,
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child:
                      imageUrl.isEmpty ? Icon(Icons.person, size: 35.h) : null,
                ),
              )
              : VideoTrackRenderer(videoTrack!, fit: VideoViewFit.cover),
          Padding(
            padding: EdgeInsets.only(bottom: 10.h, left: 10.w, right: 10.w),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: whiteColor,
                  shadows: [
                    Shadow(offset: Offset(-0.5, -0.5), color: blackColor),
                    Shadow(offset: Offset(0.5, -0.5), color: blackColor),
                    Shadow(offset: Offset(0.5, 0.5), color: blackColor),
                    Shadow(offset: Offset(-0.5, 0.5), color: blackColor),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoParticipantsJoinedInfo extends StatelessWidget {
  final bool isAudioCall;
  const _NoParticipantsJoinedInfo({required this.isAudioCall});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60.r,
          backgroundColor: isAudioCall ? Colors.green : blueColor,
          child: Icon(
            isAudioCall
                ? CupertinoIcons.phone_fill
                : CupertinoIcons.videocam_fill,
            size: 40.h,
            color: whiteColor,
          ),
        ),
        10.verticalSpace,
        Text(
          'No participants joined',
          style: getTitleMedium(
            context: context,
            fontweight: FontWeight.bold,
            color: lightGrey,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: lightGrey),
            5.horizontalSpace,
            Text(
              'Wait for other group members to join',
              style: getBodySmall(
                context: context,
                fontweight: FontWeight.w300,
                color: lightGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
