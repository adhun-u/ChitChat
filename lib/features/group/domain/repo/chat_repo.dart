import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/features/group/data/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

abstract class GroupChatRepo {
  //-------------------- SEND MESSAGE REPO ------------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> sendMessage({
    required GroupChatModel groupChat,
    required int totalMembersCount,
    required String groupName,
    required String groupBio,
    required String groupImageUrl,
    required int groupAdminUserId,
    required String groupCreatedDate,
  });

  //------------------- GET STREAM DATA FROM FIRESTORE REPO ------------------------------
  Future<Either<Stream<QuerySnapshot>?, ErrorMessageModel?>> getStreamData({
    required int currentUserId,
  });

  //----------------- INCREASE SEEN USERS COUNT IN FIRESTORE REPO ---------------------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>>
  increaseSeenUsersCount({required String docId});

  //----------------- FETCH SINGLE DOCUMENT REPO -------------------
  Future<Either<Map<String, dynamic>?, ErrorMessageModel?>> fetchSingleDoc({
    required String chatId,
  });

  //------------------- DELETE SINGLE DOCUMENT REPO ------------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> deleteSingleDoc({
    required String docId,
  });

  //------------------ CHANGE SEEN INFO REPO ----------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> changeSeenInfo({
    required String docId,
  });

  //----------------- ADD SEEN INFO TO ALL MESSAGES REPO ---------------
  Future<void> addSeenInfoToAllMessages({
    required String groupId,
    required int currentUserId,
  });

  //----------------- DELETE MULTIPLE DOCUMENTS REPO ---------------------
  Future<void> deleteMultipleDocs({required int senderId});

  //------------------- SEND GROUP MESSAGE NOTIFICATION REPO -------------------
  Future<void> sendGroupMessageNotification({
    required String groupId,
    required String title,
    required String body,
    required String imageUrl,
    required String type,
    required String token,
  });

  //-------------------- ADD MEMBER TO FIRESTORE REPO -------------------
  Future<void> addMemberToFireStore({
    required int userId,
    required String groupId,
  });

  //-------------------- REMOVE MEMBER FROM FIRESTORE REPO -----------------
  Future<void> removeMemberFromFireStore({
    required String groupId,
    required int userId,
  });
}
