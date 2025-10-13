import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SearchGroupTile extends StatelessWidget {
  final String groupName;
  final String groupImageUrl;
  final String groupBio;
  final String groupId;
  final int groupAdminId;
  final bool isCurrentUserAdded;
  final bool isRequestSent;
  const SearchGroupTile({
    super.key,
    required this.groupName,
    required this.groupImageUrl,
    required this.groupBio,
    required this.groupAdminId,
    required this.isCurrentUserAdded,
    required this.isRequestSent,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: Padding(
        padding: EdgeInsets.only(left: 10.w, right: 10.w),
        child: Row(
          children: [
            Container(
              height: 75.h,
              width: 75.h,
              decoration: BoxDecoration(
                border: Border.all(color: blueColor, width: 2),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(2.h),
                child: Consumer<ThemeProvider>(
                  builder: (context, theme, _) {
                    return CircleAvatar(
                      radius: 35.r,
                      backgroundImage:
                          groupImageUrl.isNotEmpty
                              ? NetworkImage(groupImageUrl)
                              : null,
                      backgroundColor: theme.isDark ? greyColor : darkWhite,
                      child:
                          groupImageUrl.isEmpty
                              ? Icon(Icons.group, size: 35.h)
                              : null,
                    );
                  },
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      groupName,
                      style: getTitleMedium(
                        context: context,
                        fontweight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 50.h),
                      child: Text(
                        groupBio,
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isCurrentUserAdded && !isRequestSent)
              BlocBuilder<GroupBloc, GroupState>(
                buildWhen: (_, current) {
                  return current is SendRequestLoadingState &&
                          current.groupId == groupId ||
                      current is SendRequestSuccessState &&
                          current.groupId == groupId ||
                      current is SendRequestErrorState;
                },
                builder: (context, groupState) {
                  if (groupState is SendRequestLoadingState &&
                      groupState.groupId == groupId) {
                    return SizedBox(
                      height: 30.h,
                      width: 30.h,
                      child: CircularProgressIndicator(
                        color: blueColor,
                        strokeWidth: 3,
                      ),
                    );
                  }
                  if (groupState is SendRequestSuccessState &&
                      groupState.groupId == groupId) {
                    return Consumer<ThemeProvider>(
                      builder: (context, theme, _) {
                        return _CustomCupertinoButton(
                          onTap: () {},
                          buttonColor: theme.isDark ? darkGrey : darkWhite,
                          text: "Sent",
                          textColor: theme.isDark ? darkWhite : greyColor,
                        );
                      },
                    );
                  }
                  return _CustomCupertinoButton(
                    onTap: () {
                      context.read<GroupBloc>().add(
                        SendRequestEvent(
                          groupName: groupName,
                          groupId: groupId,
                          groupAdminId: groupAdminId,
                        ),
                      );
                    },
                    buttonColor: blueColor,
                    text: "Request",
                    textColor: whiteColor,
                  );
                },
              ),
            if (isRequestSent && !isCurrentUserAdded)
              Consumer<ThemeProvider>(
                builder: (context, theme, _) {
                  return _CustomCupertinoButton(
                    onTap: () {},
                    buttonColor: theme.isDark ? darkGrey : darkWhite,
                    text: "Sent",
                    textColor: theme.isDark ? darkWhite : greyColor,
                  );
                },
              ),
            if (isCurrentUserAdded && !isRequestSent)
              Consumer<ThemeProvider>(
                builder: (context, theme, _) {
                  return _CustomCupertinoButton(
                    onTap: () {},
                    buttonColor: theme.isDark ? darkGrey : darkWhite,
                    text: "Added",
                    textColor: theme.isDark ? darkWhite : greyColor,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomCupertinoButton extends StatelessWidget {
  final Function() onTap;
  final Color buttonColor;
  final String text;
  final Color textColor;
  const _CustomCupertinoButton({
    required this.onTap,
    required this.buttonColor,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      width: 90.w,
      child: CupertinoButton(
        onPressed: () {
          onTap();
        },
        sizeStyle: CupertinoButtonSize.small,
        color: buttonColor,
        borderRadius: BorderRadius.circular(30),
        child: Text(
          text,
          style: getBodySmall(
            context: context,
            fontweight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
