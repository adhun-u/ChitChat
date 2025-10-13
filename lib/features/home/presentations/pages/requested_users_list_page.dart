import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/common/presentations/components/custom_refresh_indicator.dart';
import 'package:chitchat/common/presentations/pages/error_page.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/home/data/models/request_user_model.dart';
import 'package:chitchat/features/home/presentations/blocs/friends/friends_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RequestedUsersListPage extends StatefulWidget {
  const RequestedUsersListPage({super.key});

  @override
  State<RequestedUsersListPage> createState() => _RequestedUsersListPageState();
}

class _RequestedUsersListPageState extends State<RequestedUsersListPage> {
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (context.mounted) {
      //Fetching requested user data
      context.read<FriendsBloc>().add(
        FetchRequestedUsersEvent(shouldCallApi: true),
      );
    }
    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        //Loading more requested users data
        if (context.mounted) {
          context.read<FriendsBloc>().add(LoadMoreRequestedUsersEvent());
        }
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
    return BlocListener<FriendsBloc, FriendsState>(
      listenWhen: (_, current) {
        return (current is LoadMoreRequestedUsersErrorState) ||
            (current is LoadMoreRequestedUsersSuccessState);
      },
      listener: (context, friendsState) {
        if (friendsState is LoadMoreRequestedUsersErrorState) {
          if (context.mounted) {
            showErrorMessage(context, "Something went wrong");
          }
        }
      },
      child: Scaffold(
        body: CustomRefreshIndicator(
          onRefresh: () async {
            //Re-fetching the requested users
            if (context.mounted) {
              context.read<FriendsBloc>().add(
                FetchRequestedUsersEvent(shouldCallApi: true),
              );
            }
          },
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<FriendsBloc, FriendsState>(
                  buildWhen: (_, current) {
                    return current is FetchRequestedUsersErrorState ||
                        current is FetchRequestedUsersLoadingState ||
                        current is FetchRequestedUsersSuccessState;
                  },
                  builder: (context, friendsState) {
                    if (friendsState is FetchRequestedUsersSuccessState &&
                        friendsState.requestedUsers.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Icon(
                              CupertinoIcons.clock,
                              size: 90.h,
                              color: lightGrey,
                            ),
                          ),
                          5.verticalSpace,
                          Text(
                            'No one requested',
                            style: getTitleMedium(
                              context: context,
                              fontweight: FontWeight.w500,
                              color: lightGrey,
                            ),
                          ),
                        ],
                      );
                    }
                    if (friendsState is FetchRequestedUsersErrorState) {
                      return Expanded(child: ErrorPage());
                    }
                    if (friendsState is FetchRequestedUsersLoadingState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: LoadingIndicator(color: blueColor)),
                        ],
                      );
                    }
                    if (friendsState is FetchRequestedUsersSuccessState) {
                      return CustomRefreshIndicator(
                        onRefresh: () {
                          if (context.mounted) {
                            //Re-fetching the requested users
                            context.read<FriendsBloc>().add(
                              FetchRequestedUsersEvent(shouldCallApi: true),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: BlocBuilder<FriendsBloc, FriendsState>(
                            buildWhen: (_, current) {
                              return (current
                                      is LoadMoreRequestedUsersLoadingState) ||
                                  (current
                                      is LoadMoreRequestedUsersErrorState) ||
                                  (current
                                      is LoadMoreRequestedUsersSuccessState);
                            },
                            builder: (context, innerFriendState) {
                              return ListView.separated(
                                controller: _scrollController,
                                key: const PageStorageKey("requested users"),
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                itemCount:
                                    friendsState.requestedUsers.length +
                                    (innerFriendState
                                            is LoadMoreRequestedUsersLoadingState
                                        ? 1
                                        : 0),
                                itemBuilder: (context, index) {
                                  if (index ==
                                      friendsState.requestedUsers.length) {
                                    return Center(
                                      child: LoadingIndicator(
                                        color: blueColor,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  }
                                  final RequestUserModel user =
                                      friendsState.requestedUsers[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: 10.w,
                                      right: 10.w,
                                    ),
                                    child: _RequestedUserTile(
                                      id: user.id,
                                      profilePic: user.requestedUserProfilePic,
                                      requestedUserId: user.requestedUserId,
                                      requestedUserbio: user.requestedUserbio,
                                      requestedUsername: user.requestedUsername,
                                      requesteDate: user.requestedDate,
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 10.h);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestedUserTile extends StatelessWidget {
  final String id;
  final int requestedUserId;
  final String requestedUsername;
  final String requestedUserbio;
  final String profilePic;
  final String requesteDate;
  const _RequestedUserTile({
    required this.id,
    required this.profilePic,
    required this.requestedUserId,
    required this.requestedUserbio,
    required this.requestedUsername,
    required this.requesteDate,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 250.h),
      child: Consumer<ThemeProvider>(
        builder: (context, theme, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.isDark ? greyColor : darkWhite,
            ),
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocListener<FriendsBloc, FriendsState>(
              listenWhen: (_, current) {
                return current is RequestAcceptErrorState ||
                    current is RequestAcceptSuccessState &&
                        current.acceptRequestModel.requestedUserId ==
                            requestedUserId ||
                    current is DeclineErrorState &&
                        current.userId == requestedUserId ||
                    current is DeclineSuccessState &&
                        current.userId == requestedUserId;
              },
              listener: (_, friendsState) {
                if (friendsState is RequestAcceptErrorState) {
                  //Showing error message
                  showErrorMessage(context, friendsState.errorMessage);
                }
                if (friendsState is DeclineErrorState) {
                  showErrorMessage(context, friendsState.message);
                }
                if (friendsState is DeclineSuccessState) {
                  showSuccessMessage(context, friendsState.message);
                }
              },
              child: const SizedBox(),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 10.h),
                    child: Consumer<ThemeProvider>(
                      builder: (context, theme, _) {
                        return CircleAvatar(
                          radius: 40.r,
                          backgroundColor: theme.isDark ? darkGrey : darkWhite2,
                          backgroundImage:
                              profilePic.isNotEmpty
                                  ? NetworkImage(profilePic)
                                  : null,
                          child:
                              profilePic.isEmpty
                                  ? Icon(Icons.person, size: 35.h)
                                  : null,
                        );
                      },
                    ),
                  ),
                  10.horizontalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        requestedUsername,
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      3.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.clock,
                            size: 20.h,
                            color: lightGrey,
                          ),
                          5.horizontalSpace,
                          Text(
                            formatDate(requesteDate),
                            style: getBodySmall(
                              context: context,
                              fontweight: FontWeight.bold,
                              color: lightGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            5.verticalSpace,
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 90.h),
                  child: Text(
                    requestedUserbio,
                    style: getBodySmall(
                      context: context,
                      fontweight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            10.verticalSpace,
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Row(
                children: [
                  BlocBuilder<FriendsBloc, FriendsState>(
                    buildWhen: (_, current) {
                      return current is RequestAcceptErrorState ||
                          current is RequestAcceptLoadingState &&
                              current.userId == requestedUserId ||
                          current is RequestAcceptSuccessState &&
                              current.acceptRequestModel.requestedUserId ==
                                  requestedUserId;
                    },
                    builder: (_, friendsState) {
                      return AppButton(
                        text: "Accept",
                        buttonColor: blueColor,
                        textColor: whiteColor,
                        showLoading: friendsState is RequestAcceptLoadingState,
                        height: 45.h,
                        width: 100.w,
                        borderRadius: 10,
                        onTap: () {
                          //Accepting the request
                          context.read<FriendsBloc>().add(
                            AcceptRequestedEvent(userId: requestedUserId),
                          );
                        },
                      );
                    },
                  ),
                  10.horizontalSpace,
                  BlocBuilder<FriendsBloc, FriendsState>(
                    buildWhen: (_, current) {
                      return current is DeclineErrorState &&
                              current.userId == requestedUserId ||
                          current is DeclineLoadingState &&
                              current.userId == requestedUserId ||
                          current is DeclineSuccessState &&
                              current.userId == requestedUserId;
                    },
                    builder: (context, friendsState) {
                      return Consumer<ThemeProvider>(
                        builder: (_, theme, _) {
                          return AppButton(
                            text: "Decline",
                            buttonColor: theme.isDark ? darkGrey : darkWhite2,
                            textColor: theme.isDark ? darkWhite : greyColor,
                            showLoading: friendsState is DeclineLoadingState,
                            height: 45.h,
                            width: 100.w,
                            borderRadius: 10,
                            onTap: () {
                              //Declining a request
                              context.read<FriendsBloc>().add(
                                DeclineRequestEvent(userId: requestedUserId),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }
}
