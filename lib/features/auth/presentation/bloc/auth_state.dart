part of 'auth_bloc.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

//Login with email success state
final class LoginWithEmailSuccessState extends AuthState {
  final String successMessage;

  LoginWithEmailSuccessState({required this.successMessage});
}

//Login with email error state
final class LoginWithEmailErrorState extends AuthState {
  final String errorMessage;
  LoginWithEmailErrorState({required this.errorMessage});
}

//Login with email loading state
final class LoginWithEmailLoadingState extends AuthState {}

//Null state
final class NullState extends AuthState {}

//Login with google loading state
final class LoginWithGoogleLoadingState extends AuthState {}

//Login with google success state
final class LoginWithGoogleSuccessState extends AuthState {
  final String successMessage;

  LoginWithGoogleSuccessState({required this.successMessage});
}

//Login with google error state
final class LoginWithGoogleErrorState extends AuthState {
  final String errorMessage;
  LoginWithGoogleErrorState({required this.errorMessage});
}

//Saved credentials success state
final class UserCredentialsSavedSuccessState extends AuthState {}

//Saving error state
final class UserCredentialsSaveErrorState extends AuthState {}

//Check username and email loading state
final class CheckEmailLoadingState extends AuthState {}

//Check username and email success state
final class CheckEmailSuccessState extends AuthState {}

//Check username and email error state
final class CheckEmailErrorState extends AuthState {
  final String errorMessage;

  CheckEmailErrorState({required this.errorMessage});
}

//Otp send success state
final class SendOtpSuccessState extends AuthState {}

//Otp send error state
final class SendOtpErrorState extends AuthState {
  final String errorMessage;
  SendOtpErrorState({required this.errorMessage});
}

//Otp loading state
final class OtpLoadingState extends AuthState {}

//Verify otp loading state
final class VerifyOtpLoadingState extends AuthState {}

//Verified success state
final class VerifiedSuccessState extends AuthState {
  final String successMessage;
  VerifiedSuccessState({required this.successMessage});
}

//Verification error state
final class VerificationErrorState extends AuthState {
  final String errorMessage;

  VerificationErrorState({required this.errorMessage});
}

//Registered with email success state
final class RegisteredWithEmailSuccessState extends AuthState {}

//Registered with email error state
final class RegisteredWithEmailErrorState extends AuthState {
  final String errorMessage;

  RegisteredWithEmailErrorState({required this.errorMessage});
}

//Register with email loading state
final class RegisterWithEmailLoadingState extends AuthState {}

//Register with google success state
final class RegisterWithGoogleSuccessState extends AuthState {
  final String successMessage;

  RegisterWithGoogleSuccessState({required this.successMessage});
}

//Register with google error state
final class RegisterWithGoogleErrorState extends AuthState {
  final String errorMessage;
  RegisterWithGoogleErrorState({required this.errorMessage});
}

//Register with google loading state
final class RegisterWithGoogleLoadingState extends AuthState {}

//Change password success state
final class ChangePasswordSuccessState extends AuthState {
  final String successMessage;

  ChangePasswordSuccessState({required this.successMessage});
}

//Change password error state
final class ChangePasswordErrorState extends AuthState {
  final String errorMessage;

  ChangePasswordErrorState({required this.errorMessage});
}

//Change password loading state
final class ChangePasswordLoadingState extends AuthState {}