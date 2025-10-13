part of 'chat_bloc.dart';

sealed class ChatEvent {}

//Send text message event
final class SendMessageEvent extends ChatEvent with EquatableMixin {
  final int senderId;
  final String senderName;
  final String senderProfilePic;
  final String senderBio;
  final int receiverId;
  final String? message;
  final String type;
  final String? imageUrl;
  final String? imageText;
  final String? voiceUrl;
  final String? voiceDuration;
  final String date;
  final bool repliedMessage;

  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  SendMessageEvent({
    required this.senderId,
    required this.senderName,
    required this.senderProfilePic,
    required this.senderBio,
    required this.receiverId,
    required this.message,
    required this.type,
    required this.date,
    required this.imageText,
    required this.imageUrl,
    required this.voiceDuration,
    required this.voiceUrl,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.repliedMessage,
  });

  @override
  List<Object?> get props => [
    senderId,
    receiverId,
    message,
    type,
    date,
    imageText,
    imageUrl,
    voiceDuration,
    voiceUrl,
  ];
}

//Connect socket event
final class ConnectSocketEvent extends ChatEvent {
  final int currentUserId;
  final String username;
  final String profilepic;
  ConnectSocketEvent({
    required this.currentUserId,
    required this.profilepic,
    required this.username,
  });
}

//Disconnect socket event
final class DisconnectSocketEvent extends ChatEvent {}

//Incoming messages
final class IncomingMessageEvent extends ChatEvent with EquatableMixin {
  final ChatModel chat;
  IncomingMessageEvent({required this.chat});

  @override
  List<Object?> get props => [chat.time];
}

//Retrieve chats event
final class RetrieveChatEvent extends ChatEvent with EquatableMixin {
  final int senderId;
  final int receiverId;

  RetrieveChatEvent({required this.senderId, required this.receiverId});

  @override
  List<Object?> get props => [senderId, receiverId];
}

//Fetching temporary messages event
final class FetchTempMessagesEvent extends ChatEvent {
  final int receiverId;
  final int currentUserId;
  FetchTempMessagesEvent({
    required this.receiverId,
    required this.currentUserId,
  });
}

//Indicate event for typing , audio recording
final class IndicateEvent extends ChatEvent {
  final String indication;
  final int receiverId;
  final int senderId;
  IndicateEvent({
    required this.indication,
    required this.receiverId,
    required this.senderId,
  });
}

//Incoming indicator event
final class IncomingIndicatorEvent extends ChatEvent {
  final String indication;
  final int receiverId;

  IncomingIndicatorEvent({required this.indication, required this.receiverId});
}

//To enter in chat connection
final class EnterChatConnectionEvent extends ChatEvent {
  final int receiverId;
  EnterChatConnectionEvent({required this.receiverId});
}

//To exit from chat connection
final class ExitFromChatConnectionEvent extends ChatEvent {}

//Online indication
final class OnlineIndicationEvent extends ChatEvent {
  final bool isOnline;
  OnlineIndicationEvent({required this.isOnline});
}

//Inidicate seen
final class IndicateSeenEvent extends ChatEvent {
  final int senderId;
  final int receiverId;

  IndicateSeenEvent({required this.receiverId, required this.senderId});
}

//To remove unread messages count
final class RemoveUnreadMessagesCount extends ChatEvent {
  final int currentUserId;
  final int receiverId;

  RemoveUnreadMessagesCount({
    required this.currentUserId,
    required this.receiverId,
  });
}

//To get unread message count
final class GetUnreadMessageCountEvent extends ChatEvent {
  final int senderId;
  final String time;
  final int receiverId;
  final int currentUserId;
  GetUnreadMessageCountEvent({
    required this.senderId,
    required this.time,
    required this.currentUserId,
    required this.receiverId,
  });
}

//To fetch seen info when receiver saw and current user was not in connection
final class FetchSeenInfoEvent extends ChatEvent {
  final int receiverId;
  final int currentUserId;
  FetchSeenInfoEvent({required this.receiverId, required this.currentUserId});
}

//To save seen info
final class SaveSeenInfoEvent extends ChatEvent {
  final int senderId;
  final int receiverId;
  SaveSeenInfoEvent({required this.senderId, required this.receiverId});
}

//To send image
final class UploadFileEvent extends ChatEvent {
  final String filePath;
  final String text;
  final String type;
  final String audioDuration;
  final String audioTitle;
  final String voiceDuration;
  final int senderId;
  final int receiverId;
  final bool replyMessage;
  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;

  UploadFileEvent({
    required this.filePath,
    required this.text,
    required this.type,
    required this.receiverId,
    required this.senderId,
    required this.audioDuration,
    required this.audioTitle,
    required this.voiceDuration,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
    required this.replyMessage,
  });
}

//To cancel uploading process
final class CancelUploadingProcess extends ChatEvent {
  final String chatId;

  CancelUploadingProcess({required this.chatId});
}

//To save image
final class SaveFileEvent extends ChatEvent {
  final String senderName;
  final String senderProfilePic;
  final String senderBio;
  final String imagePath;
  final String audioPath;
  final String voicePath;
  final String voiceDuration;
  final String chatId;
  final int senderId;
  final int receiverId;
  final int currentUserId;
  final String time;
  final String type;
  final String imageText;
  final String fileUrl;
  final bool isDownloaded;
  final String audioVideoDuration;
  final String audioVideoTitle;
  final String publicId;
  final bool repliedMessage;

  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;

  SaveFileEvent({
    required this.chatId,
    required this.senderName,
    required this.senderProfilePic,
    required this.senderBio,
    required this.imagePath,
    required this.audioPath,
    required this.voicePath,
    required this.voiceDuration,
    required this.senderId,
    required this.receiverId,
    required this.currentUserId,
    required this.imageText,
    required this.type,
    required this.time,
    required this.fileUrl,
    required this.audioVideoDuration,
    required this.audioVideoTitle,
    required this.isDownloaded,
    required this.publicId,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });
}

//For fetching messages count such as image count , audio count , text message count
final class FetchMessageCountEvent extends ChatEvent {
  final int currentUserId;
  final int receiverId;

  FetchMessageCountEvent({
    required this.currentUserId,
    required this.receiverId,
  });
}

//For fetching media such as audio , image , voice
final class FetchMediaEvent extends ChatEvent {
  final int currentUserId;
  final int oppositeUserId;
  final int? limit;
  FetchMediaEvent({
    required this.currentUserId,
    required this.oppositeUserId,
    this.limit,
  });
}

//For clearing all chats
final class ClearAllChatsEvent extends ChatEvent {
  final int currentUserId;
  final int oppositeUserId;

  ClearAllChatsEvent({
    required this.currentUserId,
    required this.oppositeUserId,
  });
}

//For selecting  chat to delete or copy
final class SelectChatEvent extends ChatEvent {
  final String chatId;
  final bool isSeen;
  final int senderId;
  SelectChatEvent({
    required this.chatId,
    required this.isSeen,
    required this.senderId,
  });
}

//For changing seen info in selected chats
final class ChangeSeenInfoInSelectedChatsEvent extends ChatEvent {}

//For deselecting all selected chats
final class DeSelectChatEvent extends ChatEvent {}

//For deleting for me
final class DeleteForMeEvent extends ChatEvent {}

//For deleting for everyone
final class DeleteForEveryone extends ChatEvent {}

//For changing last message
final class ChangeLastMessageEvent extends ChatEvent {
  final int oppositeUserId;
  final String messageType;
  final String audioDuration;
  final String voiceDuration;

  ChangeLastMessageEvent({
    required this.oppositeUserId,
    required this.messageType,
    required this.audioDuration,
    required this.voiceDuration,
  });
}

//For sending call info via websocket
final class SendCallHistoryInfo extends ChatEvent {
  final String callType;
  final int callerId;
  final int calleeId;

  SendCallHistoryInfo({
    required this.callType,
    required this.callerId,
    required this.calleeId,
  });
}
