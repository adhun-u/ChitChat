import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/pages/error_page.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/group/data/models/group_model.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:chitchat/features/group/presentations/components/limit_reached_dialog.dart';
import 'package:chitchat/features/home/presentations/blocs/friends/friends_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GroupRequestsList extends StatefulWidget {
  final String groupId;
  final String groupImage;
  const GroupRequestsList({
    super.key,
    required this.groupId,
    required this.groupImage,
  });

  @override
  State<GroupRequestsList> createState() => _GroupRequestsListState();
}

class _GroupRequestsListState extends State<GroupRequestsList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    //Getting the requests without calling api
    context.read<GroupBloc>().add(
      FetchGroupRequestsEvent(groupId: widget.groupId, shouldCallApi: false),
    );

    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        //Loading more group requests
        context.read<GroupBloc>().add(
          LoadMoreGroupRequestsEvent(groupId: widget.groupId),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<GroupBloc, GroupState>(
      buildWhen: (_, current) {
        return current is FetchGroupRequestsErrorState ||
            current is FetchGroupRequestsLoadingState ||
            current is FetchGroupRequestsSuccessState;
      },
      builder: (context, groupState) {
        if (groupState is FetchGroupRequestsErrorState) {
          return Center(child: ErrorPage());
        }
        if (groupState is FetchRequestedUsersLoadingState) {
          return Center(child: LoadingIndicator(color: blueColor));
        }

        if (groupState is FetchGroupRequestsSuccessState) {
          return groupState.requests.isEmpty
              ? Center(child: _NoRequestedUsers())
              : BlocBuilder<GroupBloc, GroupState>(
                buildWhen: (_, current) {
                  return (current is LoadMoreGroupRequestsSuccessState) ||
                      (current is LoadMoreGroupRequestsErrorState) ||
                      (current is LoadMoreGroupRequestsLoadingState);
                },
                builder: (context, innerGroupState) {
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    key: const PageStorageKey("group_requests"),
                    itemCount:
                        groupState.requests.length +
                        (innerGroupState is LoadMoreGroupRequestsLoadingState
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index == groupState.requests.length) {
                        return Center(
                          child: LoadingIndicator(
                            color: blueColor,
                            strokeWidth: 2,
                          ),
                        );
                      }
                      final GroupRequestUserModel requestedUser =
                          groupState.requests[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 5.w,
                          right: 5.w,
                          top: 10.h,
                        ),
                        child: Container(
                          height: 90.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 5.w, right: 5.w),
                            child: Row(
                              children: [
                                Consumer<ThemeProvider>(
                                  builder: (context, theme, _) {
                                    return CircleAvatar(
                                      radius: 35.r,
                                      backgroundColor:
                                          theme.isDark ? greyColor : darkWhite,
                                      backgroundImage:
                                          requestedUser.imageUrl.isNotEmpty
                                              ? NetworkImage(
                                                requestedUser.imageUrl,
                                              )
                                              : null,
                                    );
                                  },
                                ),
                                10.horizontalSpace,
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        requestedUser.username,
                                        style: getTitleSmall(
                                          context: context,
                                          fontweight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (requestedUser.userBio.isNotEmpty)
                                        Text(
                                          requestedUser.userBio,
                                          style: getBodySmall(
                                            context: context,
                                            fontweight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    BlocListener<GroupBloc, GroupState>(
                                      listenWhen: (_, current) {
                                        return current
                                                    is AcceptGroupRequestErrorState &&
                                                current.userId ==
                                                    requestedUser.userId ||
                                            current
                                                    is AcceptGroupRequestSuccessState &&
                                                current.userId ==
                                                    requestedUser.userId;
                                      },
                                      listener: (context, groupState) {
                                        if (groupState
                                            is AcceptGroupRequestSuccessState) {
                                          showSuccessMessage(
                                            context,
                                            "Request accepted",
                                          );
                                        }
                                        if (groupState
                                            is AcceptGroupRequestErrorState) {
                                          showErrorMessage(
                                            context,
                                            "Something went wrong",
                                          );
                                        }
                                      },
                                      child: const SizedBox(),
                                    ),
                                    BlocBuilder<GroupBloc, GroupState>(
                                      buildWhen: (_, current) {
                                        return current
                                                    is AcceptGroupRequestErrorState &&
                                                current.userId ==
                                                    requestedUser.userId ||
                                            current
                                                    is AcceptGroupRequestLoadingState &&
                                                current.userId ==
                                                    requestedUser.userId ||
                                            current
                                                    is AcceptGroupRequestSuccessState &&
                                                current.userId ==
                                                    requestedUser.userId;
                                      },
                                      builder: (context, state) {
                                        return _BuildCupertinoButton(
                                          text: "Accept",
                                          buttonColor: blueColor,
                                          textColor: whiteColor,
                                          showLoading:
                                              groupState
                                                  is AcceptGroupRequestLoadingState,
                                          onTap: () {
                                            //To avoid unnecessary clicks
                                            if (groupState
                                                is AcceptGroupRequestLoadingState) {
                                              return;
                                            }
                                            //To show group members limit
                                            if (context
                                                    .read<GroupBloc>()
                                                    .currentGroupMembersCount ==
                                                100) {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return GroupMemberLimitReadDialog();
                                                },
                                              );
                                              return;
                                            }
                                            //Accepting the group request
                                            context.read<GroupBloc>().add(
                                              AcceptGroupRequestEvent(
                                                groupId: widget.groupId,
                                                userId: requestedUser.userId,
                                                groupName:
                                                    requestedUser.groupName,
                                                groupImage: widget.groupImage,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    10.horizontalSpace,
                                    BlocBuilder<GroupBloc, GroupState>(
                                      buildWhen: (_, current) {
                                        return current
                                                    is DeclineGroupRequestErrorState &&
                                                current.userId ==
                                                    requestedUser.userId ||
                                            current
                                                    is DeclineGroupRequestLoadingState &&
                                                current.userId ==
                                                    requestedUser.userId ||
                                            current
                                                    is DeclineGroupRequestSuccessState &&
                                                current.userId ==
                                                    requestedUser.userId;
                                      },
                                      builder: (context, groupState) {
                                        return Consumer<ThemeProvider>(
                                          builder: (context, theme, _) {
                                            return _BuildCupertinoButton(
                                              text: "Decline",
                                              buttonColor:
                                                  theme.isDark
                                                      ? darkGrey
                                                      : darkWhite2,
                                              textColor:
                                                  theme.isDark
                                                      ? darkWhite2
                                                      : lightGrey,
                                              showLoading:
                                                  groupState
                                                      is DeclineGroupRequestLoadingState,
                                              onTap: () {
                                                //To avoid unnecessary clicks
                                                if (groupState
                                                    is AcceptGroupRequestLoadingState) {
                                                  return;
                                                }
                                                //Declining the group request
                                                context.read<GroupBloc>().add(
                                                  DeclineGroupRequestEvent(
                                                    groupId:
                                                        requestedUser.groupId,
                                                    userId:
                                                        requestedUser.userId,
                                                  ),
                                                );
                                              },
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
                      );
                    },
                    separatorBuilder: (_, _) {
                      return Consumer<ThemeProvider>(
                        builder: (context, theme, _) {
                          return Divider(
                            color: theme.isDark ? greyColor : lightGrey,
                          );
                        },
                      );
                    },
                  );
                },
              );
        }
        return const SizedBox();
      },
    );
  }
}

class _BuildCupertinoButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color textColor;
  final Function() onTap;
  final bool showLoading;

  const _BuildCupertinoButton({
    required this.text,
    required this.buttonColor,
    required this.textColor,
    required this.showLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.h,
      width: 90.w,
      child: CupertinoButton(
        onPressed: () {
          onTap();
        },
        sizeStyle: CupertinoButtonSize.small,
        color: buttonColor,
        borderRadius: BorderRadius.circular(8),
        child:
            !showLoading
                ? Text(
                  text,
                  style: getBodySmall(
                    context: context,
                    fontweight: FontWeight.bold,
                    color: textColor,
                  ),
                )
                : SizedBox(
                  height: 25.h,
                  width: 25.h,
                  child: LoadingIndicator(color: whiteColor),
                ),
      ),
    );
  }
}

class _NoRequestedUsers extends StatelessWidget {
  const _NoRequestedUsers();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Icon(CupertinoIcons.clock, color: darkGrey, size: 80.h),
        Text(
          'No requests',
          style: getTitleMedium(
            context: context,
            fontweight: FontWeight.bold,
            color: darkGrey,
            fontSize: 17.sp,
          ),
        ),
      ],
    );
  }
}
