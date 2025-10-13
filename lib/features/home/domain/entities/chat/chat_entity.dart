import 'package:json_annotation/json_annotation.dart';
part 'chat_entity.g.dart';

@JsonSerializable()
class ChatEntity {
  @JsonKey(name: 'chatId')
  final String chatId;
  @JsonKey(name: 'senderId')
  final int senderId;
  @JsonKey(name: 'receiverId')
  final int receiverId;
  @JsonKey(name: 'senderName')
  final String? senderName;
  @JsonKey(name: 'senderProfilePic')
  final String? senderProfilePic;
  @JsonKey(name: 'senderBio')
  final String? senderBio;
  @JsonKey(name: 'message')
  final String? textMessage;
  @JsonKey(name: 'type')
  final String type;
  @JsonKey(name: 'time')
  final String time;
  @JsonKey(name: 'voiceUrl')
  final String? voiceUrl;
  @JsonKey(name: 'voiceDuration')
  final String? voiceDuration;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;
  @JsonKey(name: 'imageText')
  final String? imageText;
  @JsonKey(name: 'audioUrl')
  final String? audioUrl;
  @JsonKey(name: 'audioDuration')
  final String? audioDuration;
  @JsonKey(name: 'audioTitle')
  final String? audioTitle;
  @JsonKey(name: 'videoUrl')
  final String? videoUrl;
  @JsonKey(name: 'videoDuration')
  final String? videoDuration;
  @JsonKey(name: 'videoTitle')
  final String? videoTitle;
  @JsonKey(name: 'isSeen')
  final bool isSeen;
  @JsonKey(name: 'isRead')
  final bool isRead;
  @JsonKey(name: 'repliedMessage')
  final bool repliedMessage;
  @JsonKey(name: 'parentMessageSenderId')
  final int? parentMessageSenderId;
  @JsonKey(name: 'parentMessageType')
  final String? parentMessageType;
  @JsonKey(name: 'parentText')
  final String? parentText;
  @JsonKey(name: 'parentVoiceDuration')
  final String? parentVoiceDuration;
  @JsonKey(name: 'parentAudioDuration')
  final String? parentAudioDuration;

  ChatEntity({
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderProfilePic,
    required this.senderBio,
    required this.receiverId,
    required this.type,
    required this.textMessage,
    required this.time,
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
    required this.isSeen,
    required this.isRead,
    required this.repliedMessage,
    required this.parentMessageSenderId,
    required this.parentAudioDuration,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
  });

  Map<String, dynamic> toJson() {
    return _$ChatEntityToJson(this);
  }

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
    return _$ChatEntityFromJson(json);
  }
}
