// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_requested_users_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupRequestedUsersEntity _$GroupRequestedUsersEntityFromJson(
        Map<String, dynamic> json) =>
    GroupRequestedUsersEntity(
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      username: json['username'] as String,
      userId: (json['userId'] as num).toInt(),
      imageUrl: json['userProfilepic'] as String,
      userbio: json['userBio'] as String,
    );

