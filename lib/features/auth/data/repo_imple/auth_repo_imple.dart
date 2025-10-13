import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/domain/entities/message/message_entity.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/features/auth/data/models/token_model.dart';
import 'package:chitchat/features/auth/domain/entities/check/check_username_email_entity.dart';
import 'package:chitchat/features/auth/domain/entities/login_email/login_email_entity.dart';
import 'package:chitchat/features/auth/domain/entities/login_google/login_google_entity.dart';
import 'package:chitchat/features/auth/domain/entities/register_email/register_email_entity.dart';
import 'package:chitchat/features/auth/domain/entities/register_google/register_with_google_entity.dart';
import 'package:chitchat/features/auth/domain/entities/token/token_entity.dart';
import 'package:chitchat/features/auth/domain/repo/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthRepoImple implements AuthRepo {
  //Base url
  final Dio _dio = Dio(BaseOptions(baseUrl: "$baseUrl/auth"));

  //------------- LOGIN WITH EMAIL REPO IMPLEMENTING ---------------------
  //For logging using email
  @override
  Future<Either<TokenModel?, ErrorMessageModel?>> loginWithEmail({
    required String email,
    required String password,
    required String deviceToken,
  }) async {
    try {
      //Checking if the FCM token is empty or not
      if (deviceToken == "") {
        return right(ErrorMessageModel(message: 'Something went wrong'));
      }
      final response = await _dio.post(
        '/login/email',
        data:
            LoginEmailEntity(
              email: email,
              password: password,
              deviceToken: deviceToken,
            ).toJson(),
      );

      //Checking whether the response was succeess or not
      //Success state
      if (response.statusCode == 200) {
        //Parsing the data and token from response
        final TokenEntity tokenEntity = TokenEntity.fromJson(response.data);
        return left(
          TokenModel(message: tokenEntity.message, token: tokenEntity.token),
        );
      }
      //Error state
      else {
        //Parsing the error message from response
        final MessageEntity messageEntity = MessageEntity.fromJson(
          response.data,
        );

        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is! String) {
        //Parsing the error message from response
        final MessageEntity messageEntity = MessageEntity.fromJson(
          e.response!.data,
        );

        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //------------------ LOGIN WITH GOOGLE REPO IMPLEMENTING -------------
  //For loggin using google
  @override
  Future<Either<TokenModel?, ErrorMessageModel?>> loginWithGoogle({
    required String username,
    required String email,
    required String deviceToken,
  }) async {
    try {
      //Checking if the FCM token is empty or not
      if (deviceToken == "") {
        return right(ErrorMessageModel(message: 'Something went wrong'));
      }
      final response = await _dio.post(
        '/login/google',
        data:
            LoginGoogleEntity(
              email: email,
              username: username,
              deviceToken: deviceToken,
            ).toJson(),
      );

      //Checking whether the response was success or error
      //Success
      if (response.statusCode == 200) {
        //Parsing the message and token from response
        final TokenEntity tokenEntity = TokenEntity.fromJson(response.data);

        return left(
          TokenModel(message: tokenEntity.message, token: tokenEntity.token),
        );
      }
      //Error
      else {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          response.data,
        );
        return right(ErrorMessageModel(message: messageEntity.message));
      }
    }
    //Extracting the message from dioException
    on DioException catch (e) {
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is! String) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          e.response!.data,
        );
        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: "Something went wrong"));
    }
    return right(ErrorMessageModel(message: "Something went wrong"));
  }

  //--------------- REGISTER WITH EMAIL REPO IMPLEMENTING ------------------
  //For registering an account using email
  @override
  Future<Either<TokenModel?, ErrorMessageModel?>> registerWithEmail({
    required String username,
    required String email,
    required String password,
    required String deviceToken,
  }) async {
    try {
      //Checking if the FCM token is empty or not
      if (deviceToken == "") {
        return right(ErrorMessageModel(message: 'Something went wrong'));
      }
      final response = await _dio.post(
        '/register/email',
        data:
            RegisterEmailEntity(
              email: email,
              password: password,
              username: username,
              deviceToken: deviceToken,
            ).toJson(),
      );

      //Checking whether the response was success or error
      //Success
      if (response.statusCode == 200) {
        //Parsing the message and token from response
        final TokenEntity tokenEntity = TokenEntity.fromJson(response.data);

        return left(
          TokenModel(message: tokenEntity.message, token: tokenEntity.token),
        );
      }
      //Error
      else {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          response.data,
        );
        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is! String) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          e.response!.data,
        );
        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //--------------- CHECK USERNAME AND EMAIL REPO IMPLEMENTING -------------
  //Using for checking if the username or email is already taken
  @override
  Future<Either<bool?, ErrorMessageModel?>> checkEmail({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/check',
        data: CheckEmailEntity(email: email).toJson(),
      );

      //Checking whether the response was success not not
      //Success
      if (response.statusCode == 200) {
        return left(true);
      }
      //Error
      else {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          response.data,
        );
        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is! String) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          e.response!.data,
        );
        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //--------------------- SEND OTP REPO IMPLEMENTING -----------------------
  @override
  Future<Either<bool?, ErrorMessageModel?>> sendOtp({
    required String email,
  }) async {
    try {
      //Body
      Map<String, dynamic> data = {'email': email};
      final Response<dynamic> response = await _dio.post('/otp/send', data: data);

      //Checking if the response was success
      //Success
      if (response.statusCode == 200) {
        return left(true);
      }
      //Error
      else {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          response.data,
        );

        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is! String) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          e.response!.data,
        );

        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } catch (e) {
      right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //--------------- VERIFY OTP REPO IMPLEMENTING -----------------------------
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      //Body
      final Map<String, dynamic> data = {'email': email, 'otp': otp};

      final response = await _dio.post('/otp/verify', data: data);

      //Checking whether the response was success or fail
      //Success
      if (response.statusCode == 200) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          response.data,
        );

        return left(SuccessMessageModel(message: messageEntity.message));
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is! String) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          e.response!.data,
        );

        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  @override
  Future<Either<TokenModel?, ErrorMessageModel?>> registerWithGoogle({
    required String email,
    required String username,
    required String? profilePic,
    required String deviceToken,
  }) async {
    try {
      //Checking if the FCM token is empty or not
      if (deviceToken == "") {
        return right(ErrorMessageModel(message: 'Something went wrong'));
      }
      final response = await _dio.post(
        '/register/google',
        data:
            RegisterWithGoogleEntity(
              email: email,
              username: username,
              profilePic: profilePic,
              deviceToken: deviceToken,
            ).toJson(),
      );

      //Checking whether it returns success or failer
      //Success
      if (response.statusCode == 200) {
        //Parsing the token and message from response
        final TokenEntity tokenEntity = TokenEntity.fromJson(response.data);

        return left(
          TokenModel(message: tokenEntity.message, token: tokenEntity.token),
        );
      }
      //Failer
      else {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          response.data,
        );

        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is! String) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          e.response!.data,
        );

        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //-------------- CHANGE PASSWORD REPO IMPLEMENTING ------------------
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> changePassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      //Body
      final Map<String, dynamic> data = {
        "email": email,
        "newPassword": newPassword,
      };
      final response = await _dio.patch('/change/password', data: data);

      //Checking whether the response was success or failer
      //Success
      if (response.statusCode == 200) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          response.data,
        );

        return left(SuccessMessageModel(message: messageEntity.message));
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is! String) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          e.response!.data,
        );
        return right(ErrorMessageModel(message: messageEntity.message));
      } else {
        return right(ErrorMessageModel(message: "Could not change password "));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }
}
