import 'package:chitchat/common/data/models/message_model.dart';
import 'package:dartz/dartz.dart';

abstract class RequestUserRepo {
  
  //----------------- REQUEST USER REPO -------------------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> sentRequest({
    required int requestedUserId,
    required String requestedUsername,
    required String requestedUserProfilePic,
    required String requestedUserbio,
    required String requestedDate,
    required String token
  });
}
