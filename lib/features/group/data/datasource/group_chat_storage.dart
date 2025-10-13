import 'dart:developer';
import 'package:chitchat/common/application/database_service.dart';
import 'package:chitchat/features/group/domain/entities/chat_storage/group_chat_storage_model.dart';
import 'package:chitchat/objectbox.g.dart';

class GroupChatStorage {
  final Store? _store = DatabaseService.obxStore;
  //For saving a group chat to object box
  void saveGroupChat(GroupChatStorageModel groupChat) {
    if (_store != null) {
      _store.box<GroupChatStorageModel>().put(groupChat);
    }
  }

  //For fetching all group chats of a group using the id of group
  List<GroupChatStorageModel> fetchGroupChats({required String groupId}) {
    if (_store == null) {
      return [];
    }

    final List<GroupChatStorageModel> groupChats =
        _store
            .box<GroupChatStorageModel>()
            .query(GroupChatStorageModel_.groupId.equals(groupId))
            .build()
            .find();
    return groupChats;
  }

  //For clearing all chats using a group id
  void clearAllChat({required String groupId}) {
    if (_store != null) {
      final QueryBuilder query = _store.box<GroupChatStorageModel>().query(
        GroupChatStorageModel_.groupId.equals(groupId),
      );

      //Finding primary key using above key
      final List<int> ids = query.build().findIds();

      //Deleting all chats using above ids
      _store.box<GroupChatStorageModel>().removeMany(ids);
    }
  }

  //For editing seen status as true
  void changeSeenStatus({required int senderId, required String groupId}) {
    if (_store == null) {
      return;
    }

    final List<GroupChatStorageModel> unSeenChats =
        _store
            .box<GroupChatStorageModel>()
            .query(
              GroupChatStorageModel_.senderId.equals(senderId) &
                  GroupChatStorageModel_.groupId.equals(groupId) &
                  GroupChatStorageModel_.isSeen.equals(false),
            )
            .build()
            .find();

    //Changing one by one
    for (var unSeenChat in unSeenChats) {
      log("yes there are unseen messages");
      unSeenChat.isSeen = true;
    }
    //Then putting new chats
    final List<int> ids = _store.box<GroupChatStorageModel>().putMany(
      unSeenChats,
      mode: PutMode.update,
    );

    log('IDS : $ids');
  }

  //For knowning if there is any unseen message
  List<GroupChatStorageModel> isThereAnyUnseenMessages({
    required String groupId,
    required int senderId,
  }) {
    if (_store == null) {
      return [];
    }
    final Query<GroupChatStorageModel> query =
        _store
            .box<GroupChatStorageModel>()
            .query(
              GroupChatStorageModel_.groupId.equals(groupId) &
                  GroupChatStorageModel_.senderId.equals(senderId) &
                  GroupChatStorageModel_.isSeen.equals(false),
            )
            .build();

    query.limit = 1;
    final List<GroupChatStorageModel> data = query.find();
    return data;
  }

  //For getting single chat using chatId
  GroupChatStorageModel? getSingleChat({
    required String groupId,
    required String chatId,
  }) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      final List<GroupChatStorageModel> chats =
          store
              .box<GroupChatStorageModel>()
              .query(
                GroupChatStorageModel_.groupId.equals(groupId) &
                    GroupChatStorageModel_.chatId.equals(chatId),
              )
              .build()
              .find();
      return chats.isNotEmpty ? chats[0] : null;
    }
    return null;
  }

  //For changing isRead as true
  void changeReadStatus({required String groupId, required int currentUserId}) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      final List<GroupChatStorageModel> unReadMessages =
          store
              .box<GroupChatStorageModel>()
              .query(
                GroupChatStorageModel_.groupId.equals(groupId) &
                    GroupChatStorageModel_.senderId.notEquals(currentUserId) &
                    GroupChatStorageModel_.isRead.equals(false),
              )
              .build()
              .find();

      for (var chat in unReadMessages) {
        chat.isRead = true;
      }

      store.box<GroupChatStorageModel>().putMany(
        unReadMessages,
        mode: PutMode.update,
      );
    }
  }

  //For removing single chat from storage using chat id
  void deleteChat({required String chatId}) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      store
          .box<GroupChatStorageModel>()
          .query(GroupChatStorageModel_.chatId.equals(chatId))
          .build()
          .remove();
    }
  }

  //For deleting selected chats
  void deleteSelectedChats({required List<String> ids}) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      final Query query =
          store
              .box<GroupChatStorageModel>()
              .query(GroupChatStorageModel_.chatId.oneOf(ids))
              .build();

      query.remove();
    }
  }

  //For fetching media items
  List<GroupChatStorageModel> fetchMediaItems({
    required String groupId,
    int? limit,
  }) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      final Query<GroupChatStorageModel> query =
          store
              .box<GroupChatStorageModel>()
              .query(
                GroupChatStorageModel_.groupId.equals(groupId) &
                    (GroupChatStorageModel_.messageType.equals("image") |
                        GroupChatStorageModel_.messageType.equals("audio")),
              )
              .build();

      if (limit != null) {
        query.limit = limit;
      }
      return query.find();
    } else {
      return [];
    }
  }

  //For fetching last group chat only
  GroupChatStorageModel? fetchLastChat({
    required String groupId,
    required bool shouldFetchCallHistory,
  }) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      final Condition<GroupChatStorageModel> conditionDontFetchCallHistory =
          !shouldFetchCallHistory
              ? (GroupChatStorageModel_.messageType.notEquals("audioCall") &
                  GroupChatStorageModel_.messageType.notEquals("videoCall"))
              : (GroupChatStorageModel_.messageType.equals("audioCall") &
                  GroupChatStorageModel_.messageType.equals("videoCall"));
      final GroupChatStorageModel? lastChat =
          store
              .box<GroupChatStorageModel>()
              .query(
                GroupChatStorageModel_.groupId.equals(groupId) &
                    conditionDontFetchCallHistory,
              )
              .order(GroupChatStorageModel_.time, flags: Order.descending)
              .build()
              .findFirst();

      return lastChat;
    } else {
      return null;
    }
  }

  //For getting unread messages count
  int getUnreadMessagesCount({required String groupId}) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      final Condition<GroupChatStorageModel> conditionToNotCount =
          (GroupChatStorageModel_.messageType.notEquals("audioCall") &
              GroupChatStorageModel_.messageType.notEquals("videoCall"));
      final int count =
          store
              .box<GroupChatStorageModel>()
              .query(
                GroupChatStorageModel_.groupId.equals(groupId) &
                    GroupChatStorageModel_.isRead.equals(false) &
                    conditionToNotCount,
              )
              .build()
              .count();
      return count;
    } else {
      return 0;
    }
  }
}
