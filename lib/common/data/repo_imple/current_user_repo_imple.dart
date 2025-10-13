import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/domain/entities/current_user/current_user_entity.dart';
import 'package:chitchat/common/domain/entities/message/message_entity.dart';
import 'package:chitchat/common/domain/entities/password/change_password_entity.dart';
import 'package:chitchat/common/domain/repo/current_user_repo.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class CurrentUserRepoImple implements CurrentUserRepo {
  //Baseurl
  final Dio _dio = Dio(BaseOptions(baseUrl: "$baseUrl/user"));

  //------------- FETCH CURRENT USER REPO IMPLEMENTING ---------------
  //For getting current user's details
  @override
  Future<Either<CurrentUserModel?, ErrorMessageModel?>> fetchCurrentUser({
    required String token,
  }) async {
    try {
      //Sending a request to get current user
      final response = await _dio.get(
        '/current',
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the response was success or failer
      //Success
      if (response.statusCode == 200) {
        //Parsing the current user details from the response
        final CurrentUserEntity currentUserEntity = CurrentUserEntity.fromJson(
          response.data['currenUserDetails'],
        );
        return left(
          CurrentUserModel(
            userId: currentUserEntity.userId,
            username: currentUserEntity.username,
            profilePic: currentUserEntity.profiePic,
            bio: currentUserEntity.bio,
            email: currentUserEntity.emai,
          ),
        );
      }
    } catch (e) {
      printDebug(e.toString());
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //------------- UPDATE CURRENT USER DETAILS REPO IMPLEMENTING ------------------
  //For updating current user's details
  @override
  Future<Either<UpdatedUserDetailsModel, ErrorMessageModel>>
  updateCurrentUserDetails({
    required String token,
    required String imagePath,
    required String username,
    required String bio,
  }) async {
    try {
      //Creating a formfile to update details
      final FormData formData = FormData.fromMap({
        "newname": username,
        "newbio": bio,
        "profilePic":
            imagePath != "" ? await MultipartFile.fromFile(imagePath) : "",
      });
      //Sending a request to update current user details
      final response = await _dio.patch(
        '/currentuser',
        data: formData,
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the response was success or failer
      if (response.statusCode == 200) {
        final UpdatedCurrentUserEntity updatedCurrentUserEntity =
            UpdatedCurrentUserEntity.fromJson(response.data);

        return left(
          UpdatedUserDetailsModel(
            newUsername: updatedCurrentUserEntity.newUsername,
            newBio: updatedCurrentUserEntity.newBio,
            newImageUrl: updatedCurrentUserEntity.imageUrl,
          ),
        );
      }
    } catch (e) {
      printDebug(e.toString());
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //------------- UPDATE PASSWORD REPO IMPLEMENTING -------------------
  //For updating current user's password
  @override
  Future<Either<SuccessMessageModel, ErrorMessageModel>> updatePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      //Sending a request to change password
      final response = await _dio.patch(
        '/password',
        data:
            ChangePasswordEntity(
              currentPassword: currentPassword,
              newPassword: newPassword,
            ).toJson(),
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the response was success or failer
      //Success
      if (response.statusCode == 200) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          response.data,
        );

        return left(SuccessMessageModel(message: messageEntity.message));
      }
    } catch (e) {
      printDebug(e.toString());
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }
}
