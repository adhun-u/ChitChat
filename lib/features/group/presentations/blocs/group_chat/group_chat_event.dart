part of 'group_chat_bloc.dart';

sealed class GroupChatEvent {}

//For sending a message as group message
final class SendGroupTextMessage extends GroupChatEvent {
  final String textMessage;
  final String groupId;
  final int currentUserId;
  final String currentUsername;
  final int totalMembersCount;
  final String groupName;
  final String groupImageUrl;
  final String groupBio;
  final String groupCreatedAt;
  final int groupAdminUserId;
  final bool repliedMessage;
  final int parentMessageSenderId;
  final String parentMessageType;
  final String parentText;
  final String parentVoiceDuration;
  final String parentAudioDuration;
  final String parentSenderName;

  SendGroupTextMessage({
    required this.groupName,
    required this.textMessage,
    required this.groupId,
    required this.currentUserId,
    required this.currentUsername,
    required this.totalMembersCount,
    required this.groupImageUrl,
    required this.groupBio,
    required this.groupCreatedAt,
    required this.groupAdminUserId,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
    required this.parentSenderName,
  });
}

//For being notified when new message comes
final class _NotifyMessageEvent extends GroupChatEvent {
  final GroupChatStorageModel newChat;
  _NotifyMessageEvent({required this.newChat});
}

//For connecting with firestore
final class ConnectWithFireStore extends GroupChatEvent {
  final int currentUserId;
  ConnectWithFireStore({required this.currentUserId});
}

//For fetching group messages from local storage
final class FetchGroupMessagesEvent extends GroupChatEvent {
  final String groupId;
  FetchGroupMessagesEvent({required this.groupId});
}

//For changing seen users count in firestore
final class ChangeSeenUserCountEvent extends GroupChatEvent {
  final String chatId;
  final String groupId;
  final int currentUserId;
  ChangeSeenUserCountEvent({
    required this.chatId,
    required this.groupId,
    required this.currentUserId,
  });
}

//For fetching seen info
final class FetchGroupMessageSeenInfoEvent extends GroupChatEvent {
  final String groupId;
  final int senderId;
  FetchGroupMessageSeenInfoEvent({
    required this.groupId,
    required this.senderId,
  });
}

//For clearing all chats from local storage
final class ClearAllGroupChatsEvent extends GroupChatEvent {
  final String groupId;

  ClearAllGroupChatsEvent({required this.groupId});
}

//For connecting group chat websocket
final class ConnectGroupChatSocketEvent extends GroupChatEvent {
  final int userId;
  final String groupId;

  ConnectGroupChatSocketEvent({required this.userId, required this.groupId});
}

//For closing the group chat connection
final class CloseGroupChatSocketEvent extends GroupChatEvent {
  final String? groupId;

  CloseGroupChatSocketEvent({required this.groupId});
}

//For changing seen info in firebase
final class ChangeSeenInfoInFirebaseEvent extends GroupChatEvent {
  final String groupId;
  final int currentUserId;
  ChangeSeenInfoInFirebaseEvent({
    required this.groupId,
    required this.currentUserId,
  });
}

//For sending indication
final class SendIndicationEvent extends GroupChatEvent {
  final String indication;
  final String groupId;
  final int userId;
  final String? indicationType;
  SendIndicationEvent({
    required this.indication,
    required this.groupId,
    required this.userId,
    this.indicationType,
  });
}

//For getting Indication from socket connection
final class GetIndicationEvent extends GroupChatEvent {
  final String groupId;
  final String indication;
  final int userId;
  final String? indicationType;
  final bool? isInCall;
  GetIndicationEvent({
    required this.groupId,
    required this.indication,
    required this.userId,
    this.indicationType,
    this.isInCall,
  });
}

//For deleting every docs in firebase
final class DeleteEveryDocsEvent extends GroupChatEvent {
  final String groupId;
  final int senderId;

  DeleteEveryDocsEvent({required this.groupId, required this.senderId});
}

//For changing _isInChatPage as true
final class EnterInChatPageEvent extends GroupChatEvent {
  final String groupId;

  EnterInChatPageEvent({required this.groupId});
}

//For uploading image to backend
final class UploadGroupChatFileEvent extends GroupChatEvent {
  final String filePath;
  final String imageText;
  final String fileType;
  final String senderName;
  final int senderId;
  final String groupId;
  final String audioVideoTitle;
  final String audioVideoDuration;
  final String voiceDuration;
  final bool repliedMessage;
  final int parentMessageSenderId;
  final String parentMessageSenderName;
  final String parentMessageType;
  final String parentText;
  final String parentVoiceDuration;
  final String parentAudioDuration;
  UploadGroupChatFileEvent({
    required this.filePath,
    required this.imageText,
    required this.fileType,
    required this.senderId,
    required this.senderName,
    required this.groupId,
    required this.audioVideoDuration,
    required this.audioVideoTitle,
    required this.voiceDuration,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageSenderName,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });
}

//For saving the file to local storage
final class SaveGroupChatFileEvent extends GroupChatEvent {
  final String chatId;
  final String filePath;
  final String imageText;
  final int senderId;
  final String senderName;
  final String fileType;
  final String time;
  final String audioVideoDuration;
  final String audioVideoTitle;
  final String fileUrl;
  final String groupId;
  final String voiceDuration;
  final int totalMembersCount;
  final int groupAdminUserId;
  final String groupBio;
  final bool shouldSendToMembers;
  final String groupName;
  final String groupImageUrl;
  final String groupCreatedAt;
  final bool repliedMessage;
  final int parentMessageSenderId;
  final String parentMessageSenderName;
  final String parentMessageType;
  final String parentText;
  final String parentVoiceDuration;
  final String parentAudioDuration;
  SaveGroupChatFileEvent({
    required this.chatId,
    required this.filePath,
    required this.imageText,
    required this.senderId,
    required this.senderName,
    required this.fileType,
    required this.time,
    required this.audioVideoDuration,
    required this.audioVideoTitle,
    required this.voiceDuration,
    required this.fileUrl,
    required this.groupId,
    required this.totalMembersCount,
    required this.groupAdminUserId,
    required this.groupCreatedAt,
    required this.shouldSendToMembers,
    required this.groupImageUrl,
    required this.groupName,
    required this.groupBio,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageSenderName,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });
}

//For subscribing to a topic to get group messages as notification
final class SubscribeToTopicEvent extends GroupChatEvent {
  final String groupId;

  SubscribeToTopicEvent({required this.groupId});
}

//For unsubscibing to a topic to don't get group messages
final class UnSubscribeToTopicEvent extends GroupChatEvent {
  final String groupId;
  UnSubscribeToTopicEvent({required this.groupId});
}

//For selecting chat to delete
final class SelectGroupChatEvent extends GroupChatEvent {
  final String chatId;
  final bool isSeen;
  final int senderId;
  SelectGroupChatEvent({
    required this.chatId,
    required this.isSeen,
    required this.senderId,
  });
}

//For deselecting selected chats
final class DeSelectGroupChats extends GroupChatEvent {}

//For changing seen info in selected chats
final class ChangeSeenInfoInGroupSelectedChatsEvent extends GroupChatEvent {
  final String chatId;

  ChangeSeenInfoInGroupSelectedChatsEvent({required this.chatId});
}

//For deleting for current user event
final class DeleteGroupChatsForMeEvent extends GroupChatEvent {}

//For deleting for everyone from particular group
final class DeleteGroupChatForEveryOneEvent extends GroupChatEvent {
  final String groupId;

  DeleteGroupChatForEveryOneEvent({required this.groupId});
}

//For cancelling uploading process
final class CancelGroupMediaUploadProcess extends GroupChatEvent {
  final String chatId;

  CancelGroupMediaUploadProcess({required this.chatId});
}

//For other states
final class _EmitOtherGroupChatState extends GroupChatEvent {
  final GroupChatState state;
  _EmitOtherGroupChatState({required this.state});
}

//For emitting unread message count
final class _EmitUnreadMessageCount extends GroupChatEvent {
  final String groupId;

  _EmitUnreadMessageCount({required this.groupId});
}

//For removing unread message count
final class RemoveUnreadGroupMessagesCount extends GroupChatEvent {
  final String groupId;

  RemoveUnreadGroupMessagesCount({required this.groupId});
}

//For adding call history
final class AddGroupCallHistroyEvent extends GroupChatEvent {
  final String currentUserName;
  final int currentUserId;
  final String callType;
  final String groupId;
  AddGroupCallHistroyEvent({
    required this.currentUserName,
    required this.currentUserId,
    required this.callType,
    required this.groupId,
  });
}
