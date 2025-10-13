import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/device_size.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chitchat/features/auth/presentation/components/custom_cupertino_button.dart';
import 'package:chitchat/features/auth/presentation/components/custom_textfield.dart';
import 'package:chitchat/features/auth/presentation/components/forgot_password_button.dart';
import 'package:chitchat/features/auth/presentation/components/google_button.dart';
import 'package:chitchat/features/auth/presentation/pages/signup_page.dart';
import 'package:chitchat/features/navigations/presentations/pages/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  late final ValueNotifier<bool> isVisibleNotifier = ValueNotifier(false);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity.h,
      width: double.infinity.w,
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocListener<AuthBloc, AuthState>(
                listenWhen: (_, current) {
                  return current is LoginWithEmailSuccessState ||
                      current is LoginWithEmailErrorState ||
                      current is LoginWithGoogleSuccessState ||
                      current is LoginWithGoogleErrorState;
                },
                listener: (context, authState) {
                  if (authState is LoginWithEmailErrorState) {
                    showErrorMessage(context, authState.errorMessage);
                  }
                  if (authState is LoginWithEmailSuccessState) {
                    showSuccessMessage(context, authState.successMessage);
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) {
                          return MainScreen();
                        },
                      ),
                      (route) => false,
                    );
                  }
                  if (authState is LoginWithGoogleSuccessState) {
                    showSuccessMessage(context, authState.successMessage);
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) {
                          return MainScreen();
                        },
                      ),
                      (route) => false,
                    );
                  }
                  if (authState is LoginWithGoogleErrorState) {
                    showErrorMessage(context, authState.errorMessage);
                    return;
                  }
                },
                child: const SizedBox(),
              ),
              SizedBox(height: context.height() * 0.08),

              Center(
                child: SizedBox(
                  height: 140.h,
                  width: 380.w,
                  child: Image.asset(loginBackground),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.w, top: 20.h),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login',
                          style: getTitleLarge(
                            context: context,
                            fontSize: 30,
                            fontweight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Please login to continue',
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
                  valueListenable: isVisibleNotifier,
                  builder: (context, isVisible, _) {
                    return CustomTextfield(
                      controller: passwordController,
                      hintText: "Enter your password",
                      prefix: const Icon(Icons.lock),
                      suffix: IconButton(
                        onPressed: () {
                          isVisibleNotifier.value = !isVisibleNotifier.value;
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
                padding: EdgeInsets.only(right: 10.w),
                child: const ForgotPasswordButton(),
              ),
              20.verticalSpace,
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (_, current) {
                  return current is LoginWithEmailLoadingState ||
                      current is LoginWithGoogleLoadingState ||
                      current is NullState ||
                      current is LoginWithGoogleErrorState ||
                      current is LoginWithEmailErrorState ||
                      current is LoginWithGoogleSuccessState;
                },
                builder: (context, authState) {
                  return CustomCupertinoButton(
                    label: "LOGIN",
                    isLoading:
                        authState is LoginWithEmailLoadingState ||
                        authState is LoginWithGoogleLoadingState,
                    onTap: () {
                      //If the any process is in loading state , avoiding things to work
                      if (authState is LoginWithEmailLoadingState ||
                          authState is LoginWithGoogleLoadingState) {
                        return;
                      }
                      final String email = emailController.text.trim();
                      final String password = passwordController.text.trim();
                      final RegExp emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
                      );
                      //Checking if the email is empty
                      if (email.isEmpty) {
                        showWarningMessage(context, "Email must not be empty");
                        return;
                      }
                      //Checking if the email is valid
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
                      if (password.length < 6) {
                        showWarningMessage(
                          context,
                          "Password must contain 6 letters",
                        );
                        return;
                      }
                      context.read<AuthBloc>().add(
                        LoginWithEmailEvent(email: email, password: password),
                      );
                    },
                  );
                },
              ),
              12.verticalSpace,
              GestureDetector(
                onTap: () {
                  context.read<AuthBloc>().add(LoginWithGoogeEvent());
                },
                child: const GoogleButton(text: "CONTINUE WITH GOOGLE"),
              ),
              20.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dont't have an account?",
                    style: getTitleSmall(
                      context: context,
                      fontweight: FontWeight.w500,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) {
                            return const SignupPage();
                          },
                        ),
                      );
                    },
                    sizeStyle: CupertinoButtonSize.small,
                    child: Text(
                      'Create account',
                      style: getTitleSmall(
                        context: context,
                        color: blueColor,
                        fontweight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
