// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FetchRequestUserEntity _$FetchRequestUserEntityFromJson(
        Map<String, dynamic> json) =>
    FetchRequestUserEntity(
      id: json['id'] as String,
      requestedUserId: (json['requestedUserId'] as num).toInt(),
      requestedUsername: json['requestedUsername'] as String,
      profilePic: json['profilePic'] as String?,
      userBio: json['bio'] as String?,
      requestedDate: json['requestedDate'] as String,
    );
