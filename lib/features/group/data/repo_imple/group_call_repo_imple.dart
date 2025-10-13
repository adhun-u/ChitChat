import 'dart:developer';

import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:chitchat/features/group/domain/repo/call_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class GroupCallRepoImple implements GroupCallRepo {
  //Base url
  final Dio _dio = Dio(BaseOptions(baseUrl: "$baseUrl/group"));

  //--------------- CREATE ROOM REPO IMPLEMENTING --------------
  //For creating room audio or video call and to get jwt token for the room
  @override
  Future<Either<String, ErrorMessageModel>> createRoom({
    required String groupName,
    required String groupProfilePic,
    required String callType,
    required String groupId,
    required int userId,
    required String username,
    required String profilePic,
    required String token,
  }) async {
    try {
      //Body to attach to send necessary group and user details
      final Map<String, dynamic> groupInfo = {
        "groupId": groupId,
        "groupName": groupName,
        "groupProfilePic": groupProfilePic,
        "currentUserId": userId,
        "currentUserProfilePic": profilePic,
        "currentUserName": username,
        "callType": callType,
      };
      //Sending a request to get jwt token
      final Response<dynamic> result = await _dio.post(
        "/call",
        options: Options(headers: getHeaders(token: token)),
        data: groupInfo,
      );

      if (result.statusCode == 200) {
        //Extracting the token from the response
        final String jwtToken = result.data['token'];
        return left(jwtToken);
      }
    } on DioException catch (e) {
      log("CAtch error : ${e.response}");
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }
}
