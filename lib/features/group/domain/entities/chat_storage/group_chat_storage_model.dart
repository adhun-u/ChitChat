import 'package:objectbox/objectbox.dart';

@Entity()
class GroupChatStorageModel {
  @Id()
  int id = 0;
  final String groupId;
  final String chatId;
  final int senderId;
  final String senderName;
  final String messageType;
  final String textMessage;
  final String imagePath;
  final String imageText;
  final String audioPath;
  final String audioDuration;
  final String audioTitle;
  final String voicePath;
  final String voiceDuration;
  final String time;
  bool isSeen;
  bool isRead;
  bool isMediaDownloaded;
  final bool repliedMessage;

  final int parentMessageSenderId;
  final String parentMessageSenderName;
  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;

  GroupChatStorageModel({
    required this.groupId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.messageType,
    required this.textMessage,
    required this.imagePath,
    required this.imageText,
    required this.audioPath,
    required this.audioDuration,
    required this.audioTitle,
    required this.voicePath,
    required this.voiceDuration,
    required this.time,
    required this.isSeen,
    required this.isRead,
    required this.isMediaDownloaded,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageSenderName,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });
}
