class ChatModel {
  final String chatId;
  final int senderId;
  final String senderName;
  final String senderProfilePic;
  final String senderBio;
  final int receiverId;
  final String type;
  final String? textMessage;
  final String time;
  final String? imageUrl;
  final String? imageText;
  final String? voiceUrl;
  final String? voiceDuration;
  final String audioUrl;
  final String audioDuration;
  final String audioTitle;
  final String videoUrl;
  final String videoDuration;
  final String videoTitle;
  final bool isSeen;
  final bool isRead;
  final bool repliedMessage;
  final int parentMessageSenderId;
  final String parentMessageType;
  final String parentText;
  final String parentVoiceDuration;
  final String parentAudioDuration;

  ChatModel({
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderProfilePic,
    required this.senderBio,
    required this.receiverId,
    required this.type,
    required this.textMessage,
    required this.time,
    required this.imageText,
    required this.imageUrl,
    required this.voiceUrl,
    required this.voiceDuration,
    required this.audioUrl,
    required this.audioDuration,
    required this.audioTitle,
    required this.videoTitle,
    required this.videoUrl,
    required this.videoDuration,
    required this.isSeen,
    required this.isRead,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });
}

class ReplyMessageModel {
  final String senderName;
  final String messageType;
  final int parentMessageSenderId;
  final String? text;
  final String? audioDuration;
  final String? voiceDuration;

  ReplyMessageModel({
    required this.senderName,
    required this.messageType,
    required this.parentMessageSenderId,
    this.text,
    this.audioDuration,
    this.voiceDuration,
  });
}

class LastMessageModel {
  final String textMessage;
  final String messageType;
  final String time;
  final String audioDuration;
  final String voiceDuration;
  final String imageText;

  LastMessageModel({
    required this.textMessage,
    required this.messageType,
    required this.time,
    required this.audioDuration,
    required this.imageText,
    required this.voiceDuration,
  });
}

class SelectedChatModel {
  final bool isSeen;
  final int senderId;

  SelectedChatModel({required this.isSeen, required this.senderId});
}
