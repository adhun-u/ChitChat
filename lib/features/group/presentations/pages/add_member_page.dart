import 'dart:developer';

import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/presentations/components/app_text_field.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/components/shimmer_loading.dart';
import 'package:chitchat/common/presentations/pages/error_page.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:chitchat/features/group/presentations/components/limit_reached_dialog.dart';
import 'package:chitchat/features/home/data/models/added_user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AddMemberPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  const AddMemberPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  late CurrentUserModel _currentUser;
  final Debouncer _debouncer = Debouncer();
  late final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    //Getting current user id
    _currentUser = context.read<CurrentUserProvider>().currentUser;
    //Fetching some users to add as member
    context.read<GroupBloc>().add(
      FetchUsersToAddMemberEvent(groupId: widget.groupId),
    );
    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        log("Called");
        //Loading more users to add member
        context.read<GroupBloc>().add(
          LoadMoreUsersToAddMemberEvent(groupId: widget.groupId),
        );
      }
    });
  }

  //For searching a user
  void _searchDebounce(String text) {
    _debouncer.debounce(
      duration: const Duration(milliseconds: 300),
      onDebounce: () {
        context.read<GroupBloc>().add(
          SearchMembersToAddEvent(searchText: text),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        //Refetching added users of this group
        context.read<GroupBloc>().add(
          FetchGroupAddedUsersEvent(
            groupId: widget.groupId,
            currentUseId: _currentUser.userId,
            shouldCallApi: false,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Member',
                style: getTitleSmall(
                  context: context,
                  fontweight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                widget.groupName,
                style: getBodySmall(
                  context: context,
                  fontweight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: AppTextField(
                  controller: _searchController,
                  backgroudColor: lightBlue,
                  prefix: const Icon(Icons.search, color: greyColor),
                  textColor: blackColor,
                  hintText: "Search people..",
                  maxLength: 100,
                  obscureText: false,
                  onChanged: (text) {
                    _searchDebounce(text);
                  },
                  suffix: IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.close, color: greyColor),
                  ),
                ),
              ),
            ),
            20.verticalSpace,
            Expanded(
              child: BlocBuilder<GroupBloc, GroupState>(
                buildWhen: (_, current) {
                  return current is FetchAddedUsersOnlyErrorState ||
                      current is FetchAddedUsersOnlyLoadingState ||
                      current is FetchAddedUsersOnlySuccessState;
                },
                builder: (context, groupState) {
                  if (groupState is FetchAddedUsersOnlyErrorState) {
                    return Center(child: ErrorPage());
                  }
                  if (groupState is FetchAddedUsersOnlyLoadingState) {
                    return _ShowLoadingScreen();
                  }
                  if (groupState is FetchAddedUsersOnlySuccessState) {
                    return BlocBuilder<GroupBloc, GroupState>(
                      buildWhen: (_, current) {
                        return (current is LoadMoreUserToAddMemberErrorState) ||
                            (current is LoadMoreUserToAddMemberLoadingState) ||
                            (current is LoadMoreUserToAddMemberSuccessState);
                      },
                      builder: (context, innerGroupState) {
                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          key: const PageStorageKey("usersToAddMember"),
                          controller: _scrollController,
                          itemCount:
                              groupState.addedUsers.length +
                              (innerGroupState
                                      is LoadMoreUserToAddMemberLoadingState
                                  ? 1
                                  : 0),
                          itemBuilder: (context, index) {
                            if (index == groupState.addedUsers.length) {
                              return Center(
                                child: LoadingIndicator(
                                  color: blueColor,
                                  strokeWidth: 2,
                                ),
                              );
                            }
                            final AddedUserOnlyModel user =
                                groupState.addedUsers[index];
                            return ListTile(
                              title: Text(
                                user.username,
                                style: getTitleSmall(
                                  context: context,
                                  fontweight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle:
                                  user.userBio.isNotEmpty
                                      ? ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: 50.h,
                                        ),
                                        child: Text(
                                          user.userBio,
                                          style: getBodySmall(
                                            context: context,
                                            fontweight: FontWeight.w400,
                                            fontSize: 14.sp,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                      : null,
                              leading: Consumer<ThemeProvider>(
                                builder: (context, theme, _) {
                                  return Container(
                                    height: 70.h,
                                    width: 70.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color:
                                          theme.isDark ? greyColor : darkWhite,
                                      image:
                                          user.profilePic.isNotEmpty
                                              ? DecorationImage(
                                                image: NetworkImage(
                                                  user.profilePic,
                                                ),

                                                fit: BoxFit.cover,
                                              )
                                              : null,
                                    ),
                                    child:
                                        user.profilePic.isEmpty
                                            ? Icon(Icons.person, size: 35.h)
                                            : null,
                                  );
                                },
                              ),
                              trailing: BlocBuilder<GroupBloc, GroupState>(
                                buildWhen: (_, current) {
                                  return current is AddMemberErrorState &&
                                          current.userId == user.userId ||
                                      current is AddMemberLoadingState &&
                                          current.userId == user.userId ||
                                      current is AddMemberSuccessState &&
                                          current.userId == user.userId;
                                },
                                builder: (context, groupState) {
                                  if (groupState is AddMemberLoadingState) {
                                    return LoadingIndicator(color: blueColor);
                                  }
                                  if (groupState is AddMemberSuccessState) {
                                    return IconButton(
                                      onPressed: () {},
                                      icon: CircleAvatar(
                                        radius: 25.r,
                                        backgroundColor: Color(0xFFdbeafe),
                                        child: const Icon(
                                          Icons.done,
                                          color: blueColor,
                                        ),
                                      ),
                                    );
                                  }
                                  return IconButton(
                                    onPressed: () {
                                      if (context
                                              .read<GroupBloc>()
                                              .currentGroupMembersCount ==
                                          100) {
                                        //Showing limit indication
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return GroupMemberLimitReadDialog();
                                          },
                                        );
                                        return;
                                      }
                                      //Adding this user to the given group
                                      context.read<GroupBloc>().add(
                                        AddMemberToGroupEvent(
                                          groupId: widget.groupId,
                                          userId: user.userId,
                                          profilePic: user.profilePic,
                                          userBio: user.userBio,
                                          username: user.username,
                                        ),
                                      );
                                    },
                                    icon: CircleAvatar(
                                      radius: 25.r,
                                      backgroundColor: Color(0xFFdbeafe),
                                      child: Icon(
                                        Icons.person_add,
                                        color: blueColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          separatorBuilder: (_, _) {
                            return 10.verticalSpace;
                          },
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

  @override
  bool get wantKeepAlive => true;
}

class _ShowLoadingScreen extends StatelessWidget {
  const _ShowLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 30.r),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5.h,
                children: [
                  Container(
                    height: 25.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.amber,
                    ),
                  ),
                  Container(
                    height: 20.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            Consumer<ThemeProvider>(
              builder: (context, theme, child) {
                return CircleAvatar(
                  radius: 25.r,
                  backgroundColor: theme.isDark ? darkGrey : darkWhite2,
                  child: child,
                );
              },
              child: const Icon(Icons.person_add, color: lightGrey),
            ),
          ],
        ),
      ),
    );
  }
}
