// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupsEntity _$GroupsEntityFromJson(Map<String, dynamic> json) => GroupsEntity(
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      groupBio: json['groupBio'] as String?,
      groupImage: json['groupImageUrl'] as String?,
      groupAdminUserId: (json['groupAdminUserId'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      groupMembersCount: (json['groupMembersCount'] as num).toInt(),
      lastMessageTime: json['lastMessageTime'] as String,
    );
