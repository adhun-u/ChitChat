// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatEntity _$ChatEntityFromJson(Map<String, dynamic> json) => ChatEntity(
      chatId: json['chatId'] as String,
      senderId: (json['senderId'] as num).toInt(),
      senderName: json['senderName'] as String?,
      senderProfilePic: json['senderProfilePic'] as String?,
      senderBio: json['senderBio'] as String?,
      receiverId: (json['receiverId'] as num).toInt(),
      type: json['type'] as String,
      textMessage: json['message'] as String?,
      time: json['time'] as String,
      imageUrl: json['imageUrl'] as String?,
      imageText: json['imageText'] as String?,
      voiceUrl: json['voiceUrl'] as String?,
      voiceDuration: json['voiceDuration'] as String?,
      audioUrl: json['audioUrl'] as String?,
      audioDuration: json['audioDuration'] as String?,
      audioTitle: json['audioTitle'] as String?,
      videoUrl: json['videoUrl'] as String?,
      videoDuration: json['videoDuration'] as String?,
      videoTitle: json['videoTitle'] as String?,
      isSeen: json['isSeen'] as bool,
      isRead: json['isRead'] as bool,
      repliedMessage: json['repliedMessage'] as bool,
      parentMessageSenderId: (json['parentMessageSenderId'] as num?)?.toInt(),
      parentAudioDuration: json['parentAudioDuration'] as String?,
      parentMessageType: json['parentMessageType'] as String?,
      parentText: json['parentText'] as String?,
      parentVoiceDuration: json['parentVoiceDuration'] as String?,
    );

Map<String, dynamic> _$ChatEntityToJson(ChatEntity instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'senderName': instance.senderName,
      'senderProfilePic': instance.senderProfilePic,
      'senderBio': instance.senderBio,
      'message': instance.textMessage,
      'type': instance.type,
      'time': instance.time,
      'voiceUrl': instance.voiceUrl,
      'voiceDuration': instance.voiceDuration,
      'imageUrl': instance.imageUrl,
      'imageText': instance.imageText,
      'audioUrl': instance.audioUrl,
      'audioDuration': instance.audioDuration,
      'audioTitle': instance.audioTitle,
      'videoUrl': instance.videoUrl,
      'videoDuration': instance.videoDuration,
      'videoTitle': instance.videoTitle,
      'isSeen': instance.isSeen,
      'isRead': instance.isRead,
      'repliedMessage': instance.repliedMessage,
      'parentMessageSenderId': instance.parentMessageSenderId,
      'parentMessageType': instance.parentMessageType,
      'parentText': instance.parentText,
      'parentVoiceDuration': instance.parentVoiceDuration,
      'parentAudioDuration': instance.parentAudioDuration,
    };
