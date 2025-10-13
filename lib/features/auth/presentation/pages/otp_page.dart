import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chitchat/features/auth/presentation/components/custom_cupertino_button.dart';
import 'package:chitchat/features/auth/presentation/components/otp_input.dart';
import 'package:chitchat/features/auth/presentation/pages/login_page.dart';
import 'package:chitchat/common/presentations/providers/time_provider.dart';
import 'package:chitchat/features/navigations/presentations/components/bottom_nav.dart';
import 'package:chitchat/features/navigations/presentations/pages/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class OtpPage extends StatefulWidget {
  final String email;
  final bool isFromChangePasswordPage;
  const OtpPage({
    super.key,
    required this.email,
    required this.isFromChangePasswordPage,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late final TextEditingController pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TimeProvider>().setupTime();
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              BlocListener<AuthBloc, AuthState>(
                listenWhen: (_, current) {
                  return current is SendOtpSuccessState ||
                      current is ChangePasswordSuccessState ||
                      current is ChangePasswordErrorState ||
                      current is VerifiedSuccessState ||
                      current is VerificationErrorState ||
                      current is RegisteredWithEmailSuccessState ||
                      current is NullState;
                },
                listener: (context, authState) {
                  if (authState is SendOtpSuccessState) {
                    context.read<TimeProvider>().setupTime();
                    return;
                  }
                  if (authState is ChangePasswordSuccessState) {
                    showSuccessMessage(context, authState.successMessage);
                    //Navigating to login page after password changed
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) {
                          return LoginPage();
                        },
                      ),
                      (route) => false,
                    );
                    return;
                  }
                  if (authState is ChangePasswordErrorState) {
                    showErrorMessage(context, authState.errorMessage);
                  }
                  if (widget.isFromChangePasswordPage &&
                      authState is VerifiedSuccessState) {
                    //Changing password
                    context.read<AuthBloc>().add(ChangePasswordEvent());
                  }
                  if (!widget.isFromChangePasswordPage &&
                      authState is VerifiedSuccessState) {
                    showSuccessMessage(context, authState.successMessage);
                    //Registering account
                    context.read<AuthBloc>().add(RegisterWithEmailEvent());
                  }
                  if (authState is VerificationErrorState) {
                    showErrorMessage(context, authState.errorMessage);
                  }
                  if (authState is RegisteredWithEmailSuccessState) {
                    //Navigating to main screen
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (context) {
                          bottomNavIndexNotifier.value = 0;
                          return MainScreen();
                        },
                      ),
                      (route) => false,
                    );
                  }
                },
                child: const SizedBox(),
              ),
              Center(
                child: SizedBox(
                  height: 150.h,
                  width: 300.w,
                  child: Image.asset(otpBackground),
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
                          'Verification',
                          style: getTitleLarge(
                            context: context,
                            fontSize: 30.sp,
                            fontweight: FontWeight.bold,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 240.w,
                            maxHeight: 40.h,
                          ),

                          child: Text(
                            "We have sent an OTP to ${widget.email}",
                            style: getBodySmall(
                              context: context,
                              fontweight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              OtpInput(controller: pinController),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.only(right: 70.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Didn't get OTP ?",
                      style: getTitleSmall(context: context, fontSize: 13.sp),
                    ),
                    Consumer<TimeProvider>(
                      builder: (context, timeProvider, child) {
                        return timeProvider.changingDur ==
                                const Duration(seconds: 0)
                            ? SizedBox(
                              height: 26.h,
                              child: CupertinoButton(
                                onPressed: () {
                                  context.read<AuthBloc>().add(SendotpEvent());
                                },
                                sizeStyle: CupertinoButtonSize.small,
                                child: Text(
                                  'Resend',
                                  style: getTitleSmall(
                                    context: context,
                                    color: blueColor,
                                  ),
                                ),
                              ),
                            )
                            : Padding(
                              padding: EdgeInsets.only(left: 10.w, right: 10.w),
                              child: Text(
                                timeProvider.currentTime,
                                style: getTitleSmall(
                                  context: context,
                                  color: blueColor,
                                ),
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ),
              10.verticalSpace,
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (_, current) {
                  return current is OtpLoadingState ||
                      current is ChangePasswordLoadingState ||
                      current is NullState ||
                      current is VerifiedSuccessState ||
                      current is VerifyOtpLoadingState ||
                      current is VerificationErrorState ||
                      current is ChangePasswordErrorState ||
                      current is ChangePasswordSuccessState;
                },
                builder: (context, authState) {
                  return CustomCupertinoButton(
                    label: "VERIFY",
                    onTap: () {
                      //If the any process is in loading state , avoiding things to work
                      if (authState is OtpLoadingState ||
                          authState is ChangePasswordLoadingState) {
                        return;
                      }
                      final String pin = pinController.text.trim();

                      //Checking if the pin is empty
                      if (pin.isEmpty) {
                        showWarningMessage(context, "Enter OTP");
                        return;
                      }
                      //Checking if the length of pin is 4 digits
                      if (pin.length < 4) {
                        showWarningMessage(
                          context,
                          "OTP must contain 4 digits",
                        );
                        return;
                      }
                      //Verifying the pin
                      context.read<AuthBloc>().add(VerifyOtpEvent(otp: pin));
                    },
                    isLoading:
                        authState is ChangePasswordLoadingState ||
                        authState is OtpLoadingState,
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
