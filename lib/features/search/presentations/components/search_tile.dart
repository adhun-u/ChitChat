import 'package:chitchat/common/presentations/bloc/request/request_bloc.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/device_size.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/features/home/data/datasource/chat_storage.dart';
import 'package:chitchat/features/home/presentations/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class SearchTile extends StatelessWidget {
  final String username;
  final String profilePic;
  final String bio;
  final int userId;
  final int currentUserId;
  final bool isRequested;
  final bool isAdded;
  final ChatStorageDB _chatStorage = ChatStorageDB();
  SearchTile({
    super.key,
    required this.profilePic,
    required this.username,
    required this.bio,
    required this.userId,
    required this.currentUserId,
    required this.isAdded,
    required this.isRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return Container(
              height: context.height() * 0.08,
              width: context.height() * 0.08,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: blueColor, width: 2),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: context.height() * 0.035,
                  backgroundColor:
                      themeProvider.isDark ? greyColor : darkWhite2,
                  backgroundImage:
                      profilePic.isNotEmpty ? NetworkImage(profilePic) : null,

                  child:
                      profilePic.isEmpty
                          ? Icon(Icons.person, size: 30.h)
                          : null,
                ),
              ),
            );
          },
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: getTitleMedium(
                    context: context,
                    fontweight: FontWeight.bold,
                  ),
                ),
                bio.isNotEmpty
                    ? ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: context.height() * 0.045,
                        maxWidth: context.width() - 150,
                      ),
                      child: Text(
                        bio,
                        style: getTitleSmall(
                          context: context,
                          fontweight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        BlocListener<RequestBloc, RequestState>(
          listenWhen: (_, current) {
            return current is SentRequestErrorState &&
                    current.userId == userId ||
                current is SentRequestSuccessState && current.userId == userId;
          },
          listener: (context, requestState) {
            if (requestState is SentRequestErrorState) {
              showErrorMessage(context, requestState.errorMessage);
            }
            if (requestState is SentRequestSuccessState) {
              showSuccessMessage(context, requestState.message);
            }
          },
          child: const SizedBox(),
        ),
        currentUserId != userId
            ? isRequested
                ? Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: Icon(
                        Icons.check,
                        color: themeProvider.isDark ? darkWhite2 : greyColor,
                      ),
                    );
                  },
                )
                : isAdded
                ? IconButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: ChatPage(
                        profilePic: profilePic,
                        userId: userId,
                        username: username,
                        userbio: bio,
                        unreadMessageCount: _chatStorage.getUnreadMessageCount(
                          receiverId: userId,
                          currentUserId: currentUserId,
                        ),
                      ),
                      pageTransitionAnimation: PageTransitionAnimation.slideUp,
                    );
                  },
                  icon: Icon(
                    Icons.chat,
                    color: getBodySmall(context: context).color,
                  ),
                )
                : BlocBuilder<RequestBloc, RequestState>(
                  buildWhen: (_, current) {
                    return (current is SentRequestErrorState &&
                            current.userId == userId) ||
                        (current is SentRequestLoadingState &&
                            current.userId == userId) ||
                        (current is SentRequestSuccessState &&
                            current.userId == userId);
                  },
                  builder: (context, requestState) {
                    if (requestState is SentRequestLoadingState &&
                        requestState.userId == userId) {
                      return Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: SizedBox(
                          height: 30.h,
                          width: 30.h,
                          child: LoadingIndicator(color: blueColor),
                        ),
                      );
                    }
                    if (requestState is SentRequestSuccessState &&
                        requestState.userId == userId) {
                      return Consumer<ThemeProvider>(
                        builder: (context, theme, _) {
                          return Padding(
                            padding: EdgeInsets.only(right: 10.w),
                            child: Icon(
                              Icons.check,
                              color: theme.isDark ? darkWhite2 : greyColor,
                            ),
                          );
                        },
                      );
                    }
                    return IconButton(
                      onPressed: () {
                        //Sending a request to be a friend
                        context.read<RequestBloc>().add(
                          SentRequestEvent(
                            requestedUserId: userId,
                            requestedUserProfilePic: profilePic,
                            requestedUserbio: bio,
                            requestedUsername: username,
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add, color: blueColor),
                    );
                  },
                )
            : const SizedBox(),
      ],
    );
  }
}
