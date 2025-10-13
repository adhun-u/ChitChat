import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chitchat/features/auth/presentation/components/custom_cupertino_button.dart';
import 'package:chitchat/features/auth/presentation/components/custom_textfield.dart';
import 'package:chitchat/features/auth/presentation/pages/otp_page.dart';
import 'package:chitchat/common/presentations/providers/time_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  late final TextEditingController confirmPasswordController =
      TextEditingController();
  late final ValueNotifier<bool> passwordVisibleNotifier = ValueNotifier(false);
  late final ValueNotifier<bool> confirmPasswordVisibleNotifier = ValueNotifier(
    false,
  );

  bool _isCurrentPageActive = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordVisibleNotifier.dispose();
    confirmPasswordVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isCurrentPageActive = true;
    return SizedBox(
      height: double.infinity.h,
      width: double.infinity.w,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: 50.h,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              BlocListener<AuthBloc, AuthState>(
                listenWhen: (_, current) {
                  return current is UserCredentialsSavedSuccessState ||
                      current is SendOtpSuccessState ||
                      current is NullState ||
                      current is SendOtpErrorState ||
                      current is UserCredentialsSaveErrorState;
                },
                listener: (context, authState) {
                  if (authState is UserCredentialsSavedSuccessState) {
                    //Sending otp
                    context.read<AuthBloc>().add(SendotpEvent());
                  }
                  if (_isCurrentPageActive &&
                      authState is SendOtpSuccessState) {
                    //Setting up the time
                    context.read<TimeProvider>().setupTime();
                    //Navigating to otp page to verify otp
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return OtpPage(
                            email: emailController.text.trim(),
                            isFromChangePasswordPage: true,
                          );
                        },
                      ),
                    );
                    _isCurrentPageActive = false;
                  }
                },
                child: const SizedBox(),
              ),
              Center(
                child: SizedBox(
                  height: 140.h,
                  width: 380.w,
                  child: Image.asset(forgotPasswordBackground),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.w, top: 20.w),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Forgot password',
                          style: getTitleLarge(
                            context: context,
                            fontSize: 30.sp,
                            fontweight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Fill the forms below to change password',
                          style: getBodySmall(
                            context: context,
                            fontweight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              30.verticalSpace,
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: CustomTextfield(
                  controller: emailController,
                  hintText: "Enter your email",
                  prefix: const Icon(Icons.alternate_email),
                  suffix: null,
                  obscureText: false,
                ),
              ),
              10.verticalSpace,
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: ValueListenableBuilder(
                  valueListenable: passwordVisibleNotifier,
                  builder: (context, isVisible, _) {
                    return CustomTextfield(
                      controller: passwordController,
                      hintText: "Enter new password",
                      prefix: const Icon(Icons.lock),
                      suffix: IconButton(
                        onPressed: () {
                          passwordVisibleNotifier.value =
                              !passwordVisibleNotifier.value;
                        },
                        icon:
                            isVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                      ),
                      obscureText: !isVisible,
                    );
                  },
                ),
              ),
              10.verticalSpace,
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: ValueListenableBuilder(
                  valueListenable: confirmPasswordVisibleNotifier,
                  builder: (context, isVisible, _) {
                    return CustomTextfield(
                      controller: confirmPasswordController,
                      hintText: "Confirm password",
                      prefix: const Icon(Icons.lock),
                      suffix: IconButton(
                        onPressed: () {
                          confirmPasswordVisibleNotifier.value =
                              !confirmPasswordVisibleNotifier.value;
                        },
                        icon:
                            isVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                      ),
                      obscureText: !isVisible,
                    );
                  },
                ),
              ),
              20.verticalSpace,
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (_, current) {
                  return current is OtpLoadingState ||
                      current is NullState ||
                      current is SendOtpSuccessState ||
                      current is SendOtpErrorState ||
                      current is UserCredentialsSaveErrorState ||
                      current is UserCredentialsSavedSuccessState;
                },
                builder: (context, authState) {
                  return CustomCupertinoButton(
                    label: "CHANGE PASSWORD",
                    onTap: () {
                      if (authState is OtpLoadingState) {
                        return;
                      }
                      final String email = emailController.text.trim();
                      final String password = passwordController.text.trim();
                      final String confirmPassword =
                          confirmPasswordController.text.trim();
                      final RegExp emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
                      );

                      //Checking if the email is empty
                      if (email.isEmpty) {
                        showWarningMessage(context, "Email must not be empty");
                        return;
                      }
                      //Checking whether the email is valid or not
                      if (!emailRegex.hasMatch(email)) {
                        showErrorMessage(context, "Invalid email");
                        return;
                      }
                      //Checking if the password is empty
                      if (password.isEmpty) {
                        showWarningMessage(
                          context,
                          "Password must not be empty",
                        );
                        return;
                      }
                      //Checking if the password contains 6 letters
                      if (password.length < 6) {
                        showWarningMessage(
                          context,
                          "Password must contain 6 letters",
                        );
                        return;
                      }
                      //Checking if the confrim password matches the password
                      if (confirmPassword != password) {
                        showErrorMessage(
                          context,
                          "Confrim password does not match the password",
                        );
                        return;
                      }
                      //Changing password
                      context.read<AuthBloc>().add(
                        SaveUserCredentialsEvent(
                          email: email,
                          password: password,
                          username: '',
                        ),
                      );
                    },
                    isLoading: authState is OtpLoadingState,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
