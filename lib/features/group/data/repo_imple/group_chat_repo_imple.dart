

import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:chitchat/features/group/data/datasource/group_chat_storage.dart';
import 'package:chitchat/features/group/data/models/chat_model.dart';
import 'package:chitchat/features/group/domain/entities/chat_storage/group_chat_storage_model.dart';
import 'package:chitchat/features/group/domain/repo/chat_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class GroupChatRepoImple extends GroupChatRepo {
  //Base url
  final Dio _dio = Dio(BaseOptions(baseUrl: "$baseUrl/group"));
  //Creating an instance of FirebaseFireStore for adding a message to the database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //Creating an instance of GroupChatStorage
  final GroupChatStorage _storage = GroupChatStorage();
  //Group collection
  final String _groupCollec = "groups";
  //Message collection
  final String _messageCollec = "messages";
  //Group members ids
  final Map<String, List<dynamic>> groupMembersIds = {};

  //------------------------ ADD MEMBER TO FIRESTORE REPO IMPLEMENTING ---------------
  //For adding a user id to members array of a document
  @override
  Future<void> addMemberToFireStore({
    required int userId,
    required String groupId,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> query =
          await _firestore
              .collection(_groupCollec)
              .where("groupId", isEqualTo: groupId)
              .limit(1)
              .get();
      final QueryDocumentSnapshot<Map<String, dynamic>>? doc =
          query.docs.firstOrNull;

      if (doc != null) {
        await _firestore.collection(_groupCollec).doc(doc.id).update({
          "members": FieldValue.arrayUnion([userId]),
        });
        final List<dynamic> membersIds = groupMembersIds[groupId] ?? [];
        membersIds.add(userId);
        groupMembersIds[groupId] = membersIds;

        printDebug("Group members id after added : $membersIds");
      }
    } catch (e) {
      printDebug("Add member to firestore error : $e");
    }
  }

  //----------------------- REMOVE MEMBER FROM FIRESTORE REPO IMPLEMENTING ----------------
  //For removing a user id from members array of a document
  @override
  Future<void> removeMemberFromFireStore({
    required String groupId,
    required int userId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> query =
        await _firestore
            .collection(_groupCollec)
            .where("groupId", isEqualTo: groupId)
            .get();

    final QueryDocumentSnapshot<Map<String, dynamic>>? doc =
        query.docs.firstOrNull;

    if (doc != null) {
      await _firestore.collection(_groupCollec).doc(doc.id).update({
        "members": FieldValue.arrayRemove([userId]),
      });

      final List<dynamic> membersIds = groupMembersIds[groupId] ?? [];
      membersIds.remove(userId);
      groupMembersIds[groupId] = membersIds;

      printDebug("Group membersids after removed it : $membersIds");
    }
  }

  //-------------- SEND MESSAGE REPO IMPLEMENTING -------------------
  //For adding a message to firebase store
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> sendMessage({
    required GroupChatModel groupChat,
    required int totalMembersCount,
    required String groupName,
    required String groupBio,
    required String groupImageUrl,
    required int groupAdminUserId,
    required String groupCreatedDate,
  }) async {
    try {
      if (groupMembersIds[groupChat.groupId] == null) {
        final QuerySnapshot<Map<String, dynamic>> query =
            await _firestore
                .collection(_groupCollec)
                .where("groupId", isEqualTo: groupChat.groupId)
                .limit(1)
                .get();
        final QueryDocumentSnapshot<Map<String, dynamic>>? doc =
            query.docs.firstOrNull;

        if (doc != null) {
          groupMembersIds[groupChat.groupId] = doc.data()['members'];
        }
      }

      printDebug(
        "Group members ids before sending message : ${groupMembersIds[groupChat.groupId]}",
      );
      //Group message for inserting the collection
      final Map<String, dynamic> groupMessage = {
        "groupName": groupName,
        "groupBio": groupBio,
        "groupImageUrl": groupImageUrl,
        "groupId": groupChat.groupId,
        "groupAdminUserId": groupAdminUserId,
        "members": groupMembersIds[groupChat.groupId],
        "createdAt": groupCreatedDate,
        "senderId": groupChat.senderId,
        "senderName": groupChat.senderName,
        "chatId": groupChat.chatId,
        "messageType": groupChat.messageType,
        "textMessage": groupChat.textMessage,
        "imageUrl": groupChat.imageUrl,
        "imageText": groupChat.imageText,
        "audioUrl": groupChat.audioUrl,
        "audioDuration": groupChat.audioDuration,
        "audioTitle": groupChat.audioTitle,
        "voiceUrl": groupChat.voiceUrl,
        "voiceDuration": groupChat.voiceDuration,
        "videoUrl": groupChat.videoUrl,
        "videoDuration": groupChat.voiceDuration,
        "videoTitle": groupChat.videoTitle,
        "seenUsersCount": 1,
        "isSeen": false,
        "totalMembersCount": totalMembersCount,
        "time": groupChat.time,
        "repliedMessage": groupChat.repliedMessage,
        "parentMessageSenderId": groupChat.parentMessageSenderId,
        "parentMessageSenderName": groupChat.parentMessageSenderName,
        "parentMessageType": groupChat.parentMessageType,
        "parentText": groupChat.parentText,
        "parentVoiceDuration": groupChat.voiceDuration,
        "parentAudioDuration": groupChat.audioDuration,
      };

      await _firestore.collection(_messageCollec).add(groupMessage);

      return left(SuccessMessageModel(message: 'Message sent successfully'));
    } catch (e) {
      printDebug('Group chat catch error : $e');
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
  }

  //--------------- GET STREAM DATA FROM FIRESTORE REPO IMPLEMENTING ------------
  //For getting all messages from firestore
  @override
  Future<Either<Stream<QuerySnapshot<Object?>>?, ErrorMessageModel?>>
  getStreamData({required int currentUserId}) async {
    try {
      final Stream<QuerySnapshot> streamData = _firestore
          .collection(_messageCollec)
          .where("members", arrayContains: currentUserId)
          .snapshots(includeMetadataChanges: true);
      return left(streamData);
    } catch (e) {
      printDebug('Firebase stream error : $e');
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
  }

  //----------------- INCREASE SEEN USERS COUNT IN FIRESTORE REPO IMPLEMENTING ------------
  //For increasing the seenUsers count and insert new data in readUsers map
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>>
  increaseSeenUsersCount({required String docId}) async {
    try {
      //Updating the seenUsers count
      await _firestore.collection(_messageCollec).doc(docId).update({
        "seenUsersCount": FieldValue.increment(1),
      });
      return left(SuccessMessageModel(message: 'Changed successfully'));
    } catch (e) {
      printDebug("Increase seen users count error :$e");
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
  }

  //-------------- FETCH SINGLE DOCUMENT REPO IMPLEMENTING ------------------
  //For fetching a single document
  @override
  Future<Either<Map<String, dynamic>?, ErrorMessageModel?>> fetchSingleDoc({
    required String chatId,
  }) async {
    try {
      //Fetching the message using chat id
      final DocumentSnapshot<Map<String, dynamic>> messageData =
          await _firestore.collection(_messageCollec).doc(chatId).get();

      return left(messageData.data());
    } catch (e) {
      printDebug('Fetch single doc error : $e');
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
  }

  //--------------------------- DELETE SINGLE DOCUMENT REPO IMPLEMENTING ---------------
  //For deleting single document using the document id
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> deleteSingleDoc({
    required String docId,
  }) async {
    try {
      await _firestore.collection(_messageCollec).doc(docId).delete();
      return left(SuccessMessageModel(message: 'Deleted successfully'));
    } catch (e) {
      printDebug("Delete single doc error : $e");
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
  }

  //--------------------- CHANGE SEEN INFO REPO IMPLEMENTING -----------------
  //For changing seen info of a message as true
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> changeSeenInfo({
    required String docId,
  }) async {
    try {
      //Changing isSeen field of a document as true
      await _firestore.collection(_messageCollec).doc(docId).update({
        "isSeen": true,
      });
      return left(SuccessMessageModel(message: 'Changed successfully'));
    } catch (e) {
      printDebug('Change seen info error : $e');
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
  }

  //------------------ ADD SEEN INFO TO ALL MESSAGES REPO IMPLEMENTING -------------
  //For increasing seen users count when current enters app
  @override
  Future<void> addSeenInfoToAllMessages({
    required String groupId,
    required int currentUserId,
  }) async {
    try {
      //Creating a batch for update all documents within single request
      WriteBatch writeBatch = _firestore.batch();
      //Batch size for taking only limited docs to update first time
      final int batchSize = 500;
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      //Fetching unread messages from local storage

      do {
        querySnapshot =
            await _firestore
                .collection(_messageCollec)
                .limit(batchSize)
                .where("senderId", isNotEqualTo: currentUserId)
                .get();

        for (var chat in querySnapshot.docs) {
          final int seenUsersCount = chat.data()['seenUsersCount'];
          final int totalMembersCount = chat.data()['totalMembersCount'];
          final String chatId = chat.data()['chatId'];
          /*Fetching the chat from local storage for knowing
          if the chat exists and chat id from local storage is same as chat id from firebase*/
          final GroupChatStorageModel? storageChat = _storage.getSingleChat(
            groupId: groupId,
            chatId: chatId,
          );
          //If everyone saw the message , then changing the isSeen as true otherwise increasing the count
          if (seenUsersCount + 1 == totalMembersCount &&
              storageChat != null &&
              storageChat.chatId == chatId &&
              storageChat.isRead == false) {
            //Adding to all documents into batch that are changed
            writeBatch.update(chat.reference, {"isSeen": true});
          } else if (storageChat != null &&
              storageChat.chatId == chatId &&
              storageChat.isRead == false) {
            //Adding to all documents into batch that are increased the count of seen users
            writeBatch.update(chat.reference, {
              "seenUsersCount": FieldValue.increment(1),
            });
          }
        }
        //Then updating all documents within single request
        if (querySnapshot.docs.isNotEmpty) {
          await writeBatch.commit();
          //After the first 500 docs are updated , refreshing the batch get next 500 docs
          writeBatch = _firestore.batch();
        }
      } while (querySnapshot.docs.length == batchSize);
    } catch (e) {
      printDebug("Add seen info error : $e");
    }
  }

  //---------------------- DELETE MULTIPLE DOCUMENTS REPO IMPLEMENTING ----------------
  //For deleting multiple documents using senderId
  @override
  Future<void> deleteMultipleDocs({required int senderId}) async {
    try {
      //Creating a batch for deleting all documents via single request
      WriteBatch writeBatch = _firestore.batch();
      //Batch size taking only 500 docs at a time
      final int batchSize = 500;
      //For getting current user's chat
      late QuerySnapshot<Map<String, dynamic>> chatsOfCurrentUser;
      do {
        chatsOfCurrentUser =
            await _firestore
                .collection(_messageCollec)
                .where("senderId", isEqualTo: senderId)
                .limit(batchSize)
                .get();

        for (var doc in chatsOfCurrentUser.docs) {
          //Adding each document in batch to delete
          writeBatch.delete(doc.reference);
        }
        if (chatsOfCurrentUser.docs.isNotEmpty) {
          //Sending to firebase to delete the all documents that are added in batch
          await writeBatch.commit();
          //Refreshing the batch to delete next 500 docs
          writeBatch = _firestore.batch();
        }
      } while (chatsOfCurrentUser.docs.length == batchSize);
    } catch (e) {
      printDebug("Delete multiple docs error : $e");
    }
  }

  //----------------------- SEND GROUP MESSAGE NOTIFICATION REPO IMPLEMENTING ---------------
  //For sending group message notification for those who are not in chat
  @override
  Future<void> sendGroupMessageNotification({
    required String groupId,
    required String title,
    required String body,
    required String imageUrl,
    required String type,
    required String token,
  }) async {
    try {
      //Data to send notification
      final Map<String, dynamic> notificationData = {
        "groupId": groupId,
        "title": title,
        "body": body,
        "messageType": type,
        "groupProfilePic": imageUrl,
      };
      final Response<dynamic> res = await _dio.post(
        "/notification",
        options: Options(headers: getHeaders(token: token)),
        data: notificationData,
      );

      if (res.statusCode == 200) {
        printDebug('Notification data : ${res.data}');
      }
    } catch (e) {
      printDebug('Sending notification error : $e');
    }
  }
}
