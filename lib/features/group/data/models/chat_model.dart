class GroupChatModel {
  final int senderId;
  final String senderName;
  final String groupId;
  final String chatId;
  final String messageType;
  final String textMessage;
  final String imageUrl;
  final String imageText;
  final String voiceUrl;
  final String voiceDuration;
  final String audioUrl;
  final String audioDuration;
  final String audioTitle;
  final String videoUrl;
  final String videoDuration;
  final String videoTitle;
  final String time;
  final bool isSeen;
  final bool isRead;
  final bool repliedMessage;

  final int parentMessageSenderId;
  final String parentMessageSenderName;
  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;
  GroupChatModel({
    required this.senderId,
    required this.senderName,
    required this.groupId,
    required this.chatId,
    required this.messageType,
    required this.textMessage,
    required this.imageUrl,
    required this.imageText,
    required this.voiceUrl,
    required this.voiceDuration,
    required this.audioUrl,
    required this.audioDuration,
    required this.audioTitle,
    required this.videoUrl,
    required this.videoDuration,
    required this.videoTitle,
    required this.time,
    required this.isSeen,
    required this.isRead,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageSenderName,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });
}

class ReplyMessageModel {
  final int senderId;
  final String senderName;
  final String messageType;
  final String audioDuration;
  final String voiceDuration;
  final String text;

  ReplyMessageModel({
    required this.senderId,
    required this.senderName,
    required this.messageType,
    required this.audioDuration,
    required this.voiceDuration,
    required this.text,
  });
}

class UnreadGroupMessageCountModel {
  final int unreadMessagesCount;
  final String groupId;

  UnreadGroupMessageCountModel({
    required this.unreadMessagesCount,
    required this.groupId,
  });
}

class SelectedGroupChatModel {
  final int senderId;
  final bool isSeen;

  SelectedGroupChatModel({required this.senderId, required this.isSeen});
}
