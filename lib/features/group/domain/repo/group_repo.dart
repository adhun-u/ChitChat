import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/features/group/data/models/group_edited_model.dart';
import 'package:chitchat/features/group/data/models/group_model.dart';
import 'package:chitchat/features/home/data/models/added_user_model.dart';
import 'package:dartz/dartz.dart';

abstract class GroupRepo {
  //------------- CREATE GROUP REPO -----------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> createGroup({
    required String token,
    required String groupName,
    required String groupBio,
    required String imagePath,
    required int currentUserId,
  });

  //--------------- FETCH GROUP REPO -----------
  Future<Either<List<GroupModel>?, ErrorMessageModel?>> fetchGroups({
    required String token,
    required int currentUserId,
    required int limit,
    required int page,
  });

  //---------------- SEARCH GROUP REPO ------------
  Future<Either<List<SearchGroupModel>?, ErrorMessageModel?>> searchGroup({
    required String token,
    required String groupName,
    required int limit,
    required int page,
  });

  //--------------- REQUEST GROUP REPO ---------------
  Future<Either<String?, ErrorMessageModel?>> requestGroup({
    required String token,
    required String groupName,
    required String groupId,
    required int groupAdminId,
  });

  //---------------- GROUP ADDED USERS REPO ------------
  Future<Either<List<GroupAddedUserModel>?, ErrorMessageModel?>>
  fetchGroupAddedUsers({
    required String token,
    required String groupId,
    required int limit,
    required int page,
  });

  //--------------- FETCH GROUP REQUESTS REPO ---------------
  Future<Either<List<GroupRequestUserModel>?, ErrorMessageModel?>>
  fetchGroupRequests({
    required String token,
    required String groupId,
    required int limit,
    required int page,
  });

  //---------------- EDIT GROUP REPO -----------------
  Future<Either<GroupEditedModel, ErrorMessageModel>> editGroupInfo({
    required String token,
    required String groupId,
    required String newGroupName,
    required String newGroupBio,
    required String newGroupImagePath,
  });

  //--------------- ADD MEMBER REPO -------------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> addMember({
    required String token,
    required String groupId,
    required int userId,
  });

  //--------------- ACCEPT GROUP REQUEST REPO ---------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> acceptGroupRequest({
    required String token,
    required int userId,
    required String groupId,
    required String groupName,
    required String groupImage,
  });

  //--------------- DECLINE GROUP REQUEST REPO ----------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> declineGroupRequest({
    required String token,
    required int userId,
    required String groupId,
  });

  //--------------- REMOVE GROUP MEMBER REPO ----------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> removeGroupMember({
    required String token,
    required String groupId,
    required int userId,
  });

  //--------------- FETCH USERS TO ADD MEMBER REPO -------------------
  Future<Either<List<AddedUserOnlyModel>?, ErrorMessageModel?>>
  fetchUsersToAddMember({
    required String token,
    required int limit,
    required int page,
    required String groupId,
  });

  //------------------- LEAVE GROUP REPO ------------------
  Future<Either<SuccessMessageModel, ErrorMessageModel>> leaveGroup({
    required String groupId,
    required String token,
    required int currentMembersCount,
    required int currentUserId,
  });

  //--------------------- CHANGE LAST MESSAGE TIME REPO ---------------
  Future<Either<SuccessMessageModel, ErrorMessageModel>> changeLastMessageTime({
    required String time,
    required String groupId,
    required String token,
  });
}
