import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:chitchat/features/home/data/models/accept_request_model.dart';
import 'package:chitchat/features/home/data/models/request_user_model.dart';
import 'package:chitchat/features/home/data/models/sent_request_user_model.dart';
import 'package:chitchat/features/home/data/models/withdraw_request_model.dart';
import 'package:chitchat/features/home/domain/entities/accept_request/accept_request_entity.dart';
import 'package:chitchat/features/home/domain/entities/requested_users/request_user_entity.dart';
import 'package:chitchat/features/home/domain/entities/sent_users/sent_user_entity.dart';
import 'package:chitchat/features/home/domain/entities/withdraw_request/withdraw_request_entity.dart';
import 'package:chitchat/features/home/domain/repo/request_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class RequestedUsersRepoImple implements RequestedUserRepo {
  //Baseurl
  final Dio _dio = Dio(BaseOptions(baseUrl: '$baseUrl/user'));

  //------------- FETCH REQUESTED USER REPO IMPLEMENTING --------------------
  //For fetching requests of current user
  @override
  Future<Either<List<RequestUserModel>?, ErrorMessageModel?>> fetchRequested({
    required String token,
    required int limit,
    required int page,
  }) async {
    try {
      //Sending request to fetch requested users that request current user
      final Response<dynamic> response = await _dio.get(
        '/request?limit=$limit&page=$page',
        options: Options(headers: getHeaders(token: token)),
      );
      //Checking whether the response was success or failer
      if (response.statusCode == 200) {
        //Checking if the requested users are empty
        final List<dynamic> requestedUsersData =
            response.data["requestedUsers"] as List<dynamic>;

        if (requestedUsersData.isEmpty) {
          return left([]);
        }
        //Parsing the list from response
        final List<RequestUserModel> requestedUsers =
            requestedUsersData.map((user) {
              final FetchRequestUserEntity fetchRequestUserEntity =
                  FetchRequestUserEntity.fromJson(user);
              return RequestUserModel(
                id: fetchRequestUserEntity.id,
                requestedUserId: fetchRequestUserEntity.requestedUserId,
                requestedUsername: fetchRequestUserEntity.requestedUsername,
                requestedUserProfilePic:
                    fetchRequestUserEntity.profilePic ?? "",
                requestedUserbio: fetchRequestUserEntity.userBio ?? "",
                requestedDate: fetchRequestUserEntity.requestedDate,
              );
            }).toList();

        return left(requestedUsers);
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //----------------------- ACCEPT REQUEST REPO IMPLEMENTING ------------------
  //For accepting a request
  @override
  Future<Either<AcceptRequestModel?, ErrorMessageModel?>> acceptRequsted({
    required int requestedUserId,
    required String token,
  }) async {
    try {
      //Body
      Map<String, dynamic> data = {"userId": requestedUserId};

      //Sending a request to accept the request of requested user
      final response = await _dio.post(
        '/request/accept?time=${DateTime.now().toUtc().toIso8601String()}',
        data: data,
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether it was success response or failer
      //Success
      if (response.statusCode == 200) {
        //Parsing the message and requestedUserId from response
        final AcceptRequestEntity acceptRequestEntity =
            AcceptRequestEntity.fromJson(response.data);

        return left(
          AcceptRequestModel(
            message: acceptRequestEntity.message,
            requestedUserId: acceptRequestEntity.requestedUserId,
          ),
        );
      }
    } catch (e) {
      printDebug(e);
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //-------------- FETCH SENT REQUEST USERS REPO IMPLEMENTING --------------
  //For fetching the users the current user sent request
  @override
  Future<Either<List<SentRequestUserModel>?, ErrorMessageModel?>>
  fetchSentRequestUsers({
    required String token,
    required int limit,
    required int page,
  }) async {
    try {
      //Sending a request to get the users that current user sent request
      final Response<dynamic> response = await _dio.get(
        '/sent?limit=$limit&page=$page',
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the response was success or failer
      //Success state
      if (response.statusCode == 200) {
        //Converting it as a list
        final List<dynamic> responseData =
            response.data["sentUsers"] as List<dynamic>;

        if (responseData.isEmpty) {
          return left([]);
        }
        final List<SentRequestUserModel> sentUsers =
            responseData.map((sentUser) {
              final SentUserEntity sentUserEntity = SentUserEntity.fromJson(
                sentUser,
              );
              //Converting each data to SentRequestUserModel
              return SentRequestUserModel(
                sentUserId: sentUserEntity.sentUserId,
                sentUsername: sentUserEntity.sentUsername,
                sentUserProfilePic: sentUserEntity.sentUserProfilePic ?? "",
                sentUserbio: sentUserEntity.sentUserbio ?? "",
                sentDate: sentUserEntity.sentDate,
              );
            }).toList();

        return left(sentUsers);
      }
    } catch (e) {
      printDebug(e.toString());
      right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //--------------- WITHDRAW REQUEST REPO IMPLEMENTING ---------------------
  //For withdrawing a request
  @override
  Future<Either<WithdrawRequestModel?, ErrorMessageModel?>> withdrawRequest({
    required String token,
    required int userId,
  }) async {
    try {
      //Sending a request to withdraw a request
      final Response<dynamic> response = await _dio.delete(
        '/withdraw?userId=$userId',
        options: Options(headers: getHeaders(token: token)),
      );
      //Checking whether the response was success or error
      if (response.statusCode == 200) {
        //Parsing user id who is withdrawn and a message from response
        final WithdrawRequestEntity withdrawRequestEntity =
            WithdrawRequestEntity.fromJson(response.data);

        return left(
          WithdrawRequestModel(
            message: withdrawRequestEntity.message,
            withdrawnUserId: withdrawRequestEntity.withdrawnUserId,
          ),
        );
      }
    } catch (e) {
      printDebug(e);
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }

    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //----------------- DECLINE REQUEST REPO IMPLEMENTING ------------------
  //For declining a request
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> declineRequest({
    required String token,
    required int declinedUserId,
  }) async {
    try {
      final Response<dynamic> response = await _dio.delete(
        "/request/decline?userId=$declinedUserId",
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the response was success or failer
      if (response.statusCode == 200) {
        return left(SuccessMessageModel(message: 'Declined successfully'));
      }
    } catch (e) {
      printDebug(e);
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }
}
