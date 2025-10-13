import 'dart:developer';

import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:chitchat/features/home/data/datasource/chat_storage.dart';
import 'package:chitchat/features/home/data/models/added_user_model.dart';
import 'package:chitchat/features/home/domain/entities/added_user_with_last_message/added_users_with_last_message_entity.dart';
import 'package:chitchat/features/home/domain/entities/chat_storage/chat_storage_entity.dart';
import 'package:chitchat/features/home/domain/repo/user_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class UserRepoImple implements UserRepo {
  //BaseUrl
  final Dio _dio = Dio(BaseOptions(baseUrl: "$baseUrl/user"));
  //Creating an instance of ChatStorageDB for accessing chats
  final ChatStorageDB _chatStorage = ChatStorageDB();

  //------------ FETCH ADDED USERS WITH LAST MESSAGE REPO IMPLEMENTING -------------------
  //For fetching added users with their last message
  @override
  Future<Either<List<AddedUserWithLastMessageModel>?, ErrorMessageModel?>>
  fetchAddedUsersWithLastMessage({
    required String token,
    required int currentUserId,
    required int limit,
    required int page,
  }) async {
    try {
      //Sending a request to fetch added users with last message
      final response = await _dio.get(
        '/friendsWithLastMessage?limit=$limit&page=$page',
        options: Options(headers: getHeaders(token: token)),
      );
      //Checking whether the response was success or failer
      //Success
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data['addedUsers'];
        //Checking if the responseData is empty
        if (responseData.isEmpty) {
          return left([]);
        }

        //Parsing the user details from response
        List<AddedUserWithLastMessageModel> addedUsers =
            responseData.map((addedUser) {
              final AddedUsersWithLastMessageEntity addedUsersEntity =
                  AddedUsersWithLastMessageEntity.fromJson(addedUser);

              final ChatStorageDBModel? lastChat = _chatStorage.getLastMessage(
                receiverId: addedUsersEntity.userId,
                currentUserId: currentUserId,
                shouldFetchAudioAndVideoCall: false,
              );
              //Getting unread message count from chat storage
              final int unreadMessageCount = _chatStorage.getUnreadMessageCount(
                receiverId: addedUsersEntity.userId,
                currentUserId: currentUserId,
              );

              return AddedUserWithLastMessageModel(
                userId: addedUsersEntity.userId,
                username: addedUsersEntity.username,
                userbio: addedUsersEntity.bio ?? "",
                profilePic: addedUsersEntity.profilePic,
                isSeen:
                    lastChat != null && lastChat.senderId == currentUserId
                        ? lastChat.isSeen
                        : false,
                isMe:
                    lastChat != null
                        ? lastChat.senderId == currentUserId
                        : false,
                lastMessage:
                    addedUsersEntity.messageType.isNotEmpty
                        ? addedUsersEntity.messageType == "text"
                            ? addedUsersEntity.lastPendingMessage
                            : addedUsersEntity.messageType == "image"
                            ? addedUsersEntity.imageText
                            : ""
                        : lastChat != null
                        ? lastChat.type == "text"
                            ? lastChat.message!
                            : lastChat.type == "image"
                            ? lastChat.imageText ?? ""
                            : ""
                        : "No messages yet",
                lastTime: addedUsersEntity.time,
                unreadMessageCount:
                    addedUsersEntity.pendingMessageCount != 0
                        ? addedUsersEntity.pendingMessageCount
                        : unreadMessageCount,
                messageType:
                    addedUsersEntity.messageType.isNotEmpty
                        ? addedUsersEntity.messageType
                        : lastChat != null
                        ? lastChat.type
                        : "",
              );
            }).toList();

        return left(addedUsers);
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //-------------- REMOVE USER REPO IMPLEMENTING ---------------------------
  //For removing specific user
  @override
  Future<Either<SuccessMessageModel, ErrorMessageModel>> removeUser({
    required String token,
    required int userId,
  }) async {
    try {
      final Response<dynamic> response = await _dio.delete(
        "/remove?removeUserId=$userId",
        options: Options(headers: getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return left(SuccessMessageModel(message: 'Removed successfully'));
      }
    } catch (e) {
      printDebug(
        "Error from remove user : ${e is DioException ? e.response?.data : "null"}",
      );
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //------------------- CHANGE LAST MESSAGE TIME REPO IMPLEMENTING --------------
  //For change last message time of a user to sort
  @override
  Future<Either<SuccessMessageModel, ErrorMessageModel>> changeLastMessageTime({
    required int oppositeUserId,
    required String token,
  }) async {
    try {
      final Response<dynamic> response = await _dio.patch(
        "/lastMessageTime?userId=$oppositeUserId&time=${DateTime.now().toUtc().toIso8601String()}",
        options: Options(headers: getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return left(SuccessMessageModel(message: 'Time updated successfully'));
      }
    } catch (e) {
      log(
        "Error from remove user : ${e is DioException ? e.response?.data : "null"}",
      );
      return right(ErrorMessageModel(message: "Something went wrong"));
    }
    return right(ErrorMessageModel(message: "Something went wrong"));
  }
}
