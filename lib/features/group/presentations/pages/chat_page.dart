import 'package:chitchat/common/application/notifications/subscriptions.dart';
import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/common/presentations/components/arrow_button.dart';
import 'package:chitchat/common/presentations/components/call_history.dart';
import 'package:chitchat/common/presentations/components/group_date_container.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/components/message_input.dart';
import 'package:chitchat/common/presentations/components/reply_container.dart';
import 'package:chitchat/common/presentations/providers/chat_function_provider.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/group/data/models/chat_model.dart';
import 'package:chitchat/features/group/domain/entities/chat_storage/group_chat_storage_model.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:chitchat/features/group/presentations/blocs/group_chat/group_chat_bloc.dart';
import 'package:chitchat/features/group/presentations/components/audio_tile.dart';
import 'package:chitchat/features/group/presentations/components/delete_selected_chats_dialog.dart';
import 'package:chitchat/features/group/presentations/components/dialog_loading_indicator.dart';
import 'package:chitchat/features/group/presentations/components/image_message_tile.dart';
import 'package:chitchat/features/group/presentations/components/reply_message_prev.dart';
import 'package:chitchat/features/group/presentations/components/text_message_tile.dart';
import 'package:chitchat/features/group/presentations/components/voice_tile.dart';
import 'package:chitchat/features/group/presentations/pages/call_page.dart';
import 'package:chitchat/features/group/presentations/pages/details_page.dart';
import 'package:chitchat/features/group/presentations/pages/leave_alert_dialog.dart';
import 'package:chitchat/features/group/presentations/providers/group_mute_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';

class GroupChatPage extends StatefulWidget {
  final String groupImageUrl;
  final String groupName;
  final String groupBio;
  final String groupId;
  final int groupAdminId;
  final String createdAt;
  final int groupMembersCount;
  final int unreadMessagesCount;
  const GroupChatPage({
    super.key,
    required this.groupName,
    required this.groupImageUrl,
    required this.groupBio,
    required this.groupAdminId,
    required this.groupId,
    required this.createdAt,
    required this.groupMembersCount,
    required this.unreadMessagesCount,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  late final Debouncer _debouncer = Debouncer();
  late final ValueNotifier<bool> _arrowNotifier = ValueNotifier(false);
  late final ValueNotifier<ReplyMessageModel?> _replyNotifier = ValueNotifier(
    null,
  );

  @override
  void initState() {
    super.initState();
    //Text editing controller for getting text when type
    _messageController = TextEditingController();
    //Scroll controller for reaching bottom of the screen
    _scrollController = ScrollController();
    //Removing unread messages count
    if (widget.unreadMessagesCount > 0) {
      context.read<GroupChatBloc>().add(
        RemoveUnreadGroupMessagesCount(groupId: widget.groupId),
      );
    }
    _callNecessaryFunctions();
    _scrollController.addListener(_scrollListener);
    //Scrolling to bottom
    _scrollToBottom(shouldAnimate: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _debouncer.cancel();
    _arrowNotifier.dispose();
    _replyNotifier.dispose();
    super.dispose();
  }

  //For scrolling to bottom of the screen
  void _scrollToBottom({required bool shouldAnimate}) {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //Animating
        if (shouldAnimate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  //For indicating typing ..
  void indicateTyping() {
    //Sending typing indication to all members of this group except current user
    context.read<GroupChatBloc>().add(
      SendIndicationEvent(
        indication:
            "${context.read<CurrentUserProvider>().currentUser.username} is typing •••",
        groupId: widget.groupId,
        userId: context.read<CurrentUserProvider>().currentUser.userId,
        indicationType: "Typing",
      ),
    );
    //Sending "Not typing" to remove "Typing" if the user release hand from keyboard
    _debouncer.debounce(
      duration: const Duration(milliseconds: 500),
      onDebounce: () {
        context.read<GroupChatBloc>().add(
          SendIndicationEvent(
            indication: "Not typing",
            groupId: widget.groupId,
            userId: context.read<CurrentUserProvider>().currentUser.userId,
            indicationType: "Not typing",
          ),
        );
      },
    );
  }

  void _callNecessaryFunctions() async {
    //Fetching group chats from local storage
    context.read<GroupChatBloc>().add(
      FetchGroupMessagesEvent(groupId: widget.groupId),
    );
    //Adding group members count to bloc
    context.read<GroupBloc>().add(
      AddGroupMembersCountEvent(membersCount: widget.groupMembersCount),
    );
    //Connecting group websocket connection
    context.read<GroupChatBloc>().add(
      ConnectGroupChatSocketEvent(
        userId: context.read<CurrentUserProvider>().currentUser.userId,
        groupId: widget.groupId,
      ),
    );
    //Fetching seen info
    context.read<GroupChatBloc>().add(
      FetchGroupMessageSeenInfoEvent(
        groupId: widget.groupId,
        senderId: context.read<CurrentUserProvider>().currentUser.userId,
      ),
    );

    //Changing seen info in firebase and changing reading status in local storage
    context.read<GroupChatBloc>().add(
      ChangeSeenInfoInFirebaseEvent(
        groupId: widget.groupId,
        currentUserId: context.read<CurrentUserProvider>().currentUser.userId,
      ),
    );
    //Checking if the group is in calling
    context.read<GroupChatBloc>().add(
      SendIndicationEvent(
        indication: "call",
        groupId: widget.groupId,
        userId: context.read<CurrentUserProvider>().currentUser.userId,
      ),
    );
    //Checking if the group is muted
    await context.read<GroupMuteProvider>().checkIfMuted(
      groupId: widget.groupId,
    );

    //Unsubscribing fcm topic for not to get message notifications when current user enters in chat page
    await unSubscribeFromGroupMessageTopic(groupId: widget.groupId);
  }

  //For checking if user is scrolling to top
  void _scrollListener() {
    _arrowNotifier.value =
        _scrollController.position.pixels <=
        (_scrollController.position.maxScrollExtent - 200);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) async {
        //Deselecting selected chats if the chats selected
        context.read<GroupChatBloc>().add(DeSelectGroupChats());
        //Closing websocket connection
        context.read<GroupChatBloc>().add(
          CloseGroupChatSocketEvent(groupId: widget.groupId),
        );
        if (!context.read<GroupMuteProvider>().isGroupMuted) {
          await subscribeToGroupMessageTopic(groupId: widget.groupId);
        }
      },
      child: SizedBox(
        height: double.infinity.h,
        width: double.infinity.w,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: GroupDetailsPage(
                        groupName: widget.groupName,
                        groupImageUrl: widget.groupImageUrl,
                        groupId: widget.groupId,
                        createdAt: widget.createdAt,
                        groupAdminId: widget.groupAdminId,
                        groupBio: widget.groupBio,
                        groupMembersCount: widget.groupMembersCount,
                      ),
                    );
                  },
                  child: Hero(
                    tag: "group_details_hero",
                    child: Consumer<ThemeProvider>(
                      builder: (context, theme, _) {
                        return CircleAvatar(
                          radius: 30.r,
                          backgroundColor: theme.isDark ? greyColor : darkWhite,
                          backgroundImage:
                              widget.groupImageUrl.isNotEmpty
                                  ? NetworkImage(widget.groupImageUrl)
                                  : null,
                          child:
                              widget.groupImageUrl.isEmpty
                                  ? Icon(
                                    Icons.group,
                                    color:
                                        context.read<ThemeProvider>().isDark
                                            ? darkWhite
                                            : greyColor,
                                  )
                                  : null,
                        );
                      },
                    ),
                  ),
                ),
                10.horizontalSpace,
                GestureDetector(
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: GroupDetailsPage(
                        groupName: widget.groupName,
                        groupImageUrl: widget.groupImageUrl,
                        groupId: widget.groupId,
                        createdAt: widget.createdAt,
                        groupAdminId: widget.groupAdminId,
                        groupBio: widget.groupBio,
                        groupMembersCount:
                            context.read<GroupBloc>().currentGroupMembersCount,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.groupName,
                        style: getTitleMedium(
                          context: context,
                          fontweight: FontWeight.bold,
                        ),
                      ),
                      BlocListener<GroupChatBloc, GroupChatState>(
                        listenWhen: (_, current) {
                          return (current
                                  is GroupTextMessageSendingErrorState) ||
                              (current is GroupTextMessageSuccessState &&
                                  current.groupId == widget.groupId);
                        },
                        listener: (context, groupChatState) {
                          if (groupChatState is GroupTextMessageSuccessState &&
                              groupChatState.groupId == widget.groupId) {
                            //Changing last message time
                            context.read<GroupBloc>().add(
                              ChangeLastGroupMessageTimeEvent(
                                time: groupChatState.lastTime,
                                groupId: groupChatState.groupId,
                              ),
                            );
                            //changing the position of this group from the tile
                            context.read<GroupBloc>().add(
                              ChangeGroupPositionEvent(
                                groupId: widget.groupId,
                                imageText: "",
                                messageType: "text",
                                textMessage: groupChatState.text,
                                time: groupChatState.lastTime,
                              ),
                            );
                          }
                          if (groupChatState
                              is GroupTextMessageSendingErrorState) {
                            showErrorMessage(context, 'Something went wrong');
                          }
                        },
                        child: const SizedBox.shrink(),
                      ),
                      SizedBox(
                        height: 20.h,
                        width: 180.w,
                        child: BlocBuilder<GroupChatBloc, GroupChatState>(
                          buildWhen: (_, current) {
                            return (current is GroupChatTypingIndicator) ||
                                (current is GroupChatNotTypingIndicator) ||
                                (current is GroupChatRecordingIndicator) ||
                                (current is GroupChatNotRecordingIndicator);
                          },
                          builder: (context, groupChatState) {
                            return Text(
                              groupChatState is GroupChatTypingIndicator
                                  ? groupChatState.indication
                                  : groupChatState
                                      is GroupChatRecordingIndicator
                                  ? groupChatState.indication
                                  : widget.groupBio,
                              style: getBodySmall(
                                context: context,
                                fontweight: FontWeight.w400,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              BlocBuilder<GroupChatBloc, GroupChatState>(
                builder: (context, groupChatState) {
                  if (groupChatState is SelectedGroupChatsState &&
                      groupChatState.selectedChats.isNotEmpty) {
                    return Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return DeleteSelectedGroupChatsDialog(
                                  groupId: widget.groupId,
                                );
                              },
                            );
                          },
                          icon: const Icon(CupertinoIcons.delete),
                        ),
                        PopupMenuButton(
                          color:
                              context.read<ThemeProvider>().isDark
                                  ? blackColor
                                  : whiteColor,
                          borderRadius: BorderRadius.circular(10),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                onTap: () {
                                  //Deselecting all selected chats
                                  context.read<GroupChatBloc>().add(
                                    DeSelectGroupChats(),
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.deselect),
                                    10.horizontalSpace,
                                    Text(
                                      'Deselect',
                                      style: getTitleSmall(context: context),
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    );
                  } else {
                    return _PopupMenuButton(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      groupProfilePic: widget.groupImageUrl,
                      currentMembersCount: widget.groupMembersCount,
                    );
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Opacity(
                opacity: 0.3,
                child: Image.asset(
                  wallpaper1,
                  width: double.infinity.w,
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BlocListener<GroupBloc, GroupState>(
                    listenWhen: (_, current) {
                      return (current is LeaveErrorState) ||
                          (current is LeaveLoadingState) ||
                          (current is LeaveSuccessState);
                    },
                    listener: (context, groupState) {
                      if (groupState is LeaveLoadingState) {
                        //Showing a loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return DialogLoadingIndicator(
                              loadingText: "Leaving...",
                            );
                          },
                        );
                      }
                      if (groupState is LeaveErrorState) {
                        Navigator.of(context).pop();
                        showErrorMessage(context, 'Something went wrong');
                      }
                      if (groupState is LeaveSuccessState) {
                        Navigator.of(context).pop();
                        showSuccessMessage(context, "Exited successfully");
                        Navigator.of(context).pop();
                      }
                    },
                    child: const SizedBox(),
                  ),
                  BlocListener<GroupChatBloc, GroupChatState>(
                    listenWhen: (_, current) {
                      return current is MessageIndicator;
                    },
                    listener: (context, groupChatState) {
                      if (groupChatState is MessageIndicator &&
                          groupChatState.senderId !=
                              context
                                  .read<CurrentUserProvider>()
                                  .currentUser
                                  .userId) {
                        //Increasing seen count
                        context.read<GroupChatBloc>().add(
                          ChangeSeenUserCountEvent(
                            chatId: groupChatState.chatId,
                            groupId: widget.groupId,
                            currentUserId:
                                context
                                    .read<CurrentUserProvider>()
                                    .currentUser
                                    .userId,
                          ),
                        );
                        //Scrolling to bottom when current user sends a message
                        _scrollToBottom(shouldAnimate: false);
                        //Playing chat sound
                        context.read<ChatFunctionProvider>().turnOnChatSound();
                        //Turning on the vibrator
                        context.read<ChatFunctionProvider>().turnOnVibrator();
                        //Scrolling to bottom
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: BlocBuilder<GroupChatBloc, GroupChatState>(
                      buildWhen: (_, current) {
                        return (current is FetchGroupChatLoadingState) ||
                            (current is FetchGroupChatErrorState) ||
                            (current is FetchGroupChatSuccessState) ||
                            (current is FetchSeenInfoLoadingState) ||
                            (current is FetchSeenInfoSuccessState) ||
                            (current is ConnectFirebaseErrorState) ||
                            (current is ConnectFirebaseLoadingState) ||
                            (current is ConnectFirebaseSuccessState);
                      },
                      builder: (context, groupChatState) {
                        if (groupChatState is FetchGroupChatLoadingState ||
                            groupChatState is FetchSeenInfoLoadingState ||
                            groupChatState is ConnectFirebaseLoadingState) {
                          return Center(
                            child: Consumer<ThemeProvider>(
                              builder: (context, theme, _) {
                                return CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor:
                                      theme.isDark ? greyColor : darkWhite,
                                  child: const LoadingIndicator(
                                    color: blueColor,
                                    strokeWidth: 1,
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        if (groupChatState is FetchGroupChatSuccessState) {
                          return Stack(
                            children: [
                              GroupedListView(
                                physics: const BouncingScrollPhysics(),
                                controller: _scrollController,
                                elements: groupChatState.chats.values.toList(),
                                groupSeparatorBuilder: (date) {
                                  return date == ""
                                      ? const SizedBox.shrink()
                                      : GroupDateContainer(
                                        date: formatDate(date),
                                      );
                                },
                                itemBuilder: (context, chat) {
                                  return BlocBuilder<
                                    GroupChatBloc,
                                    GroupChatState
                                  >(
                                    buildWhen: (_, current) {
                                      return current is SelectedGroupChatsState;
                                    },
                                    builder: (context, selectedGroupChatState) {
                                      return GestureDetector(
                                        onLongPress: () {
                                          //Seleting current chat
                                          context.read<GroupChatBloc>().add(
                                            SelectGroupChatEvent(
                                              chatId: chat.chatId,
                                              isSeen: chat.isSeen,
                                              senderId: chat.senderId,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color:
                                                selectedGroupChatState
                                                            is SelectedGroupChatsState &&
                                                        selectedGroupChatState
                                                            .selectedChats
                                                            .containsKey(
                                                              chat.chatId,
                                                            )
                                                    ? context
                                                        .read<
                                                          ChatStyleProvider
                                                        >()
                                                        .chatColor
                                                        .withAlpha(100)
                                                    : Colors.transparent,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: 10.w,
                                              right: 10.w,
                                              bottom: 5.h,
                                              top: 5.h,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  context
                                                              .read<
                                                                CurrentUserProvider
                                                              >()
                                                              .currentUser
                                                              .userId ==
                                                          chat.senderId
                                                      ? MainAxisAlignment.end
                                                      : MainAxisAlignment.start,
                                              children: [
                                                SwipeTo(
                                                  iconColor: lightGrey,
                                                  onLeftSwipe: (_) {
                                                    if (chat.messageType ==
                                                            "audioCall" ||
                                                        chat.messageType ==
                                                            "videoCall") {
                                                      return;
                                                    }
                                                    if (chat.senderId ==
                                                        context
                                                            .read<
                                                              CurrentUserProvider
                                                            >()
                                                            .currentUser
                                                            .userId) {
                                                      _replyNotifier
                                                          .value = ReplyMessageModel(
                                                        senderId: chat.senderId,
                                                        senderName:
                                                            chat.senderName,
                                                        messageType:
                                                            chat.messageType ==
                                                                    "voiceUpload"
                                                                ? "voice"
                                                                : chat.messageType ==
                                                                    "audioUpload"
                                                                ? "audio"
                                                                : chat.messageType ==
                                                                    "imageUpload"
                                                                ? "image"
                                                                : chat
                                                                    .messageType,
                                                        audioDuration:
                                                            chat.audioDuration,
                                                        voiceDuration:
                                                            chat.voiceDuration,
                                                        text: chat.textMessage,
                                                      );
                                                    }
                                                  },
                                                  onRightSwipe: (_) {
                                                    if (chat.messageType ==
                                                            "audioCall" ||
                                                        chat.messageType ==
                                                            "videoCall") {
                                                      return;
                                                    }
                                                    if (chat.senderId !=
                                                        context
                                                            .read<
                                                              CurrentUserProvider
                                                            >()
                                                            .currentUser
                                                            .userId) {
                                                      _replyNotifier
                                                          .value = ReplyMessageModel(
                                                        senderId: chat.senderId,
                                                        senderName:
                                                            chat.senderName,
                                                        messageType:
                                                            chat.messageType ==
                                                                    "voiceUpload"
                                                                ? "voice"
                                                                : chat.messageType ==
                                                                    "audioUpload"
                                                                ? "audio"
                                                                : chat.messageType ==
                                                                    "imageUpload"
                                                                ? "image"
                                                                : chat
                                                                    .messageType,
                                                        audioDuration:
                                                            chat.audioDuration,
                                                        voiceDuration:
                                                            chat.voiceDuration,
                                                        text: chat.textMessage,
                                                      );
                                                    }
                                                  },
                                                  child: _MessageTile(
                                                    groupChat: chat,
                                                    isMe:
                                                        context
                                                            .read<
                                                              CurrentUserProvider
                                                            >()
                                                            .currentUser
                                                            .userId ==
                                                        chat.senderId,
                                                    currentUserId:
                                                        context
                                                            .read<
                                                              CurrentUserProvider
                                                            >()
                                                            .currentUser
                                                            .userId,
                                                    currentUsername:
                                                        context
                                                            .read<
                                                              CurrentUserProvider
                                                            >()
                                                            .currentUser
                                                            .username,
                                                    totalMembers:
                                                        context
                                                            .read<GroupBloc>()
                                                            .currentGroupMembersCount,
                                                    groupImageUrl:
                                                        widget.groupImageUrl,
                                                    groupName: widget.groupName,
                                                    groupAdminUserId:
                                                        widget.groupAdminId,
                                                    groupBio: widget.groupBio,
                                                    groupCreatedAt:
                                                        widget.createdAt,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                groupBy: (groupChat) {
                                  final DateTime? formattedDate =
                                      DateTime.tryParse(groupChat.time);
                                  return formattedDate != null
                                      ? DateTime(
                                        formattedDate.year,
                                        formattedDate.month,
                                        formattedDate.day,
                                      ).toString()
                                      : "";
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: _arrowNotifier,
                                builder: (context, isArrowButtonVisible, _) {
                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child:
                                        isArrowButtonVisible
                                            ? Padding(
                                              padding: EdgeInsets.only(
                                                right: 20.w,
                                                bottom: 10.h,
                                              ),
                                              child: Align(
                                                key: ValueKey<bool>(
                                                  isArrowButtonVisible,
                                                ),
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: SizedBox(
                                                  height: 40.h,
                                                  width: 40.h,
                                                  child: ArrowButton(
                                                    onClicked: () {
                                                      //Going to bottom of the chats
                                                      _scrollToBottom(
                                                        shouldAnimate: false,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            )
                                            : SizedBox.shrink(
                                              key: ValueKey<bool>(
                                                isArrowButtonVisible,
                                              ),
                                            ),
                                  );
                                },
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.w, bottom: 10.h),
                          child: ValueListenableBuilder(
                            valueListenable: _replyNotifier,
                            builder: (context, reply, child) {
                              return reply != null
                                  ? ReplyContainer(
                                    parentMessageSenderName: reply.senderName,
                                    parentMessageType: reply.messageType,
                                    parentMessage: reply.text,
                                    parentMessageAudioDuration:
                                        reply.audioDuration,
                                    parentMessageVoiceDuration:
                                        reply.voiceDuration,
                                    onCloseButtonClicked: () {
                                      _replyNotifier.value = null;
                                    },
                                  )
                                  : const SizedBox.shrink();
                            },
                          ),
                        ),

                        MessageInput(
                          controller: _messageController,
                          scrollController: _scrollController,
                          onMessageSend: () {
                            if (_messageController.text.trim().isEmpty) {
                              return;
                            }
                            //Sending a text message
                            context.read<GroupChatBloc>().add(
                              SendGroupTextMessage(
                                groupName: widget.groupName,
                                groupImageUrl: widget.groupImageUrl,
                                textMessage: _messageController.text.trim(),
                                groupBio: widget.groupBio,
                                currentUserId:
                                    context
                                        .read<CurrentUserProvider>()
                                        .currentUser
                                        .userId,
                                groupId: widget.groupId,
                                currentUsername:
                                    context
                                        .read<CurrentUserProvider>()
                                        .currentUser
                                        .username,
                                totalMembersCount:
                                    context
                                        .read<GroupBloc>()
                                        .currentGroupMembersCount,
                                parentAudioDuration:
                                    _replyNotifier.value?.audioDuration ?? "",
                                parentMessageSenderId:
                                    _replyNotifier.value?.senderId ?? 0,
                                parentSenderName:
                                    _replyNotifier.value?.senderName ?? "",
                                parentMessageType:
                                    _replyNotifier.value?.messageType ?? "",
                                parentText: _replyNotifier.value?.text ?? "",
                                parentVoiceDuration:
                                    _replyNotifier.value?.voiceDuration ?? "",
                                repliedMessage: _replyNotifier.value != null,
                                groupAdminUserId: widget.groupAdminId,
                                groupCreatedAt: widget.createdAt,
                              ),
                            );
                            //Clearing the text editing controller after sent a message
                            _messageController.clear();
                            _replyNotifier.value = null;
                            //Scrolling to bottom
                            _scrollToBottom(shouldAnimate: false);
                          },
                          onImageSend: (image) {
                            //Sending image
                            context.read<GroupChatBloc>().add(
                              UploadGroupChatFileEvent(
                                filePath: image.path,
                                imageText: _messageController.text.trim(),
                                fileType: "image",
                                senderId:
                                    context
                                        .read<CurrentUserProvider>()
                                        .currentUser
                                        .userId,
                                senderName:
                                    context
                                        .read<CurrentUserProvider>()
                                        .currentUser
                                        .username,
                                groupId: widget.groupId,
                                audioVideoDuration: "",
                                audioVideoTitle: "",
                                voiceDuration: "",
                                parentAudioDuration:
                                    _replyNotifier.value?.audioDuration ?? "",
                                parentMessageSenderId:
                                    _replyNotifier.value?.senderId ?? 0,
                                parentMessageSenderName:
                                    _replyNotifier.value?.senderName ?? "",
                                parentMessageType:
                                    _replyNotifier.value?.messageType ?? "",
                                parentText: _replyNotifier.value?.text ?? "",
                                parentVoiceDuration:
                                    _replyNotifier.value?.voiceDuration ?? "",
                                repliedMessage: _replyNotifier.value != null,
                              ),
                            );
                            //Clearing the text
                            _messageController.clear();
                            _replyNotifier.value = null;
                            _scrollToBottom(shouldAnimate: false);
                          },
                          onAudioSend: (audioFile, audioDuration, audioTitle) {
                            //Sending audio
                            context.read<GroupChatBloc>().add(
                              UploadGroupChatFileEvent(
                                filePath: audioFile.xFile.path,
                                imageText: "",
                                fileType: "audio",
                                senderId:
                                    context
                                        .read<CurrentUserProvider>()
                                        .currentUser
                                        .userId,
                                senderName:
                                    context
                                        .read<CurrentUserProvider>()
                                        .currentUser
                                        .username,
                                groupId: widget.groupId,
                                audioVideoDuration: audioDuration,
                                audioVideoTitle: audioTitle,
                                voiceDuration: "",
                                parentAudioDuration:
                                    _replyNotifier.value?.audioDuration ?? "",
                                parentMessageSenderId:
                                    _replyNotifier.value?.senderId ?? 0,
                                parentMessageSenderName:
                                    _replyNotifier.value?.senderName ?? "",
                                parentMessageType:
                                    _replyNotifier.value?.messageType ?? "",
                                parentText: _replyNotifier.value?.text ?? "",
                                parentVoiceDuration:
                                    _replyNotifier.value?.voiceDuration ?? "",
                                repliedMessage: _replyNotifier.value != null,
                              ),
                            );
                            _replyNotifier.value = null;
                          },
                          onVoiceSend: (voicePath, voiceDuration) {
                            //Uploading voice and sending to all members of this group
                            context.read<GroupChatBloc>().add(
                              UploadGroupChatFileEvent(
                                filePath: voicePath,
                                imageText: "",
                                fileType: "voice",
                                senderId:
                                    context
                                        .read<CurrentUserProvider>()
                                        .currentUser
                                        .userId,
                                senderName:
                                    context
                                        .read<CurrentUserProvider>()
                                        .currentUser
                                        .username,
                                groupId: widget.groupId,
                                audioVideoDuration: "",
                                audioVideoTitle: "",
                                voiceDuration: voiceDuration,
                                parentAudioDuration:
                                    _replyNotifier.value?.audioDuration ?? "",
                                parentMessageSenderId:
                                    _replyNotifier.value?.senderId ?? 0,
                                parentMessageSenderName:
                                    _replyNotifier.value?.senderName ?? "",
                                parentMessageType:
                                    _replyNotifier.value?.messageType ?? "",
                                parentText: _replyNotifier.value?.text ?? "",
                                parentVoiceDuration:
                                    _replyNotifier.value?.voiceDuration ?? "",
                                repliedMessage: _replyNotifier.value != null,
                              ),
                            );
                            _replyNotifier.value = null;
                          },
                          onTyping: () {
                            //Indicating typing
                            indicateTyping();
                          },
                          onRecordingStarted: () {
                            //Indicating recording
                            context.read<GroupChatBloc>().add(
                              SendIndicationEvent(
                                indication:
                                    "${context.read<CurrentUserProvider>().currentUser.username} is recording •••",
                                groupId: widget.groupId,
                                userId:
                                    context
                                        .read<CurrentUserProvider>()
                                        .currentUser
                                        .userId,
                                indicationType: "Recording",
                              ),
                            );
                          },
                          onRecordingCancelled: () {
                            //Indicating not recording
                            context.read<GroupChatBloc>().add(
                              SendIndicationEvent(
                                indication: "Not recording",
                                groupId: widget.groupId,
                                userId:
                                    context
                                        .read<CurrentUserProvider>()
                                        .currentUser
                                        .userId,
                                indicationType: "Not recording",
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final GroupChatStorageModel groupChat;
  final bool isMe;
  final String currentUsername;
  final int currentUserId;
  final int totalMembers;
  final String groupName;
  final String groupImageUrl;
  final String groupBio;
  final int groupAdminUserId;
  final String groupCreatedAt;
  const _MessageTile({
    required this.groupChat,
    required this.isMe,
    required this.currentUserId,
    required this.currentUsername,
    required this.totalMembers,
    required this.groupImageUrl,
    required this.groupName,
    required this.groupAdminUserId,
    required this.groupBio,
    required this.groupCreatedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300.w,
            minWidth: 80.w,
            minHeight: 50.h,
          ),
          child: IntrinsicWidth(
            child: IntrinsicHeight(
              child: Consumer2<ChatStyleProvider, ThemeProvider>(
                builder: (context, chatStyle, theme, child) {
                  return Container(
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
                        bottomLeft:
                            isMe
                                ? Radius.circular(chatStyle.borderRadius)
                                : Radius.circular(0),
                        bottomRight:
                            isMe
                                ? Radius.circular(0)
                                : Radius.circular(chatStyle.borderRadius),
                      ),
                    ),

                    child: child,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(3.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Padding(
                          padding: EdgeInsets.only(left: 10.w, right: 10.w),
                          child: Row(
                            children: [
                              Text(
                                groupChat.senderName,
                                style: getTitleSmall(
                                  context: context,
                                  fontweight: FontWeight.w400,
                                  color: lightGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (groupChat.repliedMessage)
                        Padding(
                          padding: EdgeInsets.only(
                            left: 7.h,
                            right: 7.h,
                            top: 7.h,
                          ),
                          child: ReplyMessagePrev(
                            message: groupChat.parentText,
                            messageType: groupChat.parentMessageType,
                            senderName: groupChat.parentMessageSenderName,
                            audioDuration: groupChat.audioDuration,
                            voiceDuration: groupChat.voiceDuration,
                            senderId: groupChat.parentMessageSenderId,
                          ),
                        ),
                      if (groupChat.messageType == "text")
                        GroupTextMessageTile(
                          text: groupChat.textMessage,
                          isMe: isMe,
                          isSeen: groupChat.isSeen,
                          time: groupChat.time,
                          chatId: groupChat.chatId,
                          groupId: groupChat.groupId,
                        ),
                      if (groupChat.messageType == "imageUpload")
                        GroupImageUploadingTile(
                          imagePath: groupChat.imagePath,
                          imageText: groupChat.imageText,
                          chatId: groupChat.chatId,
                          groupId: groupChat.groupId,
                          currentUserId: currentUserId,
                          currentUsername: currentUsername,
                          time: groupChat.time,
                          totalMembersCount: totalMembers,
                          groupImageUrl: groupImageUrl,
                          groupName: groupName,
                          parentAudioDuration: groupChat.parentAudioDuration,
                          parentMessageSenderId:
                              groupChat.parentMessageSenderId,
                          parentMessageSenderName:
                              groupChat.parentMessageSenderName,
                          parentMessageType: groupChat.parentMessageType,
                          parentText: groupChat.parentText,
                          parentVoiceDuration: groupChat.parentVoiceDuration,
                          repliedMessage: groupChat.repliedMessage,
                          groupAdminUserId: groupAdminUserId,
                          groupBio: groupBio,
                          groupCreatedAt: groupCreatedAt,
                        ),
                      if (groupChat.messageType == "image")
                        GroupImageTile(
                          groupId: groupChat.groupId,
                          chatId: groupChat.chatId,
                          senderId: groupChat.senderId,
                          senderName: groupChat.senderName,
                          imagePath: groupChat.imagePath,
                          imageText: groupChat.imageText,
                          time: groupChat.time,
                          isMe: isMe,
                          isSeen: groupChat.isSeen,
                          isDownloaded: groupChat.isMediaDownloaded,
                          totalMembersCount: totalMembers,
                          parentAudioDuration: groupChat.parentAudioDuration,
                          parentMessageSenderId:
                              groupChat.parentMessageSenderId,
                          parentMessageSenderName:
                              groupChat.parentMessageSenderName,
                          parentMessageType: groupChat.parentMessageType,
                          parentText: groupChat.parentText,
                          parentVoiceDuration: groupChat.parentVoiceDuration,
                          repliedMessage: groupChat.repliedMessage,
                        ),
                      if (groupChat.messageType == "audioUpload")
                        GroupAudioUploadTile(
                          audioPath: groupChat.audioPath,
                          audioTitle: groupChat.audioTitle,
                          audioDuration: groupChat.audioDuration,
                          currentUsername: currentUsername,
                          currentUserId: currentUserId,
                          chatId: groupChat.chatId,
                          groupId: groupChat.groupId,
                          time: groupChat.time,
                          totalMembersCount: totalMembers,
                          groupImageUrl: groupImageUrl,
                          groupName: groupName,
                          parentAudioDuration: groupChat.parentAudioDuration,
                          parentMessageSenderId:
                              groupChat.parentMessageSenderId,
                          parentMessageSenderName:
                              groupChat.parentMessageSenderName,
                          parentMessageType: groupChat.parentMessageType,
                          parentText: groupChat.parentText,
                          parentVoiceDuration: groupChat.parentVoiceDuration,
                          repliedMessage: groupChat.repliedMessage,
                          groupAdminUserId: groupAdminUserId,
                          groupBio: groupBio,
                          groupCreatedAt: groupCreatedAt,
                        ),
                      if (groupChat.messageType == "audio")
                        GroupAudioTile(
                          audioPath: groupChat.audioPath,
                          audioDuration: groupChat.audioDuration,
                          audioTitle: groupChat.audioTitle,
                          time: groupChat.time,
                          isMe: isMe,
                          isSeen: groupChat.isSeen,
                          isDownloaded: groupChat.isMediaDownloaded,
                          chatId: groupChat.chatId,
                          groupId: groupChat.groupId,
                          senderId: groupChat.senderId,
                          senderName: groupChat.senderName,
                          totalMembersCount: totalMembers,
                          parentAudioDuration: groupChat.parentAudioDuration,
                          parentMessageSenderId:
                              groupChat.parentMessageSenderId,
                          parentMessageSenderName:
                              groupChat.parentMessageSenderName,
                          parentMessageType: groupChat.parentMessageType,
                          parentText: groupChat.parentText,
                          parentVoiceDuration: groupChat.parentVoiceDuration,
                          repliedMessage: groupChat.repliedMessage,
                        ),
                      if (groupChat.messageType == "voiceUpload")
                        GroupVoiceUploadTile(
                          time: groupChat.time,
                          voiceDuration: groupChat.voiceDuration,
                          currentUserId: currentUserId,
                          currentUsername: currentUsername,
                          totalMembersCount: totalMembers,
                          chatId: groupChat.chatId,
                          groupId: groupChat.groupId,
                          groupImageUrl: groupImageUrl,
                          groupName: groupName,
                          parentAudioDuration: groupChat.parentAudioDuration,
                          parentMessageSenderId:
                              groupChat.parentMessageSenderId,
                          parentMessageSenderName:
                              groupChat.parentMessageSenderName,
                          parentMessageType: groupChat.parentMessageType,
                          parentText: groupChat.parentText,
                          parentVoiceDuration: groupChat.parentVoiceDuration,
                          repliedMessage: groupChat.repliedMessage,
                          groupAdminUserId: groupAdminUserId,
                          groupBio: groupBio,
                          groupCreatedAt: groupCreatedAt,
                        ),

                      if (groupChat.messageType == "voice")
                        GroupVoiceTile(
                          chatId: groupChat.chatId,
                          groupId: groupChat.groupId,
                          senderId: groupChat.senderId,
                          senderName: groupChat.senderName,
                          voicePath: groupChat.voicePath,
                          voiceDuration: groupChat.voiceDuration,
                          time: groupChat.time,
                          isSeen: groupChat.isSeen,
                          isMe: isMe,
                          isDownloaded: groupChat.isMediaDownloaded,
                          totalMembersCount: totalMembers,
                          parentAudioDuration: groupChat.parentAudioDuration,
                          parentMessageSenderId:
                              groupChat.parentMessageSenderId,
                          parentMessageSenderName:
                              groupChat.parentMessageSenderName,
                          parentMessageType: groupChat.parentMessageType,
                          parentText: groupChat.parentText,
                          parentVoiceDuration: groupChat.parentVoiceDuration,
                          repliedMessage: groupChat.repliedMessage,
                        ),
                      if (groupChat.messageType == "audioCall" ||
                          groupChat.messageType == "videoCall")
                        CallHistoryContainer(
                          callType: groupChat.messageType,
                          isMe: isMe,
                          callTime: groupChat.time,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PopupMenuButton extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String groupProfilePic;
  final int currentMembersCount;
  const _PopupMenuButton({
    required this.groupId,
    required this.groupName,
    required this.groupProfilePic,
    required this.currentMembersCount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupChatBloc, GroupChatState>(
      buildWhen: (_, current) {
        return current is GroupCallIndication;
      },
      builder: (context, groupChatState) {
        return PopupMenuButton(
          onOpened: () {
            context.read<GroupChatBloc>().add(
              SendIndicationEvent(
                indication: "call",
                groupId: groupId,
                userId: context.read<CurrentUserProvider>().currentUser.userId,
              ),
            );
          },
          borderRadius: BorderRadius.circular(30),
          color: context.read<ThemeProvider>().isDark ? blackColor : whiteColor,
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                enabled:
                    !(groupChatState is GroupCallIndication &&
                        groupChatState.isInCall),

                onTap: () async {
                  await unSubscribeFromGroupCallTopic(groupId: groupId);
                  if (!context.mounted) {
                    return;
                  }

                  //Saving history
                  context.read<GroupChatBloc>().add(
                    AddGroupCallHistroyEvent(
                      currentUserName:
                          context
                              .read<CurrentUserProvider>()
                              .currentUser
                              .username,
                      currentUserId:
                          context
                              .read<CurrentUserProvider>()
                              .currentUser
                              .userId,
                      callType: "videoCall",
                      groupId: groupId,
                    ),
                  );
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) {
                        return GroupCallPage(
                          groupName: groupName,
                          groupId: groupId,
                          isAudioCall: false,
                          groupProfilePic: groupProfilePic,
                          callType: "groupVideo",
                          isFromNotification: false,
                        );
                      },
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(CupertinoIcons.video_camera_solid),
                    5.horizontalSpace,
                    BlocBuilder<GroupChatBloc, GroupChatState>(
                      buildWhen: (_, current) {
                        return current is GroupCallIndication;
                      },
                      builder: (context, groupChatState) {
                        return Text(
                          groupChatState is GroupCallIndication &&
                                  groupChatState.isInCall
                              ? "Already in call"
                              : "Video call",
                          style: getTitleSmall(context: context),
                        );
                      },
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                enabled:
                    (groupChatState is GroupCallIndication &&
                            groupChatState.isInCall)
                        ? false
                        : true,
                onTap: () async {
                  await unSubscribeFromGroupCallTopic(groupId: groupId);
                  if (!context.mounted) {
                    return;
                  }
                  //Saving history
                  context.read<GroupChatBloc>().add(
                    AddGroupCallHistroyEvent(
                      currentUserName:
                          context
                              .read<CurrentUserProvider>()
                              .currentUser
                              .username,
                      currentUserId:
                          context
                              .read<CurrentUserProvider>()
                              .currentUser
                              .userId,
                      callType: "audioCall",
                      groupId: groupId,
                    ),
                  );
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) {
                        return GroupCallPage(
                          groupName: groupName,
                          groupId: groupId,
                          isAudioCall: true,
                          groupProfilePic: groupProfilePic,
                          callType: "groupAudio",
                          isFromNotification: false,
                        );
                      },
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(CupertinoIcons.phone_fill),
                    5.horizontalSpace,
                    BlocBuilder<GroupChatBloc, GroupChatState>(
                      buildWhen: (_, current) {
                        return current is GroupCallIndication;
                      },
                      builder: (context, groupChatState) {
                        return Text(
                          groupChatState is GroupCallIndication &&
                                  groupChatState.isInCall
                              ? "Already in call"
                              : "Audio call",
                          style: getTitleSmall(context: context),
                        );
                      },
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () async {
                  //Muting and unmuting group notifications
                  await context.read<GroupMuteProvider>().muteOrUnmute(
                    groupId: groupId,
                  );
                },
                child: Consumer<GroupMuteProvider>(
                  builder: (context, groupFun, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        groupFun.isGroupMuted
                            ? const Icon(Icons.volume_up)
                            : const Icon(Icons.volume_off),
                        5.horizontalSpace,
                        Text(
                          groupFun.isGroupMuted ? "Unmute" : "Mute",
                          style: getTitleSmall(context: context),
                        ),
                      ],
                    );
                  },
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return _DeleteDialog(
                        groupId: groupId,
                        groupName: groupName,
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.close),
                    5.horizontalSpace,
                    Text("Clear chat", style: getTitleSmall(context: context)),
                  ],
                ),
              ),

              PopupMenuItem(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return LeaveAlertDialog(
                        groupId: groupId,
                        currentGroupMembersCount: currentMembersCount,
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.logout, color: redColor),
                    5.horizontalSpace,
                    Text("Leave", style: getTitleSmall(context: context)),
                  ],
                ),
              ),
            ];
          },
        );
      },
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  final String groupId;
  final String groupName;
  const _DeleteDialog({required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupChatBloc, GroupChatState>(
      listenWhen: (_, current) {
        return (current is ClearAllGroupChatSuccessState) ||
            (current is ClearAllGroupChatErrorState);
      },
      listener: (context, groupChatState) {
        if (groupChatState is ClearAllGroupChatErrorState) {
          showErrorMessage(context, "Something went wrong");
        }
        if (groupChatState is ClearAllGroupChatSuccessState) {
          showSuccessMessage(context, "Deleted successfully");
        }
      },
      child: Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 400.w,
            maxWidth: 400.w,
            maxHeight: 350.h,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:
                  context.read<ThemeProvider>().isDark ? greyColor : darkWhite,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 15.h),
                  child: Column(
                    children: [
                      Text(
                        'Delete chats ?',
                        style: getTitleMedium(
                          context: context,
                          fontweight: FontWeight.bold,
                        ),
                      ),
                      5.verticalSpace,
                      Padding(
                        padding: EdgeInsets.only(left: 20.w, right: 20.w),
                        child: Text(
                          'All messages from this group will be deleted on your device',
                          style: getTitleSmall(
                            context: context,
                            color: lightGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: AppButton(
                        text: "Cancel",
                        buttonColor: Colors.transparent,
                        textColor: blueColor,
                        showLoading: false,
                        height: 40.h,
                        width: 90.w,
                        borderRadius: 0,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: AppButton(
                        text: "Delete",
                        buttonColor: Colors.transparent,
                        textColor: redColor.withAlpha(180),
                        showLoading: false,
                        height: 40.h,
                        width: 90.w,
                        borderRadius: 0,
                        onTap: () {
                          //Clearing all chats of this group
                          context.read<GroupChatBloc>().add(
                            ClearAllGroupChatsEvent(groupId: groupId),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    20.verticalSpace,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
