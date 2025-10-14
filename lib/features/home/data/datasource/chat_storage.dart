import 'package:chitchat/common/application/database_service.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/features/home/domain/entities/chat_storage/chat_storage_entity.dart';
import 'package:chitchat/objectbox.g.dart';

class ChatStorageDB {
  //For a saving chat
  Future<void> saveChat({required ChatStorageDBModel chat}) async {
    final Store? store = DatabaseService.obxStore;
    if (store == null) {
      return;
    }

    final Box<ChatStorageDBModel> box = store.box<ChatStorageDBModel>();
    box.put(chat);
  }

  //For retrieving the chats of current user with receiver
  Future<List<ChatStorageDBModel>> getSavedChats({
    required int senderId,
    required int receiverId,
  }) async {
    //Getting store for getting the box
    final Store? store = DatabaseService.obxStore;
    if (store != null) {
      final Box<ChatStorageDBModel> box = store.box<ChatStorageDBModel>();
      final List<ChatStorageDBModel> chats =
          //Putting a condition to fetch chat
          box
              .query(
                ChatStorageDBModel_.senderId.equals(senderId) &
                        ChatStorageDBModel_.receiverId.equals(receiverId) |
                    ChatStorageDBModel_.senderId.equals(receiverId) &
                        ChatStorageDBModel_.receiverId.equals(senderId),
              )
              .build()
              .find();
      return chats;
    } else {
      return [];
    }
  }

  //For deleting all chat of current user with receiver
  void deleteAllChat({
    required int currentUserId,
    required int oppositeUserId,
  }) {
    final Store? store = DatabaseService.obxStore;
    if (store == null) {
      return;
    }
    store
        .box<ChatStorageDBModel>()
        .query(
          ChatStorageDBModel_.senderId.equals(currentUserId) &
                  ChatStorageDBModel_.receiverId.equals(oppositeUserId) |
              ChatStorageDBModel_.senderId.equals(oppositeUserId) &
                  ChatStorageDBModel_.receiverId.equals(currentUserId),
        )
        .build()
        .remove();
  }

  //For deleting single chat using chat id
  void deleteSingleChat({required String chatId}) {
    final Store? store = DatabaseService.obxStore;
    if (store != null) {
      final int id =
          store
              .box<ChatStorageDBModel>()
              .query(ChatStorageDBModel_.chatId.equals(chatId))
              .build()
              .remove();
      printDebug("Removed id : $id");
    }
  }

  //For getting last message of current user with receiver
  ChatStorageDBModel? getLastMessage({
    required int receiverId,
    required int currentUserId,
    required bool shouldFetchAudioAndVideoCall,
  }) {
    final Store? store = DatabaseService.obxStore;
    if (store != null) {
      final Condition<ChatStorageDBModel> senderToReceiverCond =
          (ChatStorageDBModel_.senderId.equals(currentUserId) &
              ChatStorageDBModel_.receiverId.equals(receiverId));

      final Condition<ChatStorageDBModel> receiverToSenderCond =
          (ChatStorageDBModel_.senderId.equals(receiverId) &
              ChatStorageDBModel_.receiverId.equals(currentUserId));

      final Condition<ChatStorageDBModel> fetchAudioAndVideoCond =
          !shouldFetchAudioAndVideoCall
              ? (ChatStorageDBModel_.type.notEquals("audioCall") &
                  ChatStorageDBModel_.type.notEquals("videoCall"))
              : (ChatStorageDBModel_.type.equals("audioCall") &
                  ChatStorageDBModel_.type.equals("videoCall"));
      final Condition<ChatStorageDBModel> finalCondition =
          ((senderToReceiverCond & fetchAudioAndVideoCond) |
              (receiverToSenderCond & fetchAudioAndVideoCond));
      final ChatStorageDBModel? lastChat =
          store
              .box<ChatStorageDBModel>()
              .query(finalCondition)
              .order(ChatStorageDBModel_.date, flags: Order.descending)
              .build()
              .findFirst();
      return lastChat;
    }
    return null;
  }

  //For changing seen indication
  Future<void> changeSeenStatus({
    required int receiverId,
    required int senderId,
  }) async {
    final Store? store = DatabaseService.obxStore;
    if (store != null) {
      final List<ChatStorageDBModel> chats =
          store
              .box<ChatStorageDBModel>()
              .query(
                ChatStorageDBModel_.senderId.equals(senderId) &
                    ChatStorageDBModel_.receiverId.equals(receiverId) &
                    ChatStorageDBModel_.isSeen.equals(false),
              )
              .build()
              .find();
      //Changing one by one as true
      for (var chat in chats) {
        chat.isSeen = true;
      }
      store.box<ChatStorageDBModel>().putMany(chats);
      return;
    }
  }

  //For getting unread message count
  int getUnreadMessageCount({
    required int receiverId,
    required int currentUserId,
  }) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      final int unreadMessageCount =
          store
              .box<ChatStorageDBModel>()
              .query(
                ChatStorageDBModel_.senderId.equals(receiverId) &
                    ChatStorageDBModel_.receiverId.equals(currentUserId) &
                    ChatStorageDBModel_.isRead.equals(false),
              )
              .build()
              .count();
      return unreadMessageCount;
    }

    return 0;
  }

  //For changing read status
  void changeReadStatusAsTrue({
    required int receiverId,
    required int currentUserId,
  }) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      List<ChatStorageDBModel> chats =
          store
              .box<ChatStorageDBModel>()
              .query(
                ChatStorageDBModel_.senderId.equals(receiverId) &
                    ChatStorageDBModel_.receiverId.equals(currentUserId) &
                    ChatStorageDBModel_.isRead.equals(false),
              )
              .build()
              .find();
      //Change each message as read
      for (var chat in chats) {
        chat.isRead = true;
      }
      store.box<ChatStorageDBModel>().putMany(chats, mode: PutMode.update);
    }
  }

  //To get unseen message count
  int getUnseenMessageCount({required int senderId, required int receiverId}) {
    final Store? store = DatabaseService.obxStore;

    if (store == null) {
      return 0;
    }

    final Condition<ChatStorageDBModel> conditionToNotCount =
        (ChatStorageDBModel_.type.notEquals("audioCall") &
            ChatStorageDBModel_.type.notEquals("videoCall"));
    final int count =
        store
            .box<ChatStorageDBModel>()
            .query(
              ChatStorageDBModel_.senderId.equals(senderId) &
                  ChatStorageDBModel_.receiverId.equals(receiverId) &
                  ChatStorageDBModel_.isSeen.equals(false) &
                  conditionToNotCount,
            )
            .build()
            .count();
    return count;
  }

  //For getting all messages count of current user with a receiver
  int getTotalMessageCount({
    required int currentUserId,
    required int receiverId,
  }) {
    final Store? store = DatabaseService.obxStore;

    if (store == null) {
      return 0;
    }

    final int totalMessageCount =
        store
            .box<ChatStorageDBModel>()
            .query(
              ChatStorageDBModel_.senderId.equals(currentUserId) &
                      ChatStorageDBModel_.receiverId.equals(receiverId) |
                  ChatStorageDBModel_.senderId.equals(receiverId) &
                      ChatStorageDBModel_.receiverId.equals(currentUserId),
            )
            .build()
            .count();

    return totalMessageCount;
  }

  //For getting images's count
  int getTotalImageCount({
    required int currentUserId,
    required int receiverId,
  }) {
    final Store? store = DatabaseService.obxStore;

    if (store == null) {
      return 0;
    }

    final int totalImageCount =
        store
            .box<ChatStorageDBModel>()
            .query(
              ChatStorageDBModel_.senderId.equals(currentUserId) &
                      ChatStorageDBModel_.receiverId.equals(receiverId) &
                      ChatStorageDBModel_.type.equals("image") |
                  ChatStorageDBModel_.senderId.equals(receiverId) &
                      ChatStorageDBModel_.receiverId.equals(currentUserId) &
                      ChatStorageDBModel_.type.equals("image"),
            )
            .build()
            .count();

    return totalImageCount;
  }

  //For getting all audios's count
  int getTotalAudiosCount({
    required int currentUserId,
    required int receiverId,
  }) {
    final Store? store = DatabaseService.obxStore;

    if (store == null) {
      return 0;
    }

    final int totalAudiosCount =
        store
            .box<ChatStorageDBModel>()
            .query(
              ChatStorageDBModel_.senderId.equals(currentUserId) &
                      ChatStorageDBModel_.receiverId.equals(receiverId) &
                      ChatStorageDBModel_.type.equals("audio") |
                  ChatStorageDBModel_.senderId.equals(receiverId) &
                      ChatStorageDBModel_.receiverId.equals(currentUserId) &
                      ChatStorageDBModel_.type.equals("audio"),
            )
            .build()
            .count();

    return totalAudiosCount;
  }

  //For fetching media like audio , image , voice
  List<ChatStorageDBModel> getMedia({
    required int currentUserId,
    required int oppositeUserId,
    int? limit,
  }) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      final Query<ChatStorageDBModel> query =
          store
              .box<ChatStorageDBModel>()
              .query(
                ChatStorageDBModel_.senderId.equals(currentUserId) &
                        ChatStorageDBModel_.receiverId.equals(oppositeUserId) &
                        ((ChatStorageDBModel_.type.equals("audio") |
                            ChatStorageDBModel_.type.equals("image") &
                                ChatStorageDBModel_.isDownloaded.equals(
                                  true,
                                ))) |
                    ChatStorageDBModel_.receiverId.equals(currentUserId) &
                        ChatStorageDBModel_.senderId.equals(oppositeUserId) &
                        ((ChatStorageDBModel_.type.equals("audio") |
                                ChatStorageDBModel_.type.equals("image")) &
                            ChatStorageDBModel_.isDownloaded.equals(true)),
              )
              .build();

      if (limit != null) {
        query.limit = limit;
      }

      final List<ChatStorageDBModel> media = query.find();

      return media;
    }

    return [];
  }

  //For deleting selected chats
  void deleteSelectedChats(List<String> chatIds) {
    final Store? store = DatabaseService.obxStore;

    if (store != null) {
      final Query<ChatStorageDBModel> query =
          store
              .box<ChatStorageDBModel>()
              .query(ChatStorageDBModel_.chatId.oneOf(chatIds))
              .build();

      query.remove();
    }
  }
}
