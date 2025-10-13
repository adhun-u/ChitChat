part of 'auth_bloc.dart';

sealed class AuthEvent {}

//Login with email and password event
final class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  LoginWithEmailEvent({required this.email, required this.password});
}

//Login with google event
final class LoginWithGoogeEvent extends AuthEvent {}

//Save user credentials event
final class SaveUserCredentialsEvent extends AuthEvent {
  final String email;
  final String password;
  final String username;

  SaveUserCredentialsEvent({
    required this.email,
    required this.password,
    required this.username,
  });
}

final class RegisterWithGoogleEvent extends AuthEvent {}

//Register with email event
final class RegisterWithEmailEvent extends AuthEvent {}

//Check email and username event
final class CheckEmailEvent extends AuthEvent {
  final String email;
  CheckEmailEvent({required this.email});
}

//Send otp event
final class SendotpEvent extends AuthEvent {}

//Verify otp event
final class VerifyOtpEvent extends AuthEvent {
  final String otp;

  VerifyOtpEvent({required this.otp});
}

//Change password event
final class ChangePasswordEvent extends AuthEvent {}

//Logout event
final class LogoutEvent extends AuthEvent {}

//For emitting some stata
final class _EmitStateEvent extends AuthEvent {
  final AuthState state;

  _EmitStateEvent({required this.state});
}
