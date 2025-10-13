import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/features/home/data/models/added_user_model.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepo {
  //-------------- FETCH ADDED USERS WITH LAST MESSAGE REPO ----------
  Future<Either<List<AddedUserWithLastMessageModel>?, ErrorMessageModel?>>
  fetchAddedUsersWithLastMessage({
    required String token,
    required int currentUserId,
    required int limit,
    required int page,
  });

  //---------------- REMOVE USER REPO --------------------
  Future<Either<SuccessMessageModel, ErrorMessageModel>> removeUser({
    required String token,
    required int userId,
  });

  //------------ CHANGE LAST MESSAGE TIME REPO -------------------
  Future<Either<SuccessMessageModel, ErrorMessageModel>> changeLastMessageTime({
    required int oppositeUserId,
    required String token,
  });
}
