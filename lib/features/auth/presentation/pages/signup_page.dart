import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chitchat/features/auth/presentation/components/custom_cupertino_button.dart';
import 'package:chitchat/features/auth/presentation/components/custom_textfield.dart';
import 'package:chitchat/features/auth/presentation/components/google_button.dart';
import 'package:chitchat/features/auth/presentation/pages/otp_page.dart';
import 'package:chitchat/common/presentations/providers/time_provider.dart';
import 'package:chitchat/features/navigations/presentations/pages/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  late final TextEditingController confirmPassController =
      TextEditingController();
  late final ValueNotifier<bool> passwordVisibleNotifier = ValueNotifier(false);
  late final ValueNotifier<bool> confrimPassVisibleNotifier = ValueNotifier(
    false,
  );

  bool _isCurrentScreenActive = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    passwordVisibleNotifier.dispose();
    confrimPassVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isCurrentScreenActive = true;
    return SizedBox(
      width: double.infinity.w,
      height: double.infinity.h,
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
                      current is SendOtpErrorState ||
                      current is CheckEmailSuccessState ||
                      current is CheckEmailErrorState ||
                      current is RegisterWithGoogleSuccessState ||
                      current is RegisterWithGoogleErrorState;
                },
                listener: (context, authState) {
                  if (authState is UserCredentialsSavedSuccessState) {
                    //Sending otp
                    context.read<AuthBloc>().add(SendotpEvent());
                  }
                  if (_isCurrentScreenActive &&
                      authState is SendOtpSuccessState) {
                    //Setting up the time
                    context.read<TimeProvider>().setupTime();
                    //Navigating to otp screen
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) {
                          return OtpPage(
                            email: emailController.text.trim(),
                            isFromChangePasswordPage: false,
                          );
                        },
                      ),
                    );
                    _isCurrentScreenActive = false;
                  }
                  if (authState is SendOtpErrorState) {
                    showErrorMessage(context, authState.errorMessage);
                    return;
                  }
                  if (authState is CheckEmailErrorState) {
                    showErrorMessage(context, authState.errorMessage);
                    return;
                  }
                  if (authState is CheckEmailSuccessState) {
                    //Saving the data
                    context.read<AuthBloc>().add(
                      SaveUserCredentialsEvent(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        username: nameController.text.trim(),
                      ),
                    );
                  }
                  if (authState is RegisterWithGoogleSuccessState) {
                    showSuccessMessage(context, authState.successMessage);
                    //Navigating to main screen
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) {
                          return const MainScreen();
                        },
                      ),
                      (route) => false,
                    );
                  }
                  if (authState is RegisterWithGoogleErrorState) {
                    showErrorMessage(context, authState.errorMessage);
                  }
                },
                child: const SizedBox(),
              ),
              Center(
                child: SizedBox(
                  height: 100.h,
                  width: 380.w,
                  child: Image.asset(createAccountBackground),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.w, top: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register',
                          style: getTitleLarge(
                            context: context,
                            fontSize: 30.sp,
                            fontweight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Please register an account',
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
                  controller: nameController,
                  hintText: "Enter your name",
                  prefix: const Icon(Icons.person),
                  suffix: null,
                  obscureText: false,
                ),
              ),
              15.verticalSpace,
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
              15.verticalSpace,
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: ValueListenableBuilder(
                  valueListenable: passwordVisibleNotifier,
                  builder: (context, isVisible, _) {
                    return CustomTextfield(
                      controller: passwordController,
                      hintText: "Enter your password",
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
              15.verticalSpace,
              Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: ValueListenableBuilder(
                  valueListenable: confrimPassVisibleNotifier,
                  builder: (context, isVisible, _) {
                    return CustomTextfield(
                      controller: confirmPassController,
                      hintText: "Confirm your password",
                      prefix: const Icon(Icons.lock),
                      suffix: IconButton(
                        onPressed: () {
                          confrimPassVisibleNotifier.value =
                              !confrimPassVisibleNotifier.value;
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
                      current is CheckEmailLoadingState ||
                      current is RegisterWithGoogleLoadingState ||
                      current is NullState ||
                      current is RegisterWithGoogleSuccessState ||
                      current is SendOtpSuccessState;
                },
                builder: (context, authState) {
                  return CustomCupertinoButton(
                    label: "CREATE ACCOUNT",
                    onTap: () {
                      //If the any process is in loading state , avoiding things to work
                      if (authState is OtpLoadingState ||
                          authState is CheckEmailLoadingState ||
                          authState is RegisterWithGoogleLoadingState) {
                        return;
                      }
                      final String email = emailController.text.trim();
                      final String password = passwordController.text.trim();
                      final String username = nameController.text.trim();
                      final String confimPassword =
                          confirmPassController.text.trim();
                      final RegExp emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
                      );
                      //Checking if the username is empty
                      if (username.isEmpty) {
                        showWarningMessage(context, "Name is required");
                        return;
                      }
                      //Checking if the length of username is more than 3
                      if (username.length < 3) {
                        showWarningMessage(
                          context,
                          "Name must contain 3 characters",
                        );
                        return;
                      }
                      //Checking if the email is empty
                      if (email.isEmpty) {
                        showWarningMessage(context, "Email is required");
                        return;
                      }
                      //Checking if the email is valid
                      if (!emailRegex.hasMatch(email)) {
                        showErrorMessage(context, "Invalid email");
                        return;
                      }
                      //Checking if the password is empty
                      if (password.isEmpty) {
                        showWarningMessage(context, "Password is required");
                        return;
                      }
                      //Checking whether the password contains 6 or more letter
                      if (password.length < 6) {
                        showWarningMessage(
                          context,
                          "Password must contain 6 letters",
                        );
                        return;
                      }
                      //Checking if the confirm password is empty
                      if (confimPassword.isEmpty) {
                        showWarningMessage(context, "Confirm your password");
                        return;
                      }

                      //Checking if the confirm password is equal to password
                      if (confimPassword != password) {
                        showErrorMessage(
                          context,
                          "Confirm password does not match the password",
                        );
                        return;
                      }
                      //Checking if the username or email is already in use
                      context.read<AuthBloc>().add(
                        CheckEmailEvent(email: email),
                      );
                    },
                    isLoading:
                        authState is CheckEmailLoadingState ||
                        authState is OtpLoadingState ||
                        authState is RegisterWithGoogleLoadingState,
                  );
                },
              ),

              10.verticalSpace,
              GestureDetector(
                onTap: () {
                  context.read<AuthBloc>().add(RegisterWithGoogleEvent());
                },
                child: const GoogleButton(text: "REGISTER WITH GOOGLE"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
