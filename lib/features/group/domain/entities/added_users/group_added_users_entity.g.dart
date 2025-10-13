// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_added_users_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupAddedUsersEntity _$GroupAddedUsersEntityFromJson(
        Map<String, dynamic> json) =>
    GroupAddedUsersEntity(
      username: json['username'] as String,
      userId: (json['userId'] as num).toInt(),
      imageUrl: json['profilePic'] as String,
      bio: json['bio'] as String,
    );
