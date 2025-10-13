import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/domain/entities/message/message_entity.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:chitchat/features/search/data/models/searched_user_model.dart';
import 'package:chitchat/features/search/domain/entities/search_users/searched_user_entity.dart';
import 'package:chitchat/features/search/domain/repo/search_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class SearchRepoImple implements SearchRepo {
  //Base url
  final Dio _dio = Dio(BaseOptions(baseUrl: "$baseUrl/user"));

  //-------------- SEARCH USER REPO IMPLEMENTING -------------------------
  //For searching users using username
  @override
  Future<Either<List<SearchedUserModel>, ErrorMessageModel>> searchUser({
    required String username,
    required String token,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        '/search?username=$username&limit=$limit&page=$page',
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether response was success or failer
      //Success
      if (response.statusCode == 200) {
        //Checking if the userdetails is empty
        final users = response.data["users"] as List<dynamic>;
        if (users.isNotEmpty) {
          List<SearchedUserModel> searchedUsers =
              users.map((searchedUser) {
                final SearchedUserEntity searchedUserEntity =
                    SearchedUserEntity.fromJson(searchedUser);
                return SearchedUserModel(
                  profilePic: searchedUserEntity.profilePic,
                  userId: searchedUserEntity.userId,
                  username: searchedUserEntity.username,
                  bio: searchedUserEntity.bio,
                  isRequested: searchedUserEntity.isRequested,
                  isAdded: searchedUserEntity.isAdded,
                );
              }).toList();
          return left(searchedUsers);
        } else {
          return left([]);
        }
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
        return right(ErrorMessageModel(message: 'Something went wrong'));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: "Something went wrong"));
  }
}
