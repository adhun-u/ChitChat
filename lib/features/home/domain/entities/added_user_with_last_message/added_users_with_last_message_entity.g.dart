// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'added_users_with_last_message_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddedUsersWithLastMessageEntity _$AddedUsersWithLastMessageEntityFromJson(
        Map<String, dynamic> json) =>
    AddedUsersWithLastMessageEntity(
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      profilePic: json['profilePic'] as String,
      bio: json['bio'] as String?,
      lastPendingMessage: json['lastPendingMessage'] as String,
      pendingMessageCount: (json['pendingMessageCount'] as num).toInt(),
      time: json['time'] as String,
      messageType: json['type'] as String,
      imageText: json['imageText'] as String,
    );


