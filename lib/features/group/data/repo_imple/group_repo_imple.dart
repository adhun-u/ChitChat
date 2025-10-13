import 'dart:developer';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:chitchat/features/group/data/datasource/group_chat_storage.dart';
import 'package:chitchat/features/group/data/models/group_edited_model.dart';
import 'package:chitchat/features/group/data/models/group_model.dart';
import 'package:chitchat/features/group/data/repo_imple/group_chat_repo_imple.dart';
import 'package:chitchat/features/group/domain/entities/added_users/group_added_users_entity.dart';
import 'package:chitchat/features/group/domain/entities/chat_storage/group_chat_storage_model.dart';
import 'package:chitchat/features/group/domain/entities/edited_data/group_edited_entity.dart';
import 'package:chitchat/features/group/domain/entities/groups/groups_entity.dart';
import 'package:chitchat/features/group/domain/entities/request/fetch_requests/group_requested_users_entity.dart';
import 'package:chitchat/features/group/domain/entities/request/send_request/send_request_entity.dart';
import 'package:chitchat/features/group/domain/entities/search_group/search_group_entity.dart';
import 'package:chitchat/features/group/domain/repo/group_repo.dart';
import 'package:chitchat/features/home/data/models/added_user_model.dart';
import 'package:chitchat/features/home/domain/entities/added_user_only/added_users_only_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class GroupRepoImple implements GroupRepo {
  //Base url
  final Dio _dio = Dio(BaseOptions(baseUrl: "$baseUrl/group"));
  //Creating an instance of GroupChatStorage to access local chats
  final GroupChatStorage _storage = GroupChatStorage();
  //Creating an instance of FirebaseFirestore for accessing cloud database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //Creating an instance of GroupChatRepoImple to access some functions
  final GroupChatRepoImple _groupChatRepoImple = GroupChatRepoImple();

  //Group collection
  final String _groupCollec = "groups";

  //---------- CREATE GROUP REPO IMPLEMENTING ----------------
  //For creating a group
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> createGroup({
    required String token,
    required String groupName,
    required String groupBio,
    required String imagePath,
    required int currentUserId,
  }) async {
    try {
      //Data for creating group
      final FormData formData = FormData.fromMap({
        "groupName": groupName,
        "groupBio": groupBio,
        "groupImage":
            imagePath.isNotEmpty ? await MultipartFile.fromFile(imagePath) : "",
        "groupAdminUserId": currentUserId,
        "createdAt": DateTime.now().toUtc().toIso8601String(),
      });

      //Sending a request to create group
      final Response<dynamic> response = await _dio.post(
        "/create",
        data: formData,
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the response returns success or error
      if (response.statusCode == 200) {
        //Parsing the group id from the response
        final String groupId = response.data['groupId'];
        //Then creating a group in firestore
        final Map<String, dynamic> groupData = {
          "groupId": groupId,
          "members": [currentUserId],
        };
        final DocumentReference<Map<String, dynamic>> doc = await _firestore
            .collection(_groupCollec)
            .add(groupData);

        printDebug(doc);

        _groupChatRepoImple.groupMembersIds[groupId] = [currentUserId];

        return left(SuccessMessageModel(message: 'Group created successfully'));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //----------- FETCH GROUPS REPO IMPLEMENTING -------------
  //For fetching groups that current user created or joined
  @override
  Future<Either<List<GroupModel>?, ErrorMessageModel?>> fetchGroups({
    required String token,
    required int currentUserId,
    required int limit,
    required int page,
  }) async {
    try {
      //Sending a request to get all groups that current user created or joined
      final Response<dynamic> response = await _dio.get(
        "/get?limit=$limit&page=$page",
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the response was success or failer
      if (response.statusCode == 200) {
        final List<dynamic> groupsJson =
            response.data['groups'] as List<dynamic>;

        final List<GroupModel> groups =
            groupsJson.map((group) {
              final GroupsEntity groupEntity = GroupsEntity.fromJson(group);

              final GroupChatStorageModel? lastChat = _storage.fetchLastChat(
                groupId: groupEntity.groupId,
                shouldFetchCallHistory: false,
              );

              return GroupModel(
                groupId: groupEntity.groupId,
                groupName: groupEntity.groupName,
                groupImageUrl: groupEntity.groupImage ?? "",
                groupBio: groupEntity.groupBio ?? "",
                groupAdminUserId: groupEntity.groupAdminUserId,
                createdAt: groupEntity.createdAt,
                membersCount: groupEntity.groupMembersCount,
                isMe: lastChat != null && lastChat.senderId == currentUserId,
                isSeenLastMessage: lastChat != null && lastChat.isSeen,
                lastMessage:
                    lastChat != null
                        ? lastChat.messageType == "text"
                            ? lastChat.textMessage
                            : lastChat.messageType == "image"
                            ? lastChat.imageText
                            : ""
                        : "No messages yet",
                lastMessageTime: groupEntity.lastMessageTime,
                lastMessageType: lastChat != null ? lastChat.messageType : "",
                lastImageText: lastChat != null ? lastChat.imageText : "",
                unreadMessagesCount: _storage.getUnreadMessagesCount(
                  groupId: groupEntity.groupId,
                ),
              );
            }).toList();

        return left(groups);
      }
    } catch (e) {
      log('Catch error : $e');
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }

    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //------------- SEARCH GROUP REPO IMPLEMENTING --------------
  //For searching groups
  @override
  Future<Either<List<SearchGroupModel>?, ErrorMessageModel?>> searchGroup({
    required String token,
    required String groupName,
    required int limit,
    required int page,
  }) async {
    try {
      //Sending a request to get searched groups
      final Response<dynamic> result = await _dio.get(
        '/search?groupName=$groupName&limit=$limit&page=$page',
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the result is success or failer
      if (result.statusCode == 200) {
        //Parsing the groups from the result
        final List<dynamic> groupsJson =
            result.data['searchResult'] as List<dynamic>;

        List<SearchGroupModel> searchedGroups =
            groupsJson.map((json) {
              final SearchGroupEntity searchGroupEntity =
                  SearchGroupEntity.fromJson(json);
              return SearchGroupModel(
                groupId: searchGroupEntity.groupId,
                groupName: searchGroupEntity.groupName,
                groupImageUrl: searchGroupEntity.groupImage,
                groupBio: searchGroupEntity.groupBio,
                groupAdminUserId: searchGroupEntity.groupAdminUserId,
                isCurrentUserAdded: searchGroupEntity.isCurrentUserAdded,
                isRequestSent: searchGroupEntity.isRequestSent,
              );
            }).toList();

        return left(searchedGroups);
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //----------------- REQUEST GROUP REPO IMPLEMENTING ------------------
  //For sending a request to join in a group
  @override
  Future<Either<String?, ErrorMessageModel?>> requestGroup({
    required String token,
    required String groupName,
    required String groupId,
    required int groupAdminId,
  }) async {
    try {
      //Sending a request to add a request for a group
      final Response<dynamic> response = await _dio.post(
        '/request',
        data:
            SendRequestEntity(
              adminId: groupAdminId,
              groupId: groupId,
              groupName: groupName,
            ).toJson(),
        options: Options(headers: getHeaders(token: token)),
      );
      //Checking whether the response was success or not
      if (response.statusCode == 200) {
        return left(response.data['groupId']);
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }

    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //----------- FETCH GROUP ADDED USERS REPO IMPLEMENTING ------------
  //For fetching group members
  @override
  Future<Either<List<GroupAddedUserModel>?, ErrorMessageModel?>>
  fetchGroupAddedUsers({
    required String token,
    required String groupId,
    required int limit,
    required int page,
  }) async {
    try {
      //Sending a request to fetch all users of a group
      final Response<dynamic> response = await _dio.get(
        "/addedUsers?groupId=$groupId&limit=$limit&page=$page",
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the response was success or not
      if (response.statusCode == 200) {
        final List<dynamic> addedUsersJson =
            response.data['addedUsers'] as List<dynamic>;

        //Parsing json data to GroupAddedUserModel
        List<GroupAddedUserModel> addedUsers =
            addedUsersJson.map((json) {
              final GroupAddedUsersEntity addedUsersEntity =
                  GroupAddedUsersEntity.fromJson(json);
              return GroupAddedUserModel(
                username: addedUsersEntity.username,
                userId: addedUsersEntity.userId,
                profilePic: addedUsersEntity.imageUrl,
                userBio: addedUsersEntity.bio,
              );
            }).toList();

        return left(addedUsers);
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }

    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //------------ FETCH GROUP REQUESTS REPO IMLEMENTING ----------------
  //For fetching group requests
  @override
  Future<Either<List<GroupRequestUserModel>?, ErrorMessageModel?>>
  fetchGroupRequests({
    required String token,
    required String groupId,
    required int limit,
    required int page,
  }) async {
    try {
      //Sending a request to get all requests of a group
      final Response<dynamic> response = await _dio.get(
        "/requests?groupId=$groupId&limit=$limit&page=$page",
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking whether the response was success not not
      if (response.statusCode == 200) {
        //Parsing the json data to GroupRequestUserModel
        final List<dynamic> jsonList =
            response.data['requests'] as List<dynamic>;

        List<GroupRequestUserModel> requests =
            jsonList.map((json) {
              final GroupRequestedUsersEntity entity =
                  GroupRequestedUsersEntity.fromJson(json);
              return GroupRequestUserModel(
                groupId: entity.groupId,
                groupName: entity.groupName,
                username: entity.username,
                imageUrl: entity.imageUrl,
                userId: entity.userId,
                userBio: entity.userbio,
              );
            }).toList();
        return left(requests);
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //---------------- EDIT GROUP INFO REPO IMPLEMENTING -----------------
  //For editing group image , group bio and group name
  @override
  Future<Either<GroupEditedModel, ErrorMessageModel>> editGroupInfo({
    required String token,
    required String groupId,
    required String newGroupName,
    required String newGroupBio,
    required String newGroupImagePath,
  }) async {
    try {
      //Converting all data to into form data
      final FormData groupData = FormData.fromMap({
        "groupId": groupId,
        "groupName": newGroupName,
        "groupImage":
            newGroupImagePath.isNotEmpty
                ? await MultipartFile.fromFile(newGroupImagePath)
                : "",
        "groupBio": newGroupBio,
      });

      //Sending a request to edit a group info
      final Response<dynamic> response = await _dio.patch(
        '/edit',
        data: groupData,
        options: Options(headers: getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        log("Response : ${response.data}");
        //Parsing the data after edited
        final GroupEditedEntity groupEditedEntity = GroupEditedEntity.fromJson(
          response.data,
        );
        return left(
          GroupEditedModel(
            groupId: groupId,
            newGroupName: groupEditedEntity.newGroupName,
            newGroupBio: groupEditedEntity.newGroupBio,
            newGroupImageUrl: groupEditedEntity.newGroupImageUrl,
          ),
        );
      }
    } catch (e) {
      log("Error : $e");
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //---------------- ADD MEMBER REPO IMPLEMENTING -------------
  //For adding a member to a group
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> addMember({
    required String token,
    required String groupId,
    required int userId,
  }) async {
    try {
      //Sending a request to add a member to a group
      final Response<dynamic> response = await _dio.post(
        '/add?groupId=$groupId&userId=$userId',
        options: Options(headers: getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        await _groupChatRepoImple.addMemberToFireStore(
          groupId: groupId,
          userId: userId,
        );
        return left(SuccessMessageModel(message: 'Added successfully'));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //-------------------- ACCEPT GROUP REQUEST REPO IMPLEMENTING --------------------
  //For accepting a group request
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> acceptGroupRequest({
    required String token,
    required int userId,
    required String groupId,
    required String groupName,
    required String groupImage,
  }) async {
    try {
      final String currentTime = DateTime.now().toUtc().toIso8601String();
      //Sending a request to accept a group request to join
      final Response<dynamic> response = await _dio.post(
        "/acceptRequest?groupId=$groupId&userId=$userId&groupName=$groupName&groupImage=$groupImage&time=$currentTime",
        options: Options(headers: getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        await _groupChatRepoImple.addMemberToFireStore(
          groupId: groupId,
          userId: userId,
        );
        return left(SuccessMessageModel(message: 'Accepted request'));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }

    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //------------------ DECLINE GROUP REQUEST REPO IMPLEMENTING ---------------------------
  //For declining a group request to join
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> declineGroupRequest({
    required String token,
    required int userId,
    required String groupId,
  }) async {
    try {
      //Sending a request to decline a group request
      final Response<dynamic> response = await _dio.delete(
        "/declineRequest?groupId=$groupId&userId=$userId",
        options: Options(headers: getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return left(SuccessMessageModel(message: 'Declined successfully'));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //-------------- REMOVE GROUP MEMBER REPO IMPLEMENTING -----------------
  //For removing a member from a group
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> removeGroupMember({
    required String token,
    required String groupId,
    required int userId,
  }) async {
    try {
      //Sending a request to remove a member from a group
      final Response<dynamic> response = await _dio.delete(
        "/delete/user?groupId=$groupId&userId=$userId",
        options: Options(headers: getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        await _groupChatRepoImple.removeMemberFromFireStore(
          groupId: groupId,
          userId: userId,
        );
        return left(SuccessMessageModel(message: 'Removed successfully'));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //---------------- FETCH ADDED USERS ONLY REPO IMPLEMENTING -----------------
  //For fetching added users whithout last messages
  @override
  Future<Either<List<AddedUserOnlyModel>?, ErrorMessageModel?>>
  fetchUsersToAddMember({
    required String token,
    required int limit,
    required int page,
    required String groupId,
  }) async {
    try {
      //Sending a request for fetching added users only
      final Response<dynamic> response = await _dio.get(
        '/users?groupId=$groupId&limit=$limit&page=$page',
        options: Options(headers: getHeaders(token: token)),
      );
      //Checking whether the response was success or failer
      if (response.statusCode == 200) {
        List<dynamic> jsonList = response.data['addedUsers'] as List<dynamic>;

        //Parsing all data
        List<AddedUserOnlyModel> addedUsers =
            jsonList.map((json) {
              final AddedUsersOnlyEntity entity = AddedUsersOnlyEntity.fromJson(
                json,
              );
              return AddedUserOnlyModel(
                userId: entity.userId,
                username: entity.username,
                userBio: entity.userBio ?? "",
                profilePic: entity.profilePic ?? "",
              );
            }).toList();

        return left(addedUsers);
      }
    } catch (e) {
      printDebug("Fetch users to add member error : $e");
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //------------------ LEAVE GROUP REPO IMPLEMENTING --------------
  //For leaving from a group
  @override
  Future<Either<SuccessMessageModel, ErrorMessageModel>> leaveGroup({
    required String groupId,
    required String token,
    required int currentMembersCount,
    required int currentUserId,
  }) async {
    try {
      //Sending a request to remove current user from specific group
      final Response<dynamic> response = await _dio.delete(
        "/exit?groupId=$groupId&membersCount=$currentMembersCount",
        options: Options(headers: getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        await _groupChatRepoImple.removeMemberFromFireStore(
          groupId: groupId,
          userId: currentUserId,
        );
        return left(SuccessMessageModel(message: 'Left successfully'));
      }
    } catch (e) {
      log(e.toString());
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //-------------------- CHANGE LAST MESSAGE TIME REPO IMPLEMENTING -------------
  //For changing last message time to sort quickly
  @override
  Future<Either<SuccessMessageModel, ErrorMessageModel>> changeLastMessageTime({
    required String time,
    required String groupId,
    required String token,
  }) async {
    try {
      final Response<dynamic> response = await _dio.patch(
        "/changeTime?time=$time&groupId=$groupId",
        options: Options(headers: getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return left(SuccessMessageModel(message: 'Time changed successfully'));
      }
    } catch (e) {
      printDebug("Change last message repo error : $e");
      return right(ErrorMessageModel(message: "Something went wrong"));
    }
    return right(ErrorMessageModel(message: "Something went wrong"));
  }
}
