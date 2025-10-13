// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_chat_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupChatEntity _$GroupChatEntityFromJson(Map<String, dynamic> json) =>
    GroupChatEntity(
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      groupBio: json['groupBio'] as String?,
      groupAdminUserId: (json['groupAdminUserId'] as num).toInt(),
      groupImageUrl: json['groupImageUrl'] as String?,
      groupCreatedAt: json['createdAt'] as String,
      members: json['members'] as List<dynamic>,
      senderId: (json['senderId'] as num).toInt(),
      senderName: json['senderName'] as String,
      chatId: json['chatId'] as String,
      messageType: json['messageType'] as String,
      textMessage: json['textMessage'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imageText: json['imageText'] as String?,
      audioUrl: json['audioUrl'] as String?,
      audioDuration: json['audioDuration'] as String?,
      audioTitle: json['audioTitle'] as String?,
      voiceUrl: json['voiceUrl'] as String?,
      voiceDuration: json['voiceDuration'] as String?,
      videoUrl: json['videoUrl'] as String?,
      videoDuration: json['videoDuration'] as String?,
      videoTitle: json['videoTitle'] as String?,
      time: json['time'] as String,
      repliedMessage: json['repliedMessage'] as bool,
      parentMessageSenderId: (json['parentMessageSenderId'] as num?)?.toInt(),
      parentMessageSenderName: json['parentMessageSenderName'] as String?,
      parentMessageType: json['parentMessageType'] as String?,
      parentText: json['parentText'] as String?,
      parentVoiceDuration: json['parentVoiceDuration'] as String?,
      parentAudioDuration: json['parentAudioDuration'] as String?,
    );

