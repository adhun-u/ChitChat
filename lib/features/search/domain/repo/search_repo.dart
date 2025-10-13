import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/features/search/data/models/searched_user_model.dart';
import 'package:dartz/dartz.dart';

abstract class SearchRepo {

  //------------ SEARCH A USER REPO -----------------------
  Future<Either<List<SearchedUserModel>, ErrorMessageModel>> searchUser({
    required String username,
    
    required String token,
    required int page,
    required int limit,
  });
}
