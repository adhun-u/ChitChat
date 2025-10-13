import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/common/presentations/components/app_text_field.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late final TextEditingController currentPasswordController =
      TextEditingController();
  late final TextEditingController newPasswordController =
      TextEditingController();
  late final TextEditingController confirmPasswordController =
      TextEditingController();
  late final ValueNotifier<bool> isCurrentPassVisible = ValueNotifier(false);
  late final ValueNotifier<bool> isNewPassVisible = ValueNotifier(false);
  late final ValueNotifier<bool> isConfirmPassVisible = ValueNotifier(false);

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    isCurrentPassVisible.dispose();
    isConfirmPassVisible.dispose();
    isNewPassVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: Text(
          'Change password',
          style: getTitleMedium(context: context, fontweight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.only(left: 28.w, right: 28.w),
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: isCurrentPassVisible,
                builder: (context, isVisible, _) {

                  return AppTextField(
                    controller: currentPasswordController,
                    prefix: const Icon(Icons.lock),
                    hintText: "Enter your current password",
                    maxLines: 1,
                    suffix: Padding(
                      padding:  EdgeInsets.only(right: 10.w),
                      child: IconButton(
                        onPressed: () {
                          isCurrentPassVisible.value =
                              !isCurrentPassVisible.value;
                        },
                        icon:
                            isVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                      ),
                    ),
                    obscureText: !isVisible,
                  );
                },
              ),
            ),
          ),
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.only(left: 28.w, right: 28.w),
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: isNewPassVisible,
                builder: (context, isVisible, _) {
                  return AppTextField(
                    controller: newPasswordController,
                    prefix: const Icon(Icons.lock),
                    hintText: "Enter your new password",
                    maxLines: 1,
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: () {
                          isNewPassVisible.value = !isNewPassVisible.value;
                        },
                        icon:
                            isVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                      ),
                    ),
                    obscureText: !isVisible,
                  );
                },
              ),
            ),
          ),
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.only(left: 28.w, right: 28.w),
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: isConfirmPassVisible,
                builder: (context, isVisible, _) {
                  return AppTextField(
                    controller: confirmPasswordController,
                    prefix: const Icon(Icons.lock),
                    hintText: "Confirm password",
                    maxLines: 1,
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: () {
                          isConfirmPassVisible.value =
                              !isConfirmPassVisible.value;
                        },
                        icon:
                            isVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                      ),
                    ),
                    obscureText: !isVisible,
                  );
                },
              ),
            ),
          ),
          20.verticalSpace,
          Center(
            child: SizedBox(
              height: 60.h,
              width: 380.w,
              child: Selector<CurrentUserProvider, bool>(
                selector: (_, currentUserProv) {
                  return currentUserProv.updatePasswordLoading;
                },
                builder: (context, isLoading, _) {
                  return CupertinoButton(
                    onPressed: () async {
                      if (isLoading) {
                        return;
                      }
                      final String currentPassword =
                          currentPasswordController.text.trim();
                      final String newPassword =
                          newPasswordController.text.trim();
                      final String confirmPassword =
                          confirmPasswordController.text.trim();

                      //Checking if current password is empty
                      if (currentPassword.isEmpty) {
                        showWarningMessage(
                          context,
                          "Current password must not be empty",
                        );
                        return;
                      }
                      //Checking if current password contains 6 letters
                      if (currentPassword.length < 6) {
                        showErrorMessage(context, "Incorrect current password");
                        return;
                      }

                      //Checking if new password is empty
                      if (newPassword.isEmpty) {
                        showWarningMessage(
                          context,
                          "New password must not be empty",
                        );
                        return;
                      }

                      //Checking if new password contains 6 letters
                      if (newPassword.length < 6) {
                        showWarningMessage(
                          context,
                          "New password must contain 6 letters",
                        );
                        return;
                      }

                      //Checking if confrim password is empty
                      if (confirmPassword.isEmpty) {
                        showWarningMessage(context, "Confirm your password");
                        return;
                      }

                      //Checking if confirm password is equal to new password
                      if (confirmPassword != newPassword) {
                        showWarningMessage(
                          context,
                          "Confrim password doesn't match new password",
                        );
                        return;
                      }
                      //Changing password
                      final dartz.Either<SuccessMessageModel, ErrorMessageModel>
                      result = await context
                          .read<CurrentUserProvider>()
                          .updatePassword(
                            oldPassword: currentPassword,
                            newPassword: newPassword,
                          );

                      //Checking whether the result returns success state or error state
                      result.fold(
                        //Success
                        (_) {
                          showSuccessMessage(
                            context,
                            "Updated password successfully",
                          );

                          Navigator.of(context).pop();
                        },
                        //Error
                        (_) {
                          showErrorMessage(context, 'Something went wrong');
                        },
                      );
                    },
                    color: blueColor,
                    borderRadius: BorderRadius.circular(30),
                    child:
                        isLoading
                            ? SizedBox(
                              height: 35.h,
                              width: 25.w,
                              child: const LoadingIndicator(color: whiteColor),
                            )
                            : Text(
                              'Change password',
                              style: getTitleMedium(
                                context: context,
                                fontweight: FontWeight.bold,
                                color: whiteColor,
                                fontSize: 15.sp,
                              ),
                            ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
