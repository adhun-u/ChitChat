import 'package:chitchat/common/application/notifications/subscriptions.dart';
import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/presentations/components/arrow_button.dart';
import 'package:chitchat/common/presentations/components/call_history.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/components/reply_container.dart';
import 'package:chitchat/common/presentations/providers/audio_provider.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/common/presentations/components/group_date_container.dart';
import 'package:chitchat/common/presentations/components/message_input.dart';
import 'package:chitchat/common/presentations/providers/chat_function_provider.dart';
import 'package:chitchat/features/group/presentations/components/dialog_loading_indicator.dart';
import 'package:chitchat/features/home/data/models/chat_model.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:chitchat/features/home/presentations/blocs/user/user_bloc.dart';
import 'package:chitchat/features/home/presentations/components/audio_tile.dart';
import 'package:chitchat/features/home/presentations/components/delete_chats_dialog.dart';
import 'package:chitchat/features/home/presentations/components/delete_selected_chats_dialog.dart';
import 'package:chitchat/features/home/presentations/components/image_message_tile.dart';
import 'package:chitchat/features/home/presentations/components/remove_user_dialog.dart';
import 'package:chitchat/features/home/presentations/components/text_message_tile.dart';
import 'package:chitchat/features/home/presentations/components/voice_tile.dart';
import 'package:chitchat/features/home/presentations/pages/call_page.dart';
import 'package:chitchat/features/home/presentations/pages/user_profile_page.dart';
import 'package:chitchat/features/home/presentations/providers/mute_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatPage extends StatefulWidget {
  final int userId;
  final String username;
  final String profilePic;
  final int unreadMessageCount;
  final String userbio;
  const ChatPage({
    super.key,
    required this.profilePic,
    required this.userId,
    required this.username,
    required this.unreadMessageCount,
    required this.userbio,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _messageController = TextEditingController();
  late final CurrentUserModel currentUser;
  late final ScrollController _scrollController;
  late final ValueNotifier<bool> _isArrowButtonVisible = ValueNotifier(false);
  late final ValueNotifier<ReplyMessageModel?> _replyNotifier = ValueNotifier(
    null,
  );
  final Debouncer _debouncer = Debouncer();

  //For indicating typing ..
  void indicateTyping() {
    //Sending typing indication if user is typing
    context.read<ChatBloc>().add(
      IndicateEvent(
        indication: "Typing",
        receiverId: widget.userId,
        senderId: context.read<CurrentUserProvider>().currentUser.userId,
      ),
    );
    //Sending "Not typing" to remove "Typing" if the user release hand from keyboard
    _debouncer.debounce(
      duration: const Duration(milliseconds: 500),
      onDebounce: () {
        context.read<ChatBloc>().add(
          IndicateEvent(
            indication: "Not typing",
            receiverId: widget.userId,
            senderId: context.read<CurrentUserProvider>().currentUser.userId,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    currentUser = context.read<CurrentUserProvider>().currentUser;
    //Entering in chat connection
    context.read<ChatBloc>().add(
      EnterChatConnectionEvent(receiverId: widget.userId),
    );
    context.read<ChatBloc>().add(
      FetchSeenInfoEvent(
        currentUserId: currentUser.userId,
        receiverId: widget.userId,
      ),
    );
    //Fetch temporary message
    context.read<ChatBloc>().add(
      FetchTempMessagesEvent(
        receiverId: widget.userId,
        currentUserId: context.read<CurrentUserProvider>().currentUser.userId,
      ),
    );
    //Retrieving all chats
    context.read<ChatBloc>().add(
      RetrieveChatEvent(
        senderId: currentUser.userId,
        receiverId: widget.userId,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollBottom(currentUser.userId);
    });
    //Checking if the user is scrolling
    _scrollController.addListener(_scrollListener);

    //To remove unread message count
    context.read<ChatBloc>().add(
      RemoveUnreadMessagesCount(
        currentUserId: currentUser.userId,
        receiverId: widget.userId,
      ),
    );
    //To check whether the user is muted or not
    context.read<MuteProvider>().checkIfMuted(userId: widget.userId);
    _unSubUserTopic();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _isArrowButtonVisible.dispose();
    _replyNotifier.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  //Creating a function to scroll bottom when new message come
  void _scrollBottom(int? senderId) {
    //Checking if the scroll controller attached to the listviw.builder
    if (!_scrollController.hasClients) {
      return;
    }
    //If the user is scrolling forward or reverse , then not allowing to scroll down when new message comes
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward ||
        _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
      return;
    }
    //If the user scrolls to top , then not allowing to scroll
    bool isNotNearBottom =
        _scrollController.position.pixels <
        (_scrollController.position.maxScrollExtent - 100.0);
    if (isNotNearBottom && senderId != currentUser.userId) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _scrollListener() {
    _isArrowButtonVisible.value =
        _scrollController.position.pixels <
        (_scrollController.position.maxScrollExtent - 200);
  }

  void _unSubUserTopic() async {
    //Muting message notifications to not get notifications while in chat
    await unSubscribeFromUserMessageTopic(
      currentUserId: currentUser.userId,
      anotherUserId: widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) async {
        //Changing the last message time to sort
        final LastMessageModel? lastMessage =
            context
                .read<ChatBloc>()
                .lastMessage["${currentUser.userId}${widget.userId}"];

        if (lastMessage != null) {
          context.read<UserBloc>().add(
            ChangeLastMessageTimeEvent(
              lastMessageTime: lastMessage.time,
              userId: widget.userId,
            ),
          );
        }
        //Deselecting all selected chats if the chat are selected
        context.read<ChatBloc>().add(DeSelectChatEvent());
        //For exist from chat socket connection
        context.read<ChatBloc>().add(ExitFromChatConnectionEvent());
        //Deleting all sources from audio player
        await context.read<AudioProvider>().deleteAllSourceAndDispose();
        if (context.mounted) {
          //Subscribing to the user topic to get notification if the user is not muted
          if (!context.read<MuteProvider>().isMuted) {
            await subscribeToUserMessageTopic(
              currentUserId: currentUser.userId,
              anotherUserId: widget.userId,
            );
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            titleSpacing: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    BlocBuilder<ChatBloc, ChatState>(
                      buildWhen: (_, current) {
                        return current is OnlineIndicationState;
                      },
                      builder: (context, chatState) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) {
                                  return UserProfilePage(
                                    profilePic: widget.profilePic,
                                    username: widget.username,
                                    isOnline:
                                        chatState is OnlineIndicationState &&
                                        chatState.isOnline,
                                    userbio: widget.userbio,
                                    userId: widget.userId,

                                    receiverId: widget.userId,
                                  );
                                },
                              ),
                            );
                          },
                          child: Hero(
                            tag: "profile-hero",
                            child: Consumer<ThemeProvider>(
                              builder: (context, theme, _) {
                                return CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor:
                                      theme.isDark ? greyColor : darkWhite,
                                  backgroundImage:
                                      widget.profilePic.isNotEmpty
                                          ? NetworkImage(widget.profilePic)
                                          : null,
                                  child:
                                      widget.profilePic.isEmpty
                                          ? Icon(Icons.person, size: 35.h)
                                          : null,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 140.w,
                            child: Text(
                              widget.username,
                              style: getTitleMedium(
                                context: context,
                                fontweight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          BlocBuilder<ChatBloc, ChatState>(
                            buildWhen: (_, current) {
                              return current is TypeIndicatorState ||
                                  current is NotTypingIndicatorState ||
                                  current is RecordingIndicateState ||
                                  current is NotRecordingState;
                            },
                            builder: (context, chatState) {
                              if (chatState is RecordingIndicateState) {
                                return Text(
                                  'Recording •••',
                                  style: getTitleSmall(
                                    context: context,
                                    fontweight: FontWeight.w500,
                                    fontSize: 13.5.sp,
                                  ),
                                );
                              }
                              if (chatState is TypeIndicatorState) {
                                return Text(
                                  'Typing •••',
                                  style: getTitleSmall(
                                    context: context,
                                    fontweight: FontWeight.w500,
                                    fontSize: 13.5.sp,
                                  ),
                                );
                              }
                              return BlocBuilder<ChatBloc, ChatState>(
                                buildWhen: (_, current) {
                                  return current is OnlineIndicationState;
                                },
                                builder: (context, chatState) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        chatState is OnlineIndicationState &&
                                                chatState.isOnline
                                            ? 'Online'
                                            : "Offline",
                                        style: getTitleSmall(
                                          context: context,
                                          fontweight: FontWeight.w500,
                                          fontSize: 13.5.sp,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      chatState is OnlineIndicationState &&
                                              chatState.isOnline
                                          ? CircleAvatar(
                                            radius: 3.r,
                                            backgroundColor: greenColor,
                                          )
                                          : CircleAvatar(
                                            radius: 3.r,
                                            backgroundColor: darkGrey,
                                          ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  buildWhen: (_, current) {
                    return current is SelectChatState;
                  },
                  builder: (context, chatState) {
                    return Row(
                      children: [
                        if (chatState is SelectChatState &&
                            chatState.selectedChats.isNotEmpty)
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const DeleteSelectedChatDialog();
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
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      onTap: () {
                                        //Deselecting all selected chats
                                        context.read<ChatBloc>().add(
                                          DeSelectChatEvent(),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.deselect),
                                              10.horizontalSpace,
                                              Text(
                                                'Deselect',
                                                style: getTitleSmall(
                                                  context: context,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) {
                                        return CallPage(
                                          displayName: widget.username,
                                          imageUrl: widget.profilePic,
                                          userId: widget.userId,
                                          currentUserId: currentUser.userId,
                                          currentUsername: currentUser.username,
                                          currentUserProfilePic:
                                              currentUser.profilePic,
                                          isSomeCalling: false,
                                          isAudioCall: false,
                                        );
                                      },
                                    ),
                                  );
                                  //Saving call history
                                  context.read<ChatBloc>().add(
                                    SendCallHistoryInfo(
                                      callType: "videoCall",

                                      callerId:
                                          context
                                              .read<CurrentUserProvider>()
                                              .currentUser
                                              .userId,
                                      calleeId: widget.userId,
                                    ),
                                  );
                                },
                                icon: Icon(
                                  CupertinoIcons.video_camera_solid,
                                  size: 38.h,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  //Saving history

                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) {
                                        return CallPage(
                                          displayName: widget.username,
                                          imageUrl: widget.profilePic,
                                          userId: widget.userId,
                                          currentUserId: currentUser.userId,
                                          currentUsername: currentUser.username,
                                          currentUserProfilePic:
                                              currentUser.profilePic,
                                          isSomeCalling: false,
                                          isAudioCall: true,
                                        );
                                      },
                                    ),
                                  );

                                  //Saving call history
                                  context.read<ChatBloc>().add(
                                    SendCallHistoryInfo(
                                      callType: "audioCall",
                                      callerId:
                                          context
                                              .read<CurrentUserProvider>()
                                              .currentUser
                                              .userId,
                                      calleeId: widget.userId,
                                    ),
                                  );
                                },
                                icon: const Icon(CupertinoIcons.phone_fill),
                              ),
                              _PopupMenuButton(
                                currentUserId: currentUser.userId,
                                oppositeUserId: widget.userId,
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            toolbarHeight: 80.h,
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
              Stack(
                children: [
                  BlocListener<UserBloc, UserState>(
                    listenWhen: (_, current) {
                      return (current is RemoveUserErrorState &&
                              current.userId == widget.userId) ||
                          (current is RemoveUserLoadingState &&
                              current.userId == widget.userId) ||
                          (current is RemoveUserSuccessState &&
                              current.userId == widget.userId);
                    },
                    listener: (context, userState) {
                      if (userState is RemoveUserErrorState &&
                          userState.userId == widget.userId) {
                        Navigator.of(context).pop();
                        showErrorMessage(context, "Something went wrong");
                      }

                      if (userState is RemoveUserLoadingState &&
                          userState.userId == widget.userId) {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return DialogLoadingIndicator(
                              loadingText: "Removing...",
                            );
                          },
                        );
                      }
                      if (userState is RemoveUserSuccessState &&
                          userState.userId == widget.userId) {
                        Navigator.of(context).pop();
                        showSuccessMessage(context, "Removed successfully");
                        context.read<ChatBloc>().add(
                          ClearAllChatsEvent(
                            currentUserId:
                                context
                                    .read<CurrentUserProvider>()
                                    .currentUser
                                    .userId,
                            oppositeUserId: widget.userId,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  BlocListener<ChatBloc, ChatState>(
                    listenWhen: (_, current) {
                      return (current is SocketMessagesState &&
                              current.chat.senderId == widget.userId) ||
                          (current is OnlineIndicationState &&
                              !current.isOnline) ||
                          (current is IndicateSeenState);
                    },
                    listener: (context, chatState) {
                      if (chatState is SocketMessagesState &&
                          chatState.chat.senderId == widget.userId) {
                        //Playing the sound when new messages come
                        context.read<ChatFunctionProvider>().turnOnChatSound();
                        //Also turning on the vibration when new messages come
                        context.read<ChatFunctionProvider>().turnOnVibrator();
                      }
                      if (chatState is SocketMessagesState) {
                        //Moving to last message
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!_scrollController.hasClients) {
                            return;
                          }
                          _scrollController.jumpTo(
                            _scrollController.position.maxScrollExtent,
                          );
                        });
                      }
                      if (chatState is SendTextMessageErrorState) {
                        showErrorMessage(context, 'Something went wrong');
                      }
                      if (chatState is OnlineIndicationState &&
                          widget.unreadMessageCount != 0) {
                        //Saving seen info when receiver sees the messages that sender sent
                        context.read<ChatBloc>().add(
                          SaveSeenInfoEvent(
                            senderId: widget.userId,
                            receiverId: currentUser.userId,
                          ),
                        );
                      }
                    },

                    child: const SizedBox(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 90.h),
                    child: Stack(
                      children: [
                        BlocBuilder<ChatBloc, ChatState>(
                          buildWhen: (_, current) {
                            return current is RetrieveChatSuccessState ||
                                current is RetrieveChatErrorState ||
                                current is RetrieveChatLoadingState ||
                                current is FetchTemporaryMessagesLoadingState;
                          },
                          builder: (context, chatState) {
                            if (chatState is RetrieveChatSuccessState) {
                              return GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                },
                                child: GroupedListView(
                                  physics: const BouncingScrollPhysics(),
                                  useStickyGroupSeparators: false,
                                  controller: _scrollController,
                                  floatingHeader: false,

                                  elements: chatState.chats,
                                  groupBy: (chat) {
                                    final DateTime? formattedDate =
                                        DateTime.tryParse(chat.date);
                                    return formattedDate != null
                                        ? DateTime(
                                          formattedDate.year,
                                          formattedDate.month,
                                          formattedDate.day,
                                        ).toString()
                                        : "";
                                  },
                                  itemBuilder: (context, chat) {
                                    return GestureDetector(
                                      onLongPress: () {
                                        //Seleting this chat
                                        context.read<ChatBloc>().add(
                                          SelectChatEvent(
                                            chatId: chat.chatId,
                                            isSeen: chat.isSeen,
                                            senderId: chat.senderId,
                                          ),
                                        );
                                      },
                                      child: BlocBuilder<ChatBloc, ChatState>(
                                        buildWhen: (_, current) {
                                          return current is SelectChatState;
                                        },
                                        builder: (context, chatStateFromthis) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  chatStateFromthis
                                                              is SelectChatState &&
                                                          chatStateFromthis
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: 20.w,
                                                right: 20.w,
                                                top: 5.h,
                                                bottom: 5.h,
                                              ),
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  minHeight: 40.h,
                                                  maxWidth: 250.w,
                                                  minWidth: 50,
                                                ),
                                                child: IntrinsicWidth(
                                                  child: IntrinsicHeight(
                                                    child: SwipeTo(
                                                      iconColor: lightGrey,
                                                      onLeftSwipe: (_) {
                                                        if (chat.type ==
                                                                "audioCall" ||
                                                            chat.type ==
                                                                "videoCall") {
                                                          return;
                                                        }
                                                        if (currentUser
                                                                .userId ==
                                                            chat.senderId) {
                                                          _replyNotifier
                                                              .value = ReplyMessageModel(
                                                            senderName:
                                                                currentUser
                                                                    .username,
                                                            parentMessageSenderId:
                                                                chat.senderId,

                                                            messageType:
                                                                chat.type ==
                                                                        "voiceUpload"
                                                                    ? "voice"
                                                                    : chat.type ==
                                                                        "audioUpload"
                                                                    ? "audio"
                                                                    : chat.type ==
                                                                        "imageUpload"
                                                                    ? "image"
                                                                    : chat.type,
                                                            audioDuration:
                                                                chat.audioDuration,
                                                            text: chat.message,
                                                            voiceDuration:
                                                                chat.voiceDuration,
                                                          );
                                                        }
                                                      },
                                                      onRightSwipe: (_) {
                                                        if (chat.type ==
                                                                "audioCall" ||
                                                            chat.type ==
                                                                "videoCall") {
                                                          return;
                                                        }
                                                        if (currentUser
                                                                .userId ==
                                                            chat.receiverId) {
                                                          _replyNotifier
                                                              .value = ReplyMessageModel(
                                                            senderName:
                                                                currentUser
                                                                    .username,
                                                            parentMessageSenderId:
                                                                chat.senderId,
                                                            messageType:
                                                                chat.type ==
                                                                        "voiceUpload"
                                                                    ? "voice"
                                                                    : chat.type ==
                                                                        "audioUpload"
                                                                    ? "audio"
                                                                    : chat.type ==
                                                                        "imageUpload"
                                                                    ? "image"
                                                                    : chat.type,
                                                            audioDuration:
                                                                chat.audioDuration,
                                                            text: chat.message,
                                                            voiceDuration:
                                                                chat.voiceDuration,
                                                          );
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            chat.senderId ==
                                                                    currentUser
                                                                        .userId
                                                                ? MainAxisAlignment
                                                                    .end
                                                                : MainAxisAlignment
                                                                    .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (chat.type ==
                                                                  "audioCall" ||
                                                              chat.type ==
                                                                  "videoCall")
                                                            CallHistoryContainer(
                                                              callType:
                                                                  chat.type,
                                                              isMe:
                                                                  context
                                                                      .read<
                                                                        CurrentUserProvider
                                                                      >()
                                                                      .currentUser
                                                                      .userId ==
                                                                  chat.senderId,
                                                              callTime:
                                                                  chat.date,
                                                            ),
                                                          if (chat.type ==
                                                              "text")
                                                            TextMessageTile(
                                                              message:
                                                                  chat.message ??
                                                                  "",
                                                              senderId:
                                                                  chat.senderId,
                                                              receiverId:
                                                                  chat.receiverId,
                                                              messageDate:
                                                                  chat.date,
                                                              isMe:
                                                                  chat.senderId ==
                                                                  currentUser
                                                                      .userId,
                                                              isSeen:
                                                                  chat.isSeen,
                                                              chatId:
                                                                  chat.chatId,
                                                              parentAudioDuration:
                                                                  chat.parentAudioDuration,
                                                              parentMessageSenderId:
                                                                  chat.parentMessageSenderId,
                                                              parentMessageType:
                                                                  chat.parentMessageType,
                                                              parentText:
                                                                  chat.parentText,
                                                              parentVoiceDuration:
                                                                  chat.parentVoiceDuration,
                                                              repliedMessage:
                                                                  chat.repliedMessage,
                                                              currentUserId:
                                                                  currentUser
                                                                      .userId,
                                                              oppositeUsername:
                                                                  widget
                                                                      .username,
                                                            ),
                                                          chat.type == "image"
                                                              ? ImageMessageTile(
                                                                isMe:
                                                                    chat.senderId ==
                                                                    currentUser
                                                                        .userId,
                                                                imagePath:
                                                                    chat.imagePath ??
                                                                    "",

                                                                chatId:
                                                                    chat.chatId,
                                                                imageText:
                                                                    chat.imageText ??
                                                                    "",
                                                                senderId:
                                                                    chat.senderId,
                                                                receiverId:
                                                                    chat.receiverId,
                                                                currentUserId:
                                                                    currentUser
                                                                        .userId,
                                                                receiverName:
                                                                    widget
                                                                        .username,
                                                                isSeen:
                                                                    chat.isSeen,
                                                                time: chat.date,
                                                                isDownloaded:
                                                                    chat.isDownloaded,
                                                                parentAudioDuration:
                                                                    chat.parentAudioDuration,
                                                                parentMessageSenderId:
                                                                    chat.parentMessageSenderId,
                                                                parentMessageType:
                                                                    chat.parentMessageType,
                                                                parentText:
                                                                    chat.parentText,
                                                                parentVoiceDuration:
                                                                    chat.parentVoiceDuration,
                                                                repliedMessage:
                                                                    chat.repliedMessage,
                                                              )
                                                              : chat.type ==
                                                                  "imageUpload"
                                                              ? ImageUploadingTile(
                                                                chatId:
                                                                    chat.chatId,
                                                                currentUserProfilePic:
                                                                    currentUser
                                                                        .profilePic,
                                                                currentUsername:
                                                                    currentUser
                                                                        .username,
                                                                currentUserId:
                                                                    currentUser
                                                                        .userId,
                                                                senderId:
                                                                    chat.senderId,
                                                                receiverId:
                                                                    chat.receiverId,
                                                                imagePath:
                                                                    chat.imagePath ??
                                                                    "",
                                                                imageText:
                                                                    chat.imageText ??
                                                                    "",
                                                                time: chat.date,
                                                                parentAudioDuration:
                                                                    chat.parentAudioDuration,
                                                                parentMessageSenderId:
                                                                    chat.parentMessageSenderId,
                                                                parentMessageType:
                                                                    chat.parentMessageType,
                                                                parentText:
                                                                    chat.parentText,
                                                                parentVoiceDuration:
                                                                    chat.parentVoiceDuration,
                                                                repliedMessage:
                                                                    chat.repliedMessage,
                                                                receiverName:
                                                                    widget
                                                                        .username,
                                                                currentUserBio:
                                                                    currentUser
                                                                        .bio,
                                                              )
                                                              : const SizedBox(),
                                                          if (chat.type ==
                                                              "audioUpload")
                                                            AudioUploadingTile(
                                                              audioPath:
                                                                  chat.audioPath,
                                                              currentUserProfilePic:
                                                                  currentUser
                                                                      .profilePic,
                                                              currentUsername:
                                                                  currentUser
                                                                      .username,
                                                              audioDuration:
                                                                  chat.audioDuration,
                                                              audioTitle:
                                                                  chat.audioTitle,
                                                              chatId:
                                                                  chat.chatId,
                                                              senderId:
                                                                  chat.senderId,
                                                              receiverId:
                                                                  chat.receiverId,
                                                              receiverName:
                                                                  widget
                                                                      .username,
                                                              currentUserId:
                                                                  currentUser
                                                                      .userId,
                                                              time: chat.date,
                                                              parentAudioDuration:
                                                                  chat.parentAudioDuration,
                                                              parentMessageSenderId:
                                                                  chat.parentMessageSenderId,
                                                              parentMessageType:
                                                                  chat.parentMessageType,
                                                              parentText:
                                                                  chat.parentText,
                                                              parentVoiceDuration:
                                                                  chat.parentVoiceDuration,
                                                              repliedMessage:
                                                                  chat.repliedMessage,
                                                              currentUserBio:
                                                                  currentUser
                                                                      .bio,
                                                            ),
                                                          if (chat.type ==
                                                              "audio")
                                                            AudioTile(
                                                              audioPath:
                                                                  chat.audioPath,
                                                              audioDuration:
                                                                  chat.audioDuration,
                                                              audioTitle:
                                                                  chat.audioTitle,
                                                              chatId:
                                                                  chat.chatId,
                                                              time: chat.date,
                                                              senderId:
                                                                  chat.senderId,
                                                              receiverId:
                                                                  chat.receiverId,
                                                              receiverName:
                                                                  widget
                                                                      .username,
                                                              currentUserId:
                                                                  currentUser
                                                                      .userId,
                                                              isMe:
                                                                  currentUser
                                                                      .userId ==
                                                                  chat.senderId,
                                                              isSeen:
                                                                  chat.isSeen,
                                                              isDownloaded:
                                                                  chat.isDownloaded,
                                                              parentAudioDuration:
                                                                  chat.parentAudioDuration,
                                                              parentMessageSenderId:
                                                                  chat.parentMessageSenderId,
                                                              parentMessageType:
                                                                  chat.parentMessageType,
                                                              parentText:
                                                                  chat.parentText,
                                                              parentVoiceDuration:
                                                                  chat.parentVoiceDuration,
                                                              repliedMessage:
                                                                  chat.repliedMessage,
                                                            ),

                                                          if (chat.type ==
                                                              "voiceUpload")
                                                            VoiceLoadingTile(
                                                              chatId:
                                                                  chat.chatId,
                                                              currentUserName:
                                                                  currentUser
                                                                      .username,
                                                              currentUserProfilePic:
                                                                  currentUser
                                                                      .profilePic,
                                                              currentUserId:
                                                                  currentUser
                                                                      .userId,
                                                              receiverId:
                                                                  widget.userId,
                                                              voiceDuration:
                                                                  chat.voiceDuration,
                                                              time: chat.date,
                                                              parentAudioDuration:
                                                                  chat.parentAudioDuration,
                                                              parentMessageSenderId:
                                                                  chat.parentMessageSenderId,
                                                              parentMessageType:
                                                                  chat.parentMessageType,
                                                              parentText:
                                                                  chat.parentText,
                                                              parentVoiceDuration:
                                                                  chat.parentVoiceDuration,
                                                              repliedMessage:
                                                                  chat.repliedMessage,
                                                              receiverName:
                                                                  widget
                                                                      .username,
                                                              currentUserBio:
                                                                  currentUser
                                                                      .bio,
                                                            ),
                                                          if (chat.type ==
                                                              "voice")
                                                            VoiceTile(
                                                              chatId:
                                                                  chat.chatId,
                                                              isMe:
                                                                  chat.senderId ==
                                                                  currentUser
                                                                      .userId,
                                                              receiverId:
                                                                  chat.receiverId,
                                                              senderId:
                                                                  chat.senderId,
                                                              voicePath:
                                                                  chat.voicePath,
                                                              voiceDuration:
                                                                  chat.voiceDuration,
                                                              currentUserId:
                                                                  currentUser
                                                                      .userId,
                                                              time: chat.date,
                                                              isDownloaded:
                                                                  chat.isDownloaded,
                                                              isSeen:
                                                                  chat.isSeen,
                                                              parentAudioDuration:
                                                                  chat.parentAudioDuration,
                                                              parentMessageSenderId:
                                                                  chat.parentMessageSenderId,
                                                              parentMessageType:
                                                                  chat.parentMessageType,
                                                              parentText:
                                                                  chat.parentText,
                                                              parentVoiceDuration:
                                                                  chat.parentVoiceDuration,
                                                              repliedMessage:
                                                                  chat.repliedMessage,
                                                              receiverName:
                                                                  widget
                                                                      .username,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  groupSeparatorBuilder: (date) {
                                    return date.isEmpty
                                        ? const SizedBox()
                                        : Padding(
                                          padding: EdgeInsets.only(
                                            top: 10.h,
                                            bottom: 10.h,
                                          ),
                                          child: GroupDateContainer(
                                            date: formatDate(date),
                                          ),
                                        );
                                  },
                                ),
                              );
                            }
                            if (chatState is RetrieveChatLoadingState ||
                                chatState
                                    is FetchTemporaryMessagesLoadingState) {
                              return const Center(
                                child: LoadingIndicator(color: blueColor),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20.w, bottom: 10.h),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: ValueListenableBuilder(
                              valueListenable: _isArrowButtonVisible,
                              builder: (context, isVisible, _) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child:
                                      isVisible
                                          ? ArrowButton(
                                            key: ValueKey<bool>(isVisible),
                                            onClicked: () {
                                              _scrollController.animateTo(
                                                _scrollController
                                                    .position
                                                    .maxScrollExtent,
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                curve: Curves.fastOutSlowIn,
                                              );
                                              _isArrowButtonVisible.value =
                                                  false;
                                            },
                                          )
                                          : SizedBox(
                                            key: ValueKey<bool>(isVisible),
                                          ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.w),
                          child: ValueListenableBuilder(
                            valueListenable: _replyNotifier,
                            builder: (context, reply, _) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child:
                                    reply != null
                                        ? ReplyContainer(
                                          parentMessageSenderName:
                                              reply.parentMessageSenderId ==
                                                      currentUser.userId
                                                  ? "You"
                                                  : reply.senderName,
                                          parentMessageType: reply.messageType,
                                          parentMessage: reply.text,
                                          parentMessageAudioDuration:
                                              reply.audioDuration,
                                          parentMessageVoiceDuration:
                                              reply.voiceDuration,
                                          key: ValueKey<bool>(true),
                                          onCloseButtonClicked: () {
                                            _replyNotifier.value = null;
                                          },
                                        )
                                        : const SizedBox.shrink(
                                          key: ValueKey<bool>(false),
                                        ),
                              );
                            },
                          ),
                        ),
                        10.verticalSpace,
                        MessageInput(
                          controller: _messageController,
                          scrollController: _scrollController,
                          onMessageSend: () {
                            if (_messageController.text.trim().isEmpty) {
                              return;
                            }
                            context.read<ChatBloc>().add(
                              SendMessageEvent(
                                senderName: currentUser.username,
                                senderProfilePic: currentUser.profilePic,
                                senderBio: currentUser.bio,
                                senderId: currentUser.userId,
                                receiverId: widget.userId,
                                message: _messageController.text.trim(),
                                type: "text",
                                date: DateTime.now().toString(),
                                imageText: "",
                                imageUrl: "",
                                voiceDuration: "",
                                voiceUrl: "",
                                parentMessageSenderId:
                                    _replyNotifier
                                        .value
                                        ?.parentMessageSenderId ??
                                    0,
                                parentMessageType:
                                    _replyNotifier.value?.messageType ?? "",
                                parentText: _replyNotifier.value?.text ?? "",
                                repliedMessage: _replyNotifier.value != null,
                              ),
                            );
                            _messageController.clear();
                            _replyNotifier.value = null;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent,
                              );
                            });
                          },
                          onTyping: () {
                            indicateTyping();
                          },
                          onImageSend: (image) {
                            context.read<ChatBloc>().add(
                              UploadFileEvent(
                                filePath: image.path,
                                text: _messageController.text.trim(),
                                type: 'image',
                                senderId: currentUser.userId,
                                receiverId: widget.userId,
                                audioDuration: "",
                                audioTitle: "",
                                voiceDuration: "",
                                parentAudioDuration:
                                    _replyNotifier.value?.audioDuration ?? "",
                                parentMessageSenderId:
                                    _replyNotifier
                                        .value
                                        ?.parentMessageSenderId ??
                                    0,
                                parentMessageType:
                                    _replyNotifier.value?.messageType ?? "",
                                parentText: _replyNotifier.value?.text ?? "",
                                parentVoiceDuration:
                                    _replyNotifier.value?.voiceDuration ?? "",
                                replyMessage: _replyNotifier.value != null,
                              ),
                            );
                            _messageController.clear();
                            _replyNotifier.value = null;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent,
                              );
                            });
                          },

                          onAudioSend: (audioFile, audioDuration, audioTitle) {
                            context.read<ChatBloc>().add(
                              UploadFileEvent(
                                filePath: audioFile.xFile.path,
                                text: "",
                                type: "audio",
                                receiverId: widget.userId,
                                senderId: currentUser.userId,
                                audioDuration: audioDuration,
                                audioTitle: audioTitle,
                                voiceDuration: "",
                                parentAudioDuration:
                                    _replyNotifier.value?.audioDuration ?? "",
                                parentMessageSenderId:
                                    _replyNotifier
                                        .value
                                        ?.parentMessageSenderId ??
                                    0,
                                parentMessageType:
                                    _replyNotifier.value?.messageType ?? "",
                                parentText: _replyNotifier.value?.text ?? "",
                                parentVoiceDuration:
                                    _replyNotifier.value?.voiceDuration ?? "",
                                replyMessage: _replyNotifier.value != null,
                              ),
                            );
                            _replyNotifier.value = null;
                            WidgetsBinding.instance.addPersistentFrameCallback((
                              _,
                            ) {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent,
                                );
                              }
                            });
                          },
                          onVoiceSend: (voicePath, voiceDuration) {
                            context.read<ChatBloc>().add(
                              UploadFileEvent(
                                filePath: voicePath,
                                text: "",
                                type: "voice",
                                receiverId: widget.userId,
                                senderId: currentUser.userId,
                                audioDuration: "",
                                audioTitle: "",
                                voiceDuration: voiceDuration,
                                parentAudioDuration:
                                    _replyNotifier.value?.audioDuration ?? "",
                                parentMessageSenderId:
                                    _replyNotifier
                                        .value
                                        ?.parentMessageSenderId ??
                                    0,
                                parentMessageType:
                                    _replyNotifier.value?.messageType ?? "",
                                parentText: _replyNotifier.value?.text ?? "",
                                parentVoiceDuration:
                                    _replyNotifier.value?.voiceDuration ?? "",
                                replyMessage: _replyNotifier.value != null,
                              ),
                            );
                            _replyNotifier.value = null;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent,
                              );
                            });
                          },
                          onRecordingStarted: () {
                            //Sending "Recording" indication to receiver when current user recording
                            context.read<ChatBloc>().add(
                              IndicateEvent(
                                indication: "Recording",
                                receiverId: widget.userId,
                                senderId: currentUser.userId,
                              ),
                            );
                          },

                          onRecordingCancelled: () {
                            //Sending "Not recording" to remove "Recording" indication
                            context.read<ChatBloc>().add(
                              IndicateEvent(
                                indication: "Not recording",
                                receiverId: widget.userId,
                                senderId: currentUser.userId,
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

class _PopupMenuButton extends StatelessWidget {
  final int currentUserId;
  final int oppositeUserId;
  const _PopupMenuButton({
    required this.currentUserId,
    required this.oppositeUserId,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      borderRadius: BorderRadius.circular(10),
      color: context.read<ThemeProvider>().isDark ? blackColor : whiteColor,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return DeleteChatsDialog(
                    currentUserId: currentUserId,
                    oppositeUserId: oppositeUserId,
                  );
                },
              );
            },
            child: Row(
              children: [
                const Icon(Icons.clear),
                10.horizontalSpace,
                Text('Clear chat', style: getTitleSmall(context: context)),
              ],
            ),
          ),

          PopupMenuItem(
            onTap: () async {
              await context.read<MuteProvider>().muteOrUnmuteUser(
                userId: oppositeUserId,
                currentUserId: currentUserId,
              );
            },
            child: Consumer<MuteProvider>(
              builder: (context, muteProv, _) {
                return Row(
                  children: [
                    muteProv.isMuted
                        ? const Icon(Icons.volume_up)
                        : const Icon(Icons.volume_off),
                    10.horizontalSpace,
                    Text(
                      muteProv.isMuted ? 'Unmute' : 'Mute',
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
                  return RemoveUserDialog(userId: oppositeUserId);
                },
              );
            },
            child: Row(
              children: [
                const Icon(CupertinoIcons.delete, color: redColor),
                10.horizontalSpace,
                Text('Remove', style: getTitleSmall(context: context)),
              ],
            ),
          ),
        ];
      },
    );
  }
}
