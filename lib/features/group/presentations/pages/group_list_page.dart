import 'package:chitchat/common/presentations/components/custom_refresh_indicator.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/components/shimmer_loading.dart';
import 'package:chitchat/common/presentations/pages/error_page.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/group/data/models/group_model.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:chitchat/features/group/presentations/blocs/group_chat/group_chat_bloc.dart';
import 'package:chitchat/features/group/presentations/components/groups_tile.dart';
import 'package:chitchat/features/group/presentations/pages/create_group_page.dart';
import 'package:chitchat/features/group/presentations/pages/no_groups_joined_page.dart';
import 'package:chitchat/features/group/presentations/pages/search_group_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  late final ValueNotifier<bool> showActionsInAppBarNotifier = ValueNotifier(
    false,
  );

  late final ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    //Fetching all groups
    context.read<GroupBloc>().add(
      FetchGroupsEvent(
        currentUserId: context.read<CurrentUserProvider>().currentUser.userId,
      ),
    );
    //For loading more groups
    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        context.read<GroupBloc>().add(
          LoadMoreGroupsEvent(
            currentUserId:
                context.read<CurrentUserProvider>().currentUser.userId,
          ),
        );
      }
    });
    //Connecting firestore
    context.read<GroupChatBloc>().add(
      ConnectWithFireStore(
        currentUserId: context.read<CurrentUserProvider>().currentUser.userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity.h,
      width: double.infinity.w,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(
            'Groups',
            style: getTitleLarge(context: context, fontweight: FontWeight.bold),
          ),
          actions: [
            ValueListenableBuilder(
              valueListenable: showActionsInAppBarNotifier,
              builder: (context, isVisible, child) {
                return isVisible ? child! : const SizedBox();
              },
              child: IconButton(
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const SearchGroupPage(),
                    pageTransitionAnimation: PageTransitionAnimation.slideUp,
                  );
                },
                icon: const Icon(Icons.search),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocListener<GroupChatBloc, GroupChatState>(
              listenWhen: (_, current) {
                return (current is GroupDetailsWithMessageState);
              },
              listener: (context, groupChatState) {
                if (groupChatState is GroupDetailsWithMessageState) {
                  context.read<GroupBloc>().add(
                    ChangeGroupOrderEvent(
                      lastMessage: groupChatState.lastTextMessage,
                      groupName: groupChatState.groupName,
                      groupBio: groupChatState.groupBio,
                      groupImageUrl: groupChatState.groupImageUrl,
                      lastMessageType: groupChatState.lastMessageType,
                      lastImageText: groupChatState.imageText,
                      unreadMessagesCount: groupChatState.unreadMessageCount,
                      lastMessageTime: groupChatState.lastMessageTime,
                      groupAdminUserId: groupChatState.groupAdminUserId,
                      groupId: groupChatState.groupId,
                      groupCreatedAt: groupChatState.groupCreatedDate,
                      membersLength: groupChatState.membersLength,
                    ),
                  );
                }
              },
              child: const SizedBox.shrink(),
            ),
            BlocListener<GroupBloc, GroupState>(
              listenWhen: (_, current) {
                return current is FetchGroupsErrorState ||
                    current is FetchGroupsSuccessState;
              },
              listener: (context, groupState) {
                if (groupState is FetchGroupsSuccessState &&
                    groupState.groups.isEmpty) {
                  showActionsInAppBarNotifier.value = false;
                } else if (groupState is FetchGroupsSuccessState) {
                  showActionsInAppBarNotifier.value = true;
                } else if (groupState is FetchGroupsLoadingState) {
                  showActionsInAppBarNotifier.value = false;
                }
              },
              child: const SizedBox(),
            ),
            Expanded(
              child: BlocBuilder<GroupBloc, GroupState>(
                buildWhen: (_, current) {
                  return current is FetchGroupsErrorState ||
                      current is FetchGroupsLoadingState ||
                      current is FetchGroupsSuccessState;
                },
                builder: (context, groupState) {
                  if (groupState is FetchGroupsLoadingState) {
                    return _GroupLoadingComp();
                  }
                  if (groupState is FetchGroupsErrorState) {
                    return Center(
                      child: ErrorPage(
                        showTryAgain: true,
                        onTryAgain: () {
                          //Re-trying to fetch groups
                          context.read<GroupBloc>().add(
                            FetchGroupsEvent(
                              currentUserId:
                                  context
                                      .read<CurrentUserProvider>()
                                      .currentUser
                                      .userId,
                            ),
                          );
                        },
                      ),
                    );
                  }
                  if (groupState is FetchGroupsSuccessState &&
                      groupState.groups.isEmpty) {
                    showActionsInAppBarNotifier.value = false;
                    return const Center(child: NoGroupsJoinedPage());
                  }
                  if (groupState is FetchGroupsSuccessState &&
                      groupState.groups.isNotEmpty) {
                    showActionsInAppBarNotifier.value = true;
                    return BlocBuilder<GroupBloc, GroupState>(
                      buildWhen: (_, current) {
                        return (current is LoadMoreGroupsErrorState) ||
                            (current is LoadMoreGroupsLoadingState) ||
                            (current is LoadMoreGroupsSuccessState);
                      },
                      builder: (context, innerState) {
                        return CustomRefreshIndicator(
                          onRefresh: () {
                            //Re-fetching groups
                            context.read<GroupBloc>().add(
                              FetchGroupsEvent(
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
                            itemCount:
                                groupState.groups.length +
                                (innerState is LoadMoreGroupsLoadingState
                                    ? 1
                                    : 0),
                            controller: _scrollController,
                            key: const PageStorageKey("groups_list"),
                            itemBuilder: (context, index) {
                              if (index == groupState.groups.length) {
                                return Center(
                                  child: LoadingIndicator(
                                    color: blueColor,
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                              final GroupModel group = groupState.groups[index];
                              return GroupsTile(
                                groupId: group.groupId,
                                groupName: group.groupName,
                                groupImageUrl: group.groupImageUrl,
                                groupAdminId: group.groupAdminUserId,
                                groupBio: group.groupBio,
                                createdAt: group.createdAt,
                                groupMembersCount: group.membersCount,
                                isMe: true,
                                isSeenLastMessage: false,
                                lastMessage: group.lastMessage,
                                lastMessageTime: group.lastMessageTime,
                                lastMessageType: group.lastMessageType,
                                lastImageText: group.lastImageText,
                                unreadMessagesCount: group.unreadMessagesCount,
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: BlocBuilder<GroupBloc, GroupState>(
          buildWhen: (_, current) {
            return (current is FetchGroupsErrorState) ||
                (current is FetchGroupsLoadingState) ||
                (current is FetchGroupsSuccessState);
          },
          builder: (context, groupState) {
            return groupState is FetchGroupsSuccessState &&
                    groupState.groups.isNotEmpty
                ? FloatingActionButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const CreateGroupPage(),
                      pageTransitionAnimation: PageTransitionAnimation.slideUp,
                    );
                  },
                  backgroundColor: blueColor,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: whiteColor),
                )
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _GroupLoadingComp extends StatelessWidget {
  const _GroupLoadingComp();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.only(left: 10.w, right: 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(radius: 40.r, backgroundColor: Colors.blue),
            10.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 25.h,
                  width: 180.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.amber,
                  ),
                ),
                5.verticalSpace,
                Container(
                  height: 20.h,
                  width: 230.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
