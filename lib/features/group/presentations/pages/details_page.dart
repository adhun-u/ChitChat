import 'dart:io';

import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/presentations/components/audio_play_prev.dart';
import 'package:chitchat/common/presentations/components/custom_refresh_indicator.dart';
import 'package:chitchat/common/presentations/pages/show_image_prev.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/group/domain/entities/chat_storage/group_chat_storage_model.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:chitchat/features/group/presentations/pages/add_member_page.dart';
import 'package:chitchat/features/group/presentations/pages/added_user_list.dart';
import 'package:chitchat/features/group/presentations/pages/all_media_prev.dart';
import 'package:chitchat/features/group/presentations/pages/edit_group_page.dart';
import 'package:chitchat/features/group/presentations/pages/requests_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupName;
  final String groupImageUrl;
  final String groupId;
  final String createdAt;
  final int groupAdminId;
  final String groupBio;
  final int groupMembersCount;
  const GroupDetailsPage({
    super.key,
    required this.groupName,
    required this.groupImageUrl,
    required this.groupId,
    required this.createdAt,
    required this.groupAdminId,
    required this.groupBio,
    required this.groupMembersCount,
  });

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage>
    with SingleTickerProviderStateMixin {
  late final CurrentUserModel _currentUser;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    //Getting current user
    _currentUser = context.read<CurrentUserProvider>().currentUser;
    //Tab controller
    _tabController = TabController(
      length: _currentUser.userId == widget.groupAdminId ? 2 : 1,
      vsync: this,
    );

    //Fetching group members
    context.read<GroupBloc>().add(
      FetchGroupAddedUsersEvent(
        groupId: widget.groupId,
        currentUseId: _currentUser.userId,
        shouldCallApi: true,
      ),
    );
    //Fetching requests of this group
    context.read<GroupBloc>().add(
      FetchGroupRequestsEvent(groupId: widget.groupId, shouldCallApi: true),
    );

    //Fetching group media items
    context.read<GroupBloc>().add(
      FetchGroupMediaItems(groupId: widget.groupId, limit: 6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        //Removing all group lists
        context.read<GroupBloc>().add(ClearGroupListEvent());
      },
      child: SizedBox(
        height: double.infinity.h,
        width: double.infinity.w,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            titleSpacing: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Group details',
              style: getTitleMedium(
                context: context,
                fontweight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: CustomRefreshIndicator(
              onRefresh: () {
                //Re-fetching group members
                context.read<GroupBloc>().add(
                  FetchGroupAddedUsersEvent(
                    groupId: widget.groupId,
                    currentUseId: _currentUser.userId,
                    shouldCallApi: true,
                  ),
                );
                //Re-fetching requests of this group
                context.read<GroupBloc>().add(
                  FetchGroupRequestsEvent(
                    groupId: widget.groupId,
                    shouldCallApi: true,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 290.h),
                    child: SizedBox(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.w, right: 10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: "group_details_hero",
                                  child: Consumer<ThemeProvider>(
                                    builder: (context, theme, _) {
                                      return CircleAvatar(
                                        radius: 45.r,
                                        backgroundColor:
                                            theme.isDark
                                                ? greyColor
                                                : darkWhite,
                                        backgroundImage:
                                            widget.groupImageUrl.isNotEmpty
                                                ? NetworkImage(
                                                  widget.groupImageUrl,
                                                )
                                                : null,
                                        child:
                                            widget.groupImageUrl.isEmpty
                                                ? Icon(
                                                  Icons.group,
                                                  size: 40.h,
                                                  color:
                                                      context
                                                              .read<
                                                                ThemeProvider
                                                              >()
                                                              .isDark
                                                          ? darkWhite
                                                          : greyColor,
                                                )
                                                : null,
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: 65.h,
                                          maxWidth: 300.w,
                                        ),
                                        child: Text(
                                          widget.groupName,
                                          style: getTitleLarge(
                                            context: context,
                                            fontweight: FontWeight.bold,
                                            fontSize: 22.sp,
                                          ),
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),

                                      BlocBuilder<GroupBloc, GroupState>(
                                        buildWhen: (_, current) {
                                          return current
                                              is FetchGroupMembersCountSuccessState;
                                        },
                                        builder: (context, groupState) {
                                          return Text(
                                            "${groupState is FetchGroupMembersCountSuccessState ? groupState.membersCount : widget.groupMembersCount} Members • Created ${formatDate(widget.createdAt)}",
                                            style: getTitleSmall(
                                              context: context,
                                              fontweight: FontWeight.w400,
                                              fontSize: 13.sp,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            5.verticalSpace,
                            Padding(
                              padding: EdgeInsets.only(left: 10.w, right: 10.w),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 90.h),
                                child: Text(
                                  widget.groupBio,
                                  style: getTitleSmall(
                                    context: context,
                                    fontweight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            if (widget.groupAdminId == _currentUser.userId)
                              20.verticalSpace,
                            if (widget.groupAdminId == _currentUser.userId)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _CustomCupertinoButton(
                                    icon: Icons.group_add,
                                    text: "Add Member",
                                    buttonColor: blueColor,
                                    textColor: whiteColor,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) {
                                            return AddMemberPage(
                                              groupId: widget.groupId,
                                              groupName: widget.groupName,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  10.horizontalSpace,
                                  Consumer<ThemeProvider>(
                                    builder: (context, theme, _) {
                                      return _CustomCupertinoButton(
                                        icon: Icons.edit,
                                        text: "Edit Group",
                                        buttonColor:
                                            theme.isDark
                                                ? greyColor
                                                : darkWhite,
                                        textColor:
                                            theme.isDark
                                                ? darkWhite
                                                : greyColor,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (context) {
                                                return EditGroupPage(
                                                  groupId: widget.groupId,
                                                  groupImageUrl:
                                                      widget.groupImageUrl,
                                                  groupBio: widget.groupBio,
                                                  groupName: widget.groupName,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  10.verticalSpace,
                  Divider(
                    endIndent: 10.w,
                    indent: 10.w,
                    color:
                        context.read<ThemeProvider>().isDark
                            ? greyColor
                            : darkWhite,
                  ),

                  _BuildMediaSection(groupId: widget.groupId),
                  10.verticalSpace,
                  SizedBox(
                    height: 50.h,
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorColor: blueColor,
                      indicatorAnimation: TabIndicatorAnimation.linear,
                      overlayColor: WidgetStatePropertyAll(Colors.transparent),
                      labelStyle: getBodySmall(
                        context: context,
                        fontweight: FontWeight.bold,
                        color: blueColor,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6.w,
                            children: [
                              const Icon(Icons.group_outlined),
                              Text(
                                'Members',
                                style: getTitleSmall(
                                  context: context,
                                  fontweight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_currentUser.userId == widget.groupAdminId)
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 6.w,
                              children: [
                                const Icon(CupertinoIcons.clock),
                                Text(
                                  'Requests',
                                  style: getTitleSmall(
                                    context: context,
                                    fontweight: FontWeight.bold,
                                  ),
                                ),
                                BlocBuilder<GroupBloc, GroupState>(
                                  buildWhen: (_, current) {
                                    return current
                                            is FetchGroupRequestsErrorState ||
                                        current
                                            is FetchGroupRequestsLoadingState ||
                                        current
                                            is FetchGroupRequestsSuccessState;
                                  },
                                  builder: (context, groupState) {
                                    return groupState
                                                is FetchGroupRequestsSuccessState &&
                                            groupState.requests.isNotEmpty
                                        ? CircleAvatar(
                                          backgroundColor: redColor,
                                          radius: 13.r,
                                          child: Text(
                                            groupState.requests.length <= 99
                                                ? groupState.requests.length
                                                    .toString()
                                                : "99+",
                                            style: getBodySmall(
                                              context: context,
                                              color: whiteColor,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                        )
                                        : const SizedBox();
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 780.h),
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        GroupAddedUserList(
                          groupId: widget.groupId,
                          adminId: widget.groupAdminId,
                          currentUserId: _currentUser.userId,
                        ),
                        if (_currentUser.userId == widget.groupAdminId)
                          GroupRequestsList(
                            groupId: widget.groupId,

                            groupImage: widget.groupImageUrl,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomCupertinoButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color buttonColor;
  final Color textColor;
  final Function() onTap;
  const _CustomCupertinoButton({
    required this.icon,
    required this.text,
    required this.buttonColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      width: 200.w,
      child: CupertinoButton(
        onPressed: () {
          onTap();
        },
        color: buttonColor,
        borderRadius: BorderRadius.circular(30),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(icon, color: textColor),
              10.horizontalSpace,
              Text(
                text,
                style: getTitleSmall(
                  context: context,
                  fontweight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildMediaSection extends StatelessWidget {
  final String groupId;

  const _BuildMediaSection({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Media',
                style: getTitleMedium(
                  context: context,
                  fontweight: FontWeight.bold,
                  fontSize: 17.sp,
                ),
              ),
              BlocBuilder<GroupBloc, GroupState>(
                buildWhen: (_, current) {
                  return current is GroupMediaItemsSuccessState;
                },
                builder: (context, groupState) {
                  return groupState is GroupMediaItemsSuccessState &&
                          groupState.mediaItems.isNotEmpty
                      ? CupertinoButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) {
                                return AllMediaPrev(groupId: groupId);
                              },
                            ),
                          );
                        },
                        sizeStyle: CupertinoButtonSize.small,
                        child: Text(
                          'View all',
                          style: getTitleSmall(
                            context: context,
                            fontweight: FontWeight.bold,
                            color: blueColor,
                          ),
                        ),
                      )
                      : const SizedBox();
                },
              ),
            ],
          ),
        ),
        BlocBuilder<GroupBloc, GroupState>(
          buildWhen: (_, current) {
            return current is GroupMediaItemsSuccessState;
          },
          builder: (context, groupState) {
            if (groupState is GroupMediaItemsSuccessState &&
                groupState.mediaItems.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.only(left: 5.w, right: 10.w),
                child: SizedBox(
                  height: 250.h,
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.8 / 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.w,
                    ),
                    itemCount: groupState.mediaItems.length,
                    itemBuilder: (context, index) {
                      final GroupChatStorageModel media =
                          groupState.mediaItems[index];
                      return GestureDetector(
                        onTap: () {
                          if (media.messageType == "audio") {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) {
                                  return AudioPlayPrev(
                                    audioId: media.chatId,
                                    audioPath: media.audioPath,
                                    audioTitle: media.audioTitle,
                                  );
                                },
                              ),
                            );
                          }
                          if (media.messageType == "image") {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) {
                                  return ShowImagePrev(
                                    imagePath: media.imagePath,
                                    username: "",
                                    sentImageTime: formatDate(media.time),
                                    heroTag: media.chatId,
                                  );
                                },
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                context.read<ThemeProvider>().isDark
                                    ? greyColor
                                    : darkWhite,
                            borderRadius: BorderRadius.circular(10),
                            image:
                                media.messageType == "image"
                                    ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(File(media.imagePath)),
                                    )
                                    : null,
                          ),

                          child:
                              media.messageType == "audio"
                                  ? Icon(
                                    Icons.headphones,
                                    size: 35.h,
                                    color: blueColor,
                                  )
                                  : null,
                        ),
                      );
                    },
                  ),
                ),
              );
            }
            return SizedBox(
              height: 250.h,
              child: Column(
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
            );
          },
        ),
      ],
    );
  }
}
