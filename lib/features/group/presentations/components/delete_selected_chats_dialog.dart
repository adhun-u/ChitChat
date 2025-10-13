import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/group/presentations/blocs/group_chat/group_chat_bloc.dart';
import 'package:chitchat/features/group/presentations/components/dialog_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteSelectedGroupChatsDialog extends StatelessWidget {
  final String groupId;
  const DeleteSelectedGroupChatsDialog({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.h,
        width: 390.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: context.read<ThemeProvider>().isDark ? greyColor : darkWhite,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            30.verticalSpace,
            Center(
              child: Text(
                'Do you delete chat ?',
                style: getTitleMedium(
                  context: context,
                  fontweight: FontWeight.bold,
                ),
              ),
            ),
            10.verticalSpace,
            Padding(
              padding: EdgeInsets.only(left: 15.w, right: 15.w),
              child: Text(
                'Chats will be deleted permanently and cannot recovery',
                style: getTitleSmall(
                  context: context,
                  fontweight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            40.verticalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 10.h,
              children: [
                BlocListener<GroupChatBloc, GroupChatState>(
                  listenWhen: (_, current) {
                    return (current is DeleteGroupChatFromEveryOneErrorState) ||
                        (current is DeleteGroupChatFromEveryOneLoadingState) ||
                        (current is DeleteGroupChatFromEveryOneSuccessState);
                  },
                  listener: (context, groupChatState) {
                    if (groupChatState
                        is DeleteGroupChatFromEveryOneLoadingState) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return DialogLoadingIndicator(
                            loadingText: "Deleting...",
                          );
                        },
                      );
                    }
                    if (groupChatState
                        is DeleteGroupChatFromEveryOneErrorState) {
                      Navigator.of(context).pop();
                      showErrorMessage(context, "Something went wrong");
                      Navigator.of(context).pop();
                    }
                    if (groupChatState
                        is DeleteGroupChatFromEveryOneSuccessState) {
                      Navigator.of(context).pop();
                      showSuccessMessage(context, "Deleted successfully");
                      Navigator.of(context).pop();
                    }
                  },
                  child: const SizedBox(),
                ),

                BlocBuilder<GroupChatBloc, GroupChatState>(
                  buildWhen: (_, current) {
                    return (current is SelectedGroupChatsState);
                  },
                  builder: (context, groupChatState) {
                    return groupChatState is SelectedGroupChatsState &&
                            groupChatState.selectedChats.length == 1 &&
                            !groupChatState.selectedChats.values
                                .toList()[0]
                                .isSeen &&
                            groupChatState.selectedChats.values
                                    .toList()[0]
                                    .senderId ==
                                context
                                    .read<CurrentUserProvider>()
                                    .currentUser
                                    .userId
                        ? AppButton(
                          text: "Delete for everyone",
                          buttonColor: Colors.transparent,
                          textColor: blueColor,
                          showLoading: false,
                          height: 30.h,
                          width: 200.w,
                          borderRadius: 0,
                          onTap: () {
                            //Deleting single message which anyone from group did not see
                            context.read<GroupChatBloc>().add(
                              DeleteGroupChatForEveryOneEvent(groupId: groupId),
                            );
                          },
                        )
                        : const SizedBox();
                  },
                ),
                AppButton(
                  text: "Delete for me",
                  buttonColor: Colors.transparent,
                  textColor: blueColor,
                  showLoading: false,
                  height: 30.h,
                  width: 163.w,
                  borderRadius: 0,
                  onTap: () {
                    //Deleting the selected chats locally
                    context.read<GroupChatBloc>().add(
                      DeleteGroupChatsForMeEvent(),
                    );
                    Navigator.of(context).pop();
                  },
                ),
                AppButton(
                  text: "Cancel",
                  buttonColor: Colors.transparent,
                  textColor: blueColor,
                  showLoading: false,
                  height: 30.h,
                  width: 120.w,
                  borderRadius: 0,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
