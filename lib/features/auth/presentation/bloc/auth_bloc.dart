import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:chitchat/common/application/notifications/handler.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/features/auth/data/datasource/user_cred_db.dart';
import 'package:chitchat/features/auth/data/models/token_model.dart';
import 'package:chitchat/features/auth/data/repo_imple/auth_repo_imple.dart';
import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  //Creating an instance for AuthRepoImple
  final AuthRepoImple _authRepoImple = AuthRepoImple();

  AuthBloc() : super(AuthInitial()) {
    //Login with email event
    on<LoginWithEmailEvent>(loginWithEmail);
    //Login with google event
    on<LoginWithGoogeEvent>(loginWithGoogle);
    //Save user credentials event
    on<SaveUserCredentialsEvent>(saveUserdata);
    //Check username and email event
    on<CheckEmailEvent>(checkEmailAndUsername);
    //Send otp event
    on<SendotpEvent>(sendOtp);
    //Verify otp event
    on<VerifyOtpEvent>(verifyOtp);
    //Register with email event
    on<RegisterWithEmailEvent>(registerWithEmail);
    //Register with google event
    on<RegisterWithGoogleEvent>(registerWithGoogle);
    //Change password event
    on<ChangePasswordEvent>(changePassword);
    //Logout event
    on<LogoutEvent>(logout);
    //To emit some state
    on<_EmitStateEvent>((event, emit) {
      emit(event.state);
    });
  }

  //------------- LOGIN WITH EMAIL BLOC ---------------------
  Future<void> loginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(LoginWithEmailLoadingState());

    final Either<TokenModel?, ErrorMessageModel?> result = await _authRepoImple
        .loginWithEmail(
          email: event.email,
          password: event.password,
          deviceToken: FCMPushNotification.fcmToken ?? "",
        );
    //Checking whether it returns success state or error state
    result.fold(
      //Success state
      (tokenModel) async {
        if (tokenModel != null) {
          log("Token : ${tokenModel.token}");
          //Saving the jwt token
          await saveToken(tokenModel.token);
          add(
            _EmitStateEvent(
              state: LoginWithEmailSuccessState(
                successMessage: tokenModel.message,
              ),
            ),
          );
        } else {
          //Emitting null state to avoid loading state
          return emit(
            LoginWithEmailErrorState(errorMessage: "Something went wrong"),
          );
        }
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(
            LoginWithEmailErrorState(errorMessage: errorModel.message),
          );
        } else {
          //Emitting null state to avoid loading state
          return emit(NullState());
        }
      },
    );
  }

  //---------------- LOGIN WITH GOOGLE BLOC ----------------------
  Future<void> loginWithGoogle(
    LoginWithGoogeEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(LoginWithGoogleLoadingState());
      //Creating an instance for google sign
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final Either<TokenModel?, ErrorMessageModel?> result =
            await _authRepoImple.loginWithGoogle(
              username: googleUser.displayName!,
              email: googleUser.email,
              deviceToken: FCMPushNotification.fcmToken ?? "",
            );
        await googleSignIn.disconnect();
        // Checking whether it returns success state or error state
        result.fold(
          //Success state
          (tokenModel) {
            if (tokenModel != null) {
              saveToken(tokenModel.token);
              return emit(
                LoginWithGoogleSuccessState(successMessage: tokenModel.message),
              );
            }
          },
          //Error state
          (errorModel) {
            if (errorModel != null) {
              return emit(
                LoginWithGoogleErrorState(errorMessage: errorModel.message),
              );
            }
          },
        );
      } else {
        //Emitting null state to avoid loading state
        emit(NullState());
      }
    } catch (e) {
      emit(NullState());
    }
  }

  //--------------------- SAVE USER CREDENTIALS BLOC ---------------------
  Future<void> saveUserdata(
    SaveUserCredentialsEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      //Saving neccessary user credentials
      await saveUserCredentials(
        username: event.username,
        email: event.email,
        password: event.password,
      );

      emit(UserCredentialsSavedSuccessState());
    } catch (e) {
      emit(UserCredentialsSaveErrorState());
    }
  }

  //---------------- CHECK USERNAME AND EMAIL BLOC -------------------
  Future<void> checkEmailAndUsername(
    CheckEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(CheckEmailLoadingState());

    final Either<bool?, ErrorMessageModel?> result = await _authRepoImple
        .checkEmail(email: event.email);

    //Checking if it returns success state or error state
    result.fold(
      //Success state
      (_) {
        return emit(CheckEmailSuccessState());
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(CheckEmailErrorState(errorMessage: errorModel.message));
        }
      },
    );
  }

  //--------------------- SEND OTP BLOC ---------------------------------
  Future<void> sendOtp(SendotpEvent event, Emitter<AuthState> emit) async {
    emit(OtpLoadingState());

    //Getting the credentials from database
    final ({String? email, String? password, String? username})
    userCredentials = await getUserCredentials();
    if (userCredentials.email != null) {
      //Then sending otp to email
      final Either<bool?, ErrorMessageModel?> result = await _authRepoImple
          .sendOtp(email: userCredentials.email!);

      //Checking whether it returns success state or error state
      result.fold(
        //Success state
        (_) {
          return emit(SendOtpSuccessState());
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(SendOtpErrorState(errorMessage: errorModel.message));
          }
        },
      );
    } else {
      return emit(NullState());
    }
  }

  //------------------ VARIFY OTP BLOC ------------------------------
  Future<void> verifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(VerifyOtpLoadingState());

    //Getting user credentials from database
    final ({String? email, String? password, String? username})
    userCredentials = await getUserCredentials();
    if (userCredentials.email != null) {
      final result = await _authRepoImple.verifyOtp(
        email: userCredentials.email!,
        otp: event.otp,
      );

      //Checking whether it returns success state or error state
      result.fold(
        //Success state
        (successModel) {
          if (successModel != null) {
            return emit(
              VerifiedSuccessState(successMessage: successModel.message),
            );
          }
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(
              VerificationErrorState(errorMessage: errorModel.message),
            );
          }
        },
      );
    } else {
      //Returing null state to cancel loading
      return emit(NullState());
    }
  }

  //--------------------- REGISTER WITH EMAIL BLOC ----------------------
  Future<void> registerWithEmail(
    RegisterWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(RegisterWithEmailLoadingState());

    //Getting user credentials from database
    final ({String? email, String? password, String? username})
    userCredentials = await getUserCredentials();

    if (userCredentials.email != null &&
        userCredentials.username != null &&
        userCredentials.password != null) {
      final Either<TokenModel?, ErrorMessageModel?> result =
          await _authRepoImple.registerWithEmail(
            username: userCredentials.username!,
            email: userCredentials.email!,
            password: userCredentials.password!,
            deviceToken: FCMPushNotification.fcmToken ?? "",
          );

      //Checking whether it returns success state or error state
      result.fold(
        //Success state
        (tokenModel) {
          if (tokenModel != null) {
            //Saving the token
            saveToken(tokenModel.token);

            return emit(RegisteredWithEmailSuccessState());
          }
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(
              RegisteredWithEmailErrorState(errorMessage: errorModel.message),
            );
          }
        },
      );
    } else {
      //Returing null state to cancel loading
      return emit(NullState());
    }
  }

  //----------------------- REGISTER WITH GOOGLE BLOC -----------------------
  Future<void> registerWithGoogle(
    RegisterWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(RegisterWithGoogleLoadingState());

    //Creating an instance for google sign
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final Either<TokenModel?, ErrorMessageModel?> result =
          await _authRepoImple.registerWithGoogle(
            email: googleUser.email,
            username: googleUser.displayName!,
            profilePic: googleUser.photoUrl,
            deviceToken: FCMPushNotification.fcmToken ?? "",
          );
      await googleSignIn.disconnect();
      //Checking whether it returns success state or error state
      result.fold(
        //Success state
        (tokenModel) {
          if (tokenModel != null) {
            //Saving the token
            saveToken(tokenModel.token);
            return emit(
              RegisterWithGoogleSuccessState(
                successMessage: tokenModel.message,
              ),
            );
          }
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(
              RegisterWithGoogleErrorState(errorMessage: errorModel.message),
            );
          }
        },
      );
    } else {
      //To avoid loading state
      return emit(NullState());
    }
  }

  //------------------ CHANGE PASSWORD BLOC ------------------------
  Future<void> changePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ChangePasswordLoadingState());

    //Getting userCredentials from database
    final ({String? email, String? password, String? username})
    userCredentials = await getUserCredentials();
    if (userCredentials.email != null && userCredentials.password != null) {
      final result = await _authRepoImple.changePassword(
        email: userCredentials.email!,
        newPassword: userCredentials.password!,
      );

      //Checking whether it retuns success state or error state
      result.fold(
        //Success state
        (successModel) {
          if (successModel != null) {
            return emit(
              ChangePasswordSuccessState(successMessage: successModel.message),
            );
          }
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(
              ChangePasswordErrorState(errorMessage: errorModel.message),
            );
          }
        },
      );
    } else {
      //To avoid loading state
      emit(NullState());
    }
  }

  //------------------- LOGOUT BLOC -------------------------
  Future<void> logout(LogoutEvent event, Emitter<AuthState> emit) async {
    await deleteToken();
  }
}
