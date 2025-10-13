import 'package:chitchat/common/presentations/components/custom_refresh_indicator.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/pages/error_page.dart';
import 'package:chitchat/common/presentations/providers/chat_function_provider.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/home/data/models/added_user_model.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:chitchat/features/home/presentations/blocs/user/user_bloc.dart';
import 'package:chitchat/features/home/presentations/components/added_user_loading.dart';
import 'package:chitchat/features/home/presentations/components/list_user_tile.dart';
import 'package:chitchat/features/home/presentations/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late final ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      //Loading more friends
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        context.read<UserBloc>().add(
          LoadMoreFriendsWithLastMessageEvent(
            currentUserId:
                context.read<CurrentUserProvider>().currentUser.userId,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        10.verticalSpace,
        BlocListener<ChatBloc, ChatState>(
          listenWhen: (_, current) {
            return (current is UnreadMessageCountState &&
                    current.unreadMessagesCount != 0 &&
                    current.senderId !=
                        context
                            .read<CurrentUserProvider>()
                            .currentUser
                            .userId) ||
                (current is SocketMessagesState);
          },
          listener: (context, chatState) {
            if (chatState is SocketMessagesState) {
              final int currentUserId =
                  context.read<CurrentUserProvider>().currentUser.userId;

              if (currentUserId == chatState.chat.senderId) {
                //Changing the order from sender pespective and if the sender is current user
                context.read<UserBloc>().add(
                  ChangePositionOfUserEvent(
                    userId: chatState.chat.receiverId,
                    lastTextMessage: chatState.chat.textMessage ?? "",
                    lastAudioDuration: chatState.chat.audioDuration,
                    lastImageText: chatState.chat.imageText ?? "",
                    lastMessageType: chatState.chat.type,
                    lastVoiceDuration: chatState.chat.voiceDuration ?? "",
                    lastMessageTime: chatState.chat.time,
                  ),
                );

                //Changing the last message
                context.read<UserBloc>().add(
                  ChangeLastMessageTimeEvent(
                    lastMessageTime: chatState.chat.time,
                    userId: chatState.chat.receiverId,
                  ),
                );
              } else {
                int unreadMessageCount =
                    context
                        .read<ChatBloc>()
                        .unreadMessagesCounts["${context.read<CurrentUserProvider>().currentUser.userId}${chatState.chat.senderId}"]
                        ?.unreadMessagesCount ??
                    0;

                unreadMessageCount = unreadMessageCount + 1;
                context.read<UserBloc>().add(
                  ChangeUsersOrderEvent(
                    username: chatState.chat.senderName,
                    lastMessage: chatState.chat.textMessage ?? "",
                    userbio: chatState.chat.senderBio,
                    profilePic: chatState.chat.senderProfilePic,
                    messageType: chatState.chat.type,
                    time: chatState.chat.time,
                    isMe: false,
                    userId: chatState.chat.senderId,
                    unreadMessageCount: unreadMessageCount,
                  ),
                );
              }
            }
            if (chatState is UnreadMessageCountState &&
                chatState.senderId !=
                    context.read<CurrentUserProvider>().currentUser.userId) {
              //Turning vibrator on to indicate when new messages come
              context.read<ChatFunctionProvider>().turnOnVibrator();
              //Playing a sound to indicate when new messages come
              context.read<ChatFunctionProvider>().turnOnChatSound();
            }
          },
          child: const SizedBox(),
        ),

        BlocBuilder<UserBloc, UserState>(
          buildWhen: (_, current) {
            return current is FetchAddedUserWithLastMessageErrorState ||
                current is FetchAddedUserWithLastMessageLoadingState ||
                current is FetchAddedUserWithLastMessageSuccessState;
          },
          builder: (context, userState) {
            if (userState is FetchAddedUserWithLastMessageLoadingState) {
              return SizedBox(height: 660.h, child: const AddedUserLoading());
            }
            if (userState is FetchAddedUserWithLastMessageErrorState) {
              return const Expanded(child: ErrorPage());
            }
            if (userState is FetchAddedUserWithLastMessageSuccessState &&
                userState.addedUsers.isEmpty) {
              return Expanded(child: const _EmptyUserPage());
            }
            if (userState is FetchAddedUserWithLastMessageSuccessState) {
              return Expanded(
                child: BlocBuilder<UserBloc, UserState>(
                  buildWhen: (previous, current) {
                    return (current
                            is LoadMoreFriendsWithLastMessageErrorState) ||
                        (current
                            is LoadMoreFriendsWithLastMessageLoadingState) ||
                        (current is LoadMoreFriendsWithLastMessageSuccessState);
                  },
                  builder: (context, innerState) {
                    return CustomRefreshIndicator(
                      onRefresh: () {
                        //Re-fetching current user's friends
                        context.read<UserBloc>().add(
                          FetchAddedUsersWithLastMessageEvent(
                            currentUserId:
                                context
                                    .read<CurrentUserProvider>()
                                    .currentUser
                                    .userId,
                          ),
                        );
                      },
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        controller: _scrollController,
                        itemCount:
                            userState.addedUsers.length +
                            (innerState
                                    is LoadMoreFriendsWithLastMessageLoadingState
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index == userState.addedUsers.length) {
                            return Center(
                              child: LoadingIndicator(
                                color: blueColor,
                                strokeWidth: 2,
                              ),
                            );
                          }
                          final AddedUserWithLastMessageModel user =
                              userState.addedUsers[index];
                          return Consumer<ThemeProvider>(
                            builder: (context, theme, child) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(10),
                                highlightColor: Colors.transparent,
                                splashColor:
                                    theme.isDark ? greyColor : darkWhite2,
                                onTap: () {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: ChatPage(
                                      profilePic: user.profilePic,
                                      userId: user.userId,
                                      username: user.username,
                                      unreadMessageCount:
                                          user.unreadMessageCount,
                                      userbio: user.userbio,
                                    ),
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.slideUp,
                                  );
                                },
                                child: child,
                              );
                            },
                            child: ListUserTile(
                              userId: user.userId,
                              username: user.username,
                              profilePic: user.profilePic,
                              lastMessage: user.lastMessage,
                              lastTime: user.lastTime,
                              unreadMessageCount: user.unreadMessageCount,
                              messageType: user.messageType,
                              isSeen: user.isSeen,
                              isMe: user.isMe,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }
}

class _EmptyUserPage extends StatelessWidget {
  const _EmptyUserPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        50.verticalSpace,
        Center(
          child: SizedBox(
            height: 200.h,
            child: Image.asset(emptyUsersBackground, fit: BoxFit.cover),
          ),
        ),
        Text(
          "No Conversations Yet",
          style: getTitleMedium(context: context, fontweight: FontWeight.bold),
        ),
        Padding(
          padding: EdgeInsets.only(left: 50.w, right: 50.w),
          child: Text(
            "You haven't started any conversations. Connect with friends to begin chatting!",
            style: getBodySmall(
              context: context,
              fontweight: FontWeight.w400,
              color: lightGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
