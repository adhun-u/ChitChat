// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sent_user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SentUserEntity _$SentUserEntityFromJson(Map<String, dynamic> json) =>
    SentUserEntity(
      sentUserId: (json['sentUserId'] as num).toInt(),
      sentUsername: json['sentUsername'] as String,
      sentUserProfilePic: json['sentUserProfilePic'] as String?,
      sentUserbio: json['sentUserbio'] as String?,
      sentDate: json['sentDate'] as String,
    );
