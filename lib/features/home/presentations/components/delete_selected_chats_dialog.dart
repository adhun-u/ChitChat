import 'package:chitchat/common/presentations/components/app_button.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/group/presentations/components/dialog_loading_indicator.dart';
import 'package:chitchat/features/home/data/models/chat_model.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteSelectedChatDialog extends StatefulWidget {
  const DeleteSelectedChatDialog({super.key});

  @override
  State<DeleteSelectedChatDialog> createState() =>
      _DeleteSelectedChatDialogState();
}

class _DeleteSelectedChatDialogState extends State<DeleteSelectedChatDialog> {
  late final Map<String, SelectedChatModel> _selectedChats;
  @override
  void initState() {
    super.initState();
    //Getting the selected chats details
    _selectedChats = context.read<ChatBloc>().selectedChats;
  }

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
                BlocListener<ChatBloc, ChatState>(
                  listener: (context, chatState) {
                    if (chatState is DeleteForEveryoneLoadingState) {
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
                    if (chatState is DeleteForEveryoneErrorState) {
                      Navigator.of(context).pop();
                      showErrorMessage(context, "Something went wrong");
                      Navigator.of(context).pop();
                    }
                    if (chatState is DeleteForEveryoneSuccessState) {
                      Navigator.of(context).pop();
                      showSuccessMessage(context, "Deleted successfully");
                      Navigator.of(context).pop();
                    }
                  },
                  child: const SizedBox(),
                ),
                if (_selectedChats.length == 1 &&
                    !_selectedChats.values.toList()[0].isSeen &&
                    !context.watch<ChatBloc>().isReceiverInOnline &&
                    context.read<CurrentUserProvider>().currentUser.userId ==
                        _selectedChats.values.toList()[0].senderId)
                  AppButton(
                    text: "Delete for everyone",
                    buttonColor: Colors.transparent,
                    textColor: blueColor,
                    showLoading: false,
                    height: 30.h,
                    width: 200.w,
                    borderRadius: 0,
                    onTap: () {
                      //Deleting single message which receiver did not see
                      context.read<ChatBloc>().add(DeleteForEveryone());
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
                    context.read<ChatBloc>().add(DeleteForMeEvent());
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
