import 'package:objectbox/objectbox.dart';

@Entity()
class ChatStorageDBModel {
  @Id()
  int id = 0;
  final String chatId;
  final int senderId;
  final int receiverId;
  final String type;
  final String? message;
  final String? imagePath;
  final String? imageText;
  final String audioPath;
  final String audioDuration;
  final String audioTitle;
  final String voicePath;
  final String voiceDuration;
  final String date;
  bool isSeen;
  bool isRead;
  bool isDownloaded;
  final bool repliedMessage;

  final int parentMessageSenderId;

  final String parentMessageType;

  final String parentText;

  final String parentVoiceDuration;

  final String parentAudioDuration;

  ChatStorageDBModel({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.message,
    required this.imagePath,
    required this.imageText,
    required this.audioPath,
    required this.audioDuration,
    required this.audioTitle,
    required this.voicePath,
    required this.voiceDuration,
    required this.date,
    required this.isSeen,
    required this.isRead,
    required this.isDownloaded,
    required this.repliedMessage,
    required this.parentAudioDuration,
    required this.parentMessageSenderId,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });
}
