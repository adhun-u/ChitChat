import 'package:json_annotation/json_annotation.dart';
part 'group_chat_entity.g.dart';

@JsonSerializable()
class GroupChatEntity {
  @JsonKey(name: 'groupId')
  final String groupId;
  @JsonKey(name: 'groupName')
  final String groupName;
  @JsonKey(name: 'groupBio')
  final String? groupBio;
  @JsonKey(name: 'groupAdminUserId')
  final int groupAdminUserId;
  @JsonKey(name: 'groupImageUrl')
  final String? groupImageUrl;
  @JsonKey(name: 'createdAt')
  final String groupCreatedAt;
  @JsonKey(name: 'members')
  final List<dynamic> members;
  @JsonKey(name: 'senderId')
  final int senderId;
  @JsonKey(name: 'senderName')
  final String senderName;
  @JsonKey(name: 'chatId')
  final String chatId;
  @JsonKey(name: 'messageType')
  final String messageType;
  @JsonKey(name: 'textMessage')
  final String? textMessage;
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
  @JsonKey(name: 'voiceUrl')
  final String? voiceUrl;
  @JsonKey(name: 'voiceDuration')
  final String? voiceDuration;
  @JsonKey(name: 'videoUrl')
  final String? videoUrl;
  @JsonKey(name: 'videoDuration')
  final String? videoDuration;
  @JsonKey(name: 'videoTitle')
  final String? videoTitle;
  @JsonKey(name: 'time')
  final String time;
  @JsonKey(name: 'repliedMessage')
  final bool repliedMessage;
  @JsonKey(name: 'parentMessageSenderId')
  final int? parentMessageSenderId;
  @JsonKey(name: 'parentMessageSenderName')
  final String? parentMessageSenderName;
  @JsonKey(name: 'parentMessageType')
  final String? parentMessageType;
  @JsonKey(name: 'parentText')
  final String? parentText;
  @JsonKey(name: 'parentVoiceDuration')
  final String? parentVoiceDuration;
  @JsonKey(name: 'parentAudioDuration')
  final String? parentAudioDuration;

  GroupChatEntity({
    required this.groupId,
    required this.groupName,
    required this.groupBio,
    required this.groupAdminUserId,
    required this.groupImageUrl,
    required this.groupCreatedAt,
    required this.members,
    required this.senderId,
    required this.senderName,
    required this.chatId,
    required this.messageType,
    required this.textMessage,
    required this.imageUrl,
    required this.imageText,
    required this.audioUrl,
    required this.audioDuration,
    required this.audioTitle,
    required this.voiceUrl,
    required this.voiceDuration,
    required this.videoUrl,
    required this.videoDuration,
    required this.videoTitle,
    required this.time,
    required this.repliedMessage,
    required this.parentMessageSenderId,
    required this.parentMessageSenderName,
    required this.parentMessageType,
    required this.parentText,
    required this.parentVoiceDuration,
    required this.parentAudioDuration,
  });
  factory GroupChatEntity.fromJson(Map<String, dynamic> json) {
    return _$GroupChatEntityFromJson(json);
  }
}
