import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/common/presentations/components/custom_refresh_indicator.dart';
import 'package:chitchat/common/presentations/pages/error_page.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/icons.dart';
import 'package:chitchat/core/helpers/date_time_formatter.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/home/data/models/sent_request_user_model.dart';
import 'package:chitchat/features/home/presentations/blocs/friends/friends_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SendRequestUsersListPage extends StatefulWidget {
  const SendRequestUsersListPage({super.key});

  @override
  State<SendRequestUsersListPage> createState() =>
      _SendRequestUsersListPageState();
}

class _SendRequestUsersListPageState extends State<SendRequestUsersListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        //Loading more sent users details
        context.read<FriendsBloc>().add(LoadMoreSentUsersEvent());
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
    super.build(context);
    return Scaffold(
      body: CustomRefreshIndicator(
        onRefresh: () async {
          //Re-fetching the users
          context.read<FriendsBloc>().add(
            FetchSentRequestEvent(shouldCallApi: true),
          );
        },
        child: Column(
          children: [
            BlocListener<FriendsBloc, FriendsState>(
              listenWhen: (_, current) {
                return current is RequestWithdrawErrorState ||
                    current is RequestWithdrawSuccessState;
              },
              listener: (context, friendsState) {
                if (friendsState is RequestWithdrawErrorState) {
                  showErrorMessage(context, friendsState.errorMessage);
                }
                if (friendsState is RequestWithdrawSuccessState) {
                  showSuccessMessage(context, "Withdrawn successfully");
                }
              },
              child: const SizedBox(),
            ),
            Expanded(
              child: BlocBuilder<FriendsBloc, FriendsState>(
                buildWhen: (_, current) {
                  return current is FetchSentRequestErrorState ||
                      current is FetchSentRequestLoadingState ||
                      current is FetchSentRequestSuccessState;
                },
                builder: (context, friendsState) {
                  if (friendsState is FetchSentRequestSuccessState &&
                      friendsState.sentRequestUsers.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.asset(
                            sendRequestIcon,
                            color: lightGrey,
                            height: 100.h,
                          ),
                        ),
                        5.verticalSpace,
                        Text(
                          'No one is sent',
                          style: getTitleMedium(
                            context: context,
                            fontweight: FontWeight.w500,
                            color: lightGrey,
                          ),
                        ),
                      ],
                    );
                  }
                  if (friendsState is FetchSentRequestErrorState) {
                    return Expanded(child: ErrorPage());
                  }
                  if (friendsState is FetchSentRequestLoadingState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: LoadingIndicator(color: blueColor)),
                      ],
                    );
                  }
                  if (friendsState is FetchSentRequestSuccessState) {
                    return BlocBuilder<FriendsBloc, FriendsState>(
                      buildWhen: (_, current) {
                        return (current is LoadMoreSentUsersErrorState) ||
                            (current is LoadMoreSentUsersLoadingState) ||
                            (current is LoadMoreSentUsersSuccessState);
                      },
                      builder: (context, innerFriendState) {
                        return Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            key: const PageStorageKey("sent users"),
                            itemCount:
                                friendsState.sentRequestUsers.length +
                                (innerFriendState
                                        is LoadMoreSentUsersLoadingState
                                    ? 1
                                    : 0),
                            itemBuilder: (context, index) {
                              if (index ==
                                  friendsState.sentRequestUsers.length) {
                                return Center(
                                  child: LoadingIndicator(
                                    color: blueColor,
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                              final SentRequestUserModel user =
                                  friendsState.sentRequestUsers[index];
                              return Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: BlocBuilder<FriendsBloc, FriendsState>(
                                  buildWhen: (_, current) {
                                    return current
                                                is RequestWithdrawLoadingState &&
                                            current.userId == user.sentUserId ||
                                        current is RequestWithdrawErrorState &&
                                            current.userId == user.sentUserId ||
                                        current
                                                is RequestWithdrawSuccessState &&
                                            current.withdrawnUserId ==
                                                user.sentUserId;
                                  },
                                  builder: (context, friendsState) {
                                    return _SentUserTile(
                                      sentUserId: user.sentUserId,
                                      sentUsername: user.sentUsername,
                                      sentUserbio: user.sentUserbio,
                                      profilePic: user.sentUserProfilePic,
                                      sentDate: user.sentDate,
                                      showLoading:
                                          friendsState
                                              is RequestWithdrawLoadingState,
                                    );
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 10);
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
      ),
    );
  }
}

class _SentUserTile extends StatelessWidget {
  final String profilePic;
  final int sentUserId;
  final String sentUsername;
  final String sentUserbio;
  final String sentDate;
  final bool showLoading;
  const _SentUserTile({
    required this.profilePic,
    required this.sentUserId,
    required this.sentUserbio,
    required this.sentUsername,
    required this.sentDate,
    required this.showLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 250.h, maxWidth: 400.w),
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
            Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 0.w, top: 10.h),
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
                        sentUsername,
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
                            formatDate(sentDate),
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
            if (sentUserbio.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 90.h,
                      maxWidth: 390.w,
                    ),
                    child: Text(
                      sentUserbio,
                      style: getBodySmall(
                        context: context,
                        fontweight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            10.verticalSpace,
            AppButton(
              text: "Withdraw",
              buttonColor: blueColor,
              textColor: whiteColor,
              showLoading: showLoading,
              height: 50.h,
              width: 390.w,
              borderRadius: 30,
              onTap: () {
                //Withdrawing the request of current user
                context.read<FriendsBloc>().add(
                  WithdrawRequestEvent(userId: sentUserId),
                );
              },
            ),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }
}
