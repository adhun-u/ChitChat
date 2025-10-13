import 'dart:io';
import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/presentations/components/audio_play_prev.dart';
import 'package:chitchat/common/presentations/pages/show_image_prev.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/home/domain/entities/chat_storage/chat_storage_entity.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:chitchat/features/home/presentations/pages/call_page.dart';
import 'package:chitchat/features/home/presentations/pages/show_all_media.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  final String profilePic;
  final String username;
  final String userbio;
  final int userId;
  final bool isOnline;
  final int receiverId;
  const UserProfilePage({
    super.key,
    required this.profilePic,
    required this.username,
    required this.userbio,
    required this.userId,
    required this.isOnline,
    required this.receiverId,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final CurrentUserModel _currentUser;
  @override
  void initState() {
    super.initState();
    _currentUser = context.read<CurrentUserProvider>().currentUser;
    //Fetching all messages count
    context.read<ChatBloc>().add(
      FetchMessageCountEvent(
        currentUserId: _currentUser.userId,
        receiverId: widget.receiverId,
      ),
    );
    //Fetching media from local storage
    context.read<ChatBloc>().add(
      FetchMediaEvent(
        currentUserId: _currentUser.userId,
        oppositeUserId: widget.userId,
        limit: 9,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Profile',
          style: getTitleMedium(context: context, fontweight: FontWeight.bold),
        ),
        titleSpacing: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Hero(
              tag: "profile-hero",
              child: Consumer<ThemeProvider>(
                builder: (context, theme, _) {
                  return CircleAvatar(
                    radius: 70.r,
                    backgroundColor: theme.isDark ? greyColor : darkWhite,
                    backgroundImage:
                        widget.profilePic.isNotEmpty
                            ? NetworkImage(widget.profilePic)
                            : null,
                    child:
                        widget.profilePic.isEmpty
                            ? Icon(Icons.person, size: 60.h, color: lightGrey)
                            : null,
                  );
                },
              ),
            ),
          ),
          10.verticalSpace,
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 50.h, maxWidth: 300.w),
            child: Text(
              widget.username,
              style: getTitleLarge(
                context: context,
                fontweight: FontWeight.bold,
              ),
              overflow: TextOverflow.clip,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (_, current) {
                  return current is OnlineIndicationState;
                },
                builder: (context, chatState) {
                  if (chatState is OnlineIndicationState) {
                    return Text(
                      chatState.isOnline ? "Online now" : "Offline now",
                      style: getTitleSmall(
                        context: context,
                        fontweight: FontWeight.bold,
                        color: chatState.isOnline ? Colors.green : lightGrey,
                      ),
                    );
                  }
                  return Text(
                    widget.isOnline ? "Online now" : "Offline now",
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.bold,
                      color: widget.isOnline ? greenColor : lightGrey,
                    ),
                  );
                },
              ),
            ],
          ),
          5.verticalSpace,
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 100.h, maxWidth: 300.w),
            child: SizedBox(
              child: Text(
                widget.userbio,
                style: getBodySmall(
                  context: context,
                  fontweight: FontWeight.w400,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          30.verticalSpace,
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (_, current) {
              return current is MessageCountState;
            },
            builder: (context, chatState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TextAndCount(
                    count:
                        chatState is MessageCountState
                            ? chatState.totalMessageCount
                            : 0,
                    text: "Messages",
                  ),
                  10.horizontalSpace,
                  _TextAndCount(
                    count:
                        chatState is MessageCountState
                            ? chatState.totalImagesCount
                            : 0,
                    text: "Photos",
                  ),
                  10.horizontalSpace,
                  _TextAndCount(
                    count:
                        chatState is MessageCountState
                            ? chatState.totalAudiosCount
                            : 0,
                    text: "Audios",
                  ),
                ],
              );
            },
          ),

          20.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _VideoAudioCallButtons(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) {
                        return CallPage(
                          displayName: widget.username,
                          imageUrl: widget.profilePic,
                          userId: widget.userId,
                          currentUserId: _currentUser.userId,
                          currentUsername: _currentUser.username,
                          currentUserProfilePic: _currentUser.profilePic,
                          isSomeCalling: false,
                          isAudioCall: true,
                        );
                      },
                    ),
                  );
                },
                text: "Video",
                icon: CupertinoIcons.video_camera_solid,
                buttonColor: blueColor,
              ),
              10.horizontalSpace,
              _VideoAudioCallButtons(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) {
                        return CallPage(
                          displayName: widget.username,
                          imageUrl: widget.profilePic,
                          userId: widget.userId,
                          currentUserId: _currentUser.userId,
                          currentUsername: _currentUser.username,
                          currentUserProfilePic: _currentUser.profilePic,
                          isSomeCalling: false,
                          isAudioCall: true,
                        );
                      },
                    ),
                  );
                },
                text: "Audio",
                icon: CupertinoIcons.phone_fill,
                buttonColor: Colors.green,
              ),
            ],
          ),
          10.verticalSpace,
          Divider(color: lightGrey, endIndent: 15.w, indent: 15.w),
          _RecentMediaSection(
            currentUserId: _currentUser.userId,
            oppositeUserId: widget.userId,
          ),
        ],
      ),
    );
  }
}

class _RecentMediaSection extends StatelessWidget {
  final int currentUserId;
  final int oppositeUserId;

  const _RecentMediaSection({
    required this.currentUserId,
    required this.oppositeUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (_, current) {
        return (current is FetchMediaErrorState) ||
            (current is FetchMediaLoadingState) ||
            (current is FetchMediaSuccessState);
      },
      builder: (context, chatState) {
        if (chatState is FetchMediaSuccessState && chatState.media.isNotEmpty) {
          return Expanded(
            child: Column(
              children: [
                if (chatState.media.length > 9)
                  Padding(
                    padding: EdgeInsets.only(right: 5.w),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: CupertinoButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) {
                                return ShowAllMedia(
                                  currentUserId: currentUserId,
                                  oppositeUserId: oppositeUserId,
                                );
                              },
                            ),
                          );
                        },
                        sizeStyle: CupertinoButtonSize.small,
                        child: Text(
                          "View all",
                          style: getTitleSmall(
                            context: context,
                            fontweight: FontWeight.bold,
                            color: blueColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    child: GridView.builder(
                      itemCount: chatState.media.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final ChatStorageDBModel chat = chatState.media[index];
                        return Padding(
                          padding: EdgeInsets.only(left: 5.w, top: 5.h),
                          child: GestureDetector(
                            onTap: () {
                              if (chat.type == "audio") {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) {
                                      return AudioPlayPrev(
                                        audioId: chat.chatId,
                                        audioPath: chat.audioPath,
                                        audioTitle: chat.audioTitle,
                                      );
                                    },
                                  ),
                                );
                              } else if (chat.type == "image") {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) {
                                      return ShowImagePrev(
                                        imagePath: chat.imagePath ?? "",
                                        username: "",
                                        sentImageTime: formatDate(chat.date),
                                        heroTag: chat.chatId,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image:
                                    chat.type == "image"
                                        ? DecorationImage(
                                          fit: BoxFit.cover,

                                          image: FileImage(
                                            File(chat.imagePath ?? ""),
                                          ),
                                        )
                                        : null,
                                color:
                                    context.read<ThemeProvider>().isDark
                                        ? greyColor
                                        : darkWhite,
                              ),
                              child:
                                  chat.type == "audio"
                                      ? Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: 10.w,
                                                top: 10.h,
                                              ),
                                              child: Text(
                                                chat.audioDuration,
                                                style: getBodySmall(
                                                  context: context,
                                                  fontweight: FontWeight.w400,
                                                  color: lightGrey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Icon(
                                              Icons.music_note,
                                              size: 35.h,
                                              color: blueColor,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: 10.w,
                                              right: 10.w,
                                              bottom: 10.w,
                                            ),
                                            child: Text(
                                              chat.audioTitle,
                                              style: getBodySmall(
                                                context: context,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                      : const SizedBox(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (chatState is FetchMediaSuccessState && chatState.media.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Media',
                      style: getTitleMedium(
                        context: context,
                        fontweight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              10.verticalSpace,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, theme, _) {
                      return CircleAvatar(
                        radius: 55.r,
                        backgroundColor: theme.isDark ? greyColor : darkWhite,
                        child: Icon(
                          CupertinoIcons.photo,
                          color: lightGrey,
                          size: 40.h,
                        ),
                      );
                    },
                  ),
                  15.verticalSpace,
                  Text(
                    'No recent media',
                    style: getTitleLarge(
                      context: context,
                      fontweight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: lightGrey,
                    ),
                  ),
                  5.verticalSpace,
                  Text(
                    'Photos, videos and files will appear here',
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.w400,
                      fontSize: 13.sp,
                      color: lightGrey,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _VideoAudioCallButtons extends StatelessWidget {
  final Function() onTap;
  final String text;
  final IconData icon;
  final Color buttonColor;

  const _VideoAudioCallButtons({
    required this.onTap,
    required this.text,
    required this.icon,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      width: 180.w,
      child: CupertinoButton(
        onPressed: () {
          onTap();
        },
        color: buttonColor,
        borderRadius: BorderRadius.circular(30),
        sizeStyle: CupertinoButtonSize.small,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: whiteColor, size: 35.h),
            5.horizontalSpace,
            Text(
              text,
              style: getTitleMedium(
                context: context,
                fontweight: FontWeight.bold,
                color: whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextAndCount extends StatelessWidget {
  final String text;
  final int count;
  const _TextAndCount({required this.count, required this.text});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Container(
          height: 90.h,
          width: 120.h,
          decoration: BoxDecoration(
            color: theme.isDark ? greyColor : darkWhite,
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count > 999 ? "1K+" : count.toString(),
            style: getTitleMedium(
              context: context,
              fontweight: FontWeight.bold,
            ),
          ),
          5.verticalSpace,
          Text(
            text,
            style: getTitleSmall(context: context, fontweight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
