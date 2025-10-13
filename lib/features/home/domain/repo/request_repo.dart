import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/features/home/data/models/accept_request_model.dart';
import 'package:chitchat/features/home/data/models/request_user_model.dart';
import 'package:chitchat/features/home/data/models/sent_request_user_model.dart';
import 'package:chitchat/features/home/data/models/withdraw_request_model.dart';
import 'package:dartz/dartz.dart';

abstract class RequestedUserRepo {
  //------------ FETCH REQUESTS REPO ------------------
  Future<Either<List<RequestUserModel>?, ErrorMessageModel?>> fetchRequested({
    required String token,
    required int limit,
    required int page,
  });

  //-------------- ACCEPT REQUEST REPO ------------------
  Future<Either<AcceptRequestModel?, ErrorMessageModel?>> acceptRequsted({
    required int requestedUserId,
    required String token,
  });

  //---------------- FETCH SENT REQUESTS REPO ----------------
  Future<Either<List<SentRequestUserModel>?, ErrorMessageModel?>>
  fetchSentRequestUsers({
    required String token,
    required int limit,
    required int page,
  });

  //---------------- WITHDRAW REQUEST REPO -------------------
  Future<Either<WithdrawRequestModel?, ErrorMessageModel?>> withdrawRequest({
    required String token,
    required int userId,
  });

  //----------------- DECLINE REQUEST REPO ----------------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> declineRequest({
    required String token,
    required int declinedUserId,
  });
}
