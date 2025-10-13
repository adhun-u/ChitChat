// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_group_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchGroupEntity _$SearchGroupEntityFromJson(Map<String, dynamic> json) =>
    SearchGroupEntity(
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
      groupBio: json['groupBio'] as String,
      groupImage: json['groupImageUrl'] as String,
      groupAdminUserId: (json['groupAdminUserId'] as num).toInt(),
      isCurrentUserAdded: json['isCurrentUserAdded'] as bool,
      isRequestSent: json['isRequestSent'] as bool,
    );

