import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/features/auth/data/models/token_model.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepo {
  //------------- LOGIN WITH EMAIL REPO -----------------------
  Future<Either<TokenModel?, ErrorMessageModel?>> loginWithEmail({
    required String email,
    required String password,
    required String deviceToken
  });

  //------------ LOGIN WITH GOOGLE REPO ------------------------
  Future<Either<TokenModel?, ErrorMessageModel?>> loginWithGoogle({
    required String username,
    required String email,
     required String deviceToken
  });

  //----------- REGISTER WITH EMAIL REPO ------------------------
  Future<Either<TokenModel?, ErrorMessageModel?>> registerWithEmail({
    required String username,
    required String email,
    required String password,
     required String deviceToken
  });

  //------------ REGISTER WITH GOOGLE REPO --------------------------
  Future<Either<TokenModel?, ErrorMessageModel?>> registerWithGoogle({
    required String email,
    required String username,
    required String? profilePic,
     required String deviceToken
  });

  //---------- CHECK USERNAME AND EMAIL REPO ----------------------
  //Using for checking if the username or email is already taken
  Future<Either<bool?, ErrorMessageModel?>> checkEmail({required String email});

  //----------- SEND OTP REPO -------------------------
  Future<Either<bool?, ErrorMessageModel?>> sendOtp({required String email});

  //----------- VARIFY OTP REPO ------------------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> verifyOtp({
    required String email,
    required String otp,
  });

  //------------ CHANGE PASSWORD REPO -----------------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> changePassword({
    required String email,
    required String newPassword,
  });
}
