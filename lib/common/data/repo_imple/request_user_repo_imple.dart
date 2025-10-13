import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/domain/entities/message/message_entity.dart';
import 'package:chitchat/common/domain/entities/request_user/request_user_entity.dart';
import 'package:chitchat/common/domain/repo/request_user_repo.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class RequestUserRepoImple implements RequestUserRepo {
  //Baseurl
  final Dio _dio = Dio(BaseOptions(baseUrl: '$baseUrl/user'));


  //--------------------- REQUEST USER REPO IMPLEMENTING --------------------
  //For sending a request to be friend
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> sentRequest({
    required int requestedUserId,
    required String requestedUsername,
    required String requestedUserProfilePic,
    required String requestedUserbio,
    required String requestedDate,
    required String token,
  }) async {
    try {
      //Sending a request to add user to request list
      final response = await _dio.post(
        '/request',
        data:
            RequestUserEntity(
              requestedUserId: requestedUserId,
              requestedUsername: requestedUsername,
              requestedUserProfilePic: requestedUserProfilePic,
              requestedUserbio: requestedUserbio,
              requestedDate : requestedDate
            ).toJson(),
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the response was success or failer
      if (response.statusCode == 200) {
        //Success response
        return left(
          SuccessMessageModel(
         message: "Sent request successfully"
          ),
        );
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
}
