import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/group/data/models/group_model.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GroupAddedUserList extends StatefulWidget {
  final String groupId;
  final int adminId;
  final int currentUserId;
  const GroupAddedUserList({
    super.key,
    required this.groupId,
    required this.adminId,
    required this.currentUserId,
  });

  @override
  State<GroupAddedUserList> createState() => _GroupAddedUserListState();
}

class _GroupAddedUserListState extends State<GroupAddedUserList> {
  @override
  void initState() {
    super.initState();
    //Getting group members without calling api
    context.read<GroupBloc>().add(
      FetchGroupAddedUsersEvent(
        groupId: widget.groupId,
        currentUseId: widget.currentUserId,
        shouldCallApi: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      buildWhen: (_, current) {
        return current is FetchGroupAddedUsersLoadingState ||
            current is FetchGroupAddedUsersErrorState ||
            current is FetchGroupAddedUsersSuccessState;
      },
      builder: (context, groupState) {
        if (groupState is FetchGroupAddedUsersLoadingState) {
          return Center(child: LoadingIndicator(color: blueColor));
        }
        if (groupState is FetchGroupAddedUsersSuccessState) {
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: groupState.addedUsers.length,
            itemBuilder: (context, index) {
              final GroupAddedUserModel addedUser =
                  groupState.addedUsers[index];
              return ListTile(
                leading: Consumer<ThemeProvider>(
                  builder: (context, theme, _) {
                    return CircleAvatar(
                      radius: 30.r,
                      backgroundColor: theme.isDark ? greyColor : darkWhite,
                      backgroundImage:
                          addedUser.profilePic.isNotEmpty
                              ? NetworkImage(addedUser.profilePic)
                              : null,

                      child:
                          addedUser.profilePic.isEmpty
                              ? Icon(Icons.person, size: 35.h)
                              : null,
                    );
                  },
                ),
                title: Text(
                  addedUser.userId == widget.currentUserId
                      ? "You"
                      : addedUser.username,
                  style: getTitleMedium(
                    context: context,
                    fontweight: FontWeight.bold,
                  ),
                ),
                subtitle:
                    addedUser.userBio.isNotEmpty
                        ? Text(
                          addedUser.userBio,
                          style: getBodySmall(
                            context: context,
                            fontweight: FontWeight.w500,
                          ),
                        )
                        : null,
                trailing:
                    addedUser.userId == widget.adminId
                        ? _GroupMemberStatus(text: "Admin")
                        : widget.currentUserId == widget.adminId
                        ? IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return _ShowDeleteMemberDialog(
                                  imageUrl: addedUser.profilePic,
                                  username: addedUser.username,
                                  groupId: widget.groupId,
                                  userId: addedUser.userId,
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            CupertinoIcons.delete,
                            color: redColor,
                          ),
                        )
                        : null,
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _ShowDeleteMemberDialog extends StatelessWidget {
  final String imageUrl;
  final String username;
  final String groupId;
  final int userId;

  const _ShowDeleteMemberDialog({
    required this.imageUrl,
    required this.username,
    required this.groupId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.h,
        width: 400.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: context.read<ThemeProvider>().isDark ? greyColor : darkWhite,
        ),
        child: BlocListener<GroupBloc, GroupState>(
          listenWhen: (_, current) {
            return (current is RemoveMemberErrorState) ||
                (current is RemoveMemberLoadingState) ||
                (current is RemoveMemberSuccessState);
          },
          listener: (context, groupState) {
            if (groupState is RemoveMemberLoadingState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor:
                      context.read<ThemeProvider>().isDark
                          ? blackColor
                          : whiteColor,
                  content: Text(
                    "Removing...",
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.bold,
                      color:
                          context.read<ThemeProvider>().isDark
                              ? darkWhite
                              : greyColor,
                    ),
                  ),
                ),
              );
            }
            if (groupState is RemoveMemberErrorState) {
              ScaffoldMessenger.of(
                context,
              ).hideCurrentSnackBar(reason: SnackBarClosedReason.remove);
              showErrorMessage(context, "Something went wrong");
              Navigator.of(context).pop();
            }
            if (groupState is RemoveMemberSuccessState) {
              ScaffoldMessenger.of(
                context,
              ).hideCurrentSnackBar(reason: SnackBarClosedReason.remove);
              showSuccessMessage(context, "Removed successfully");
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.w, top: 20.h),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Remove memeber ?',
                            style: getTitleMedium(
                              context: context,
                              fontweight: FontWeight.bold,
                              color: lightGrey,
                            ),
                          ),
                          10.horizontalSpace,
                          Icon(
                            CupertinoIcons.delete,
                            color: redColor.withAlpha(180),
                            size: 25.h,
                          ),
                        ],
                      ),
                      Text(
                        'Do you want to remove $username from this group',
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.w400,
                          color: lightGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Column(
                    children: [
                      AppButton(
                        text: "Remove",
                        buttonColor: Colors.transparent,
                        textColor: redColor.withAlpha(180),
                        showLoading: false,
                        height: 40.h,
                        width: 90.w,
                        borderRadius: 0,
                        onTap: () {
                          //Removing this user from group
                          context.read<GroupBloc>().add(
                            RemoveMemberEvent(groupId: groupId, userId: userId),
                          );
                        },
                      ),
                      AppButton(
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupMemberStatus extends StatelessWidget {
  final String text;
  const _GroupMemberStatus({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23.h,
      width: 60.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Color(0xFFdbeafe),
      ),
      child: Center(
        child: Text(
          text,
          style: getBodySmall(
            context: context,
            fontweight: FontWeight.bold,
            fontSize: 11.sp,
            color: blueColor,
          ),
        ),
      ),
    );
  }
}
