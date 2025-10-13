// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentUserEntity _$CurrentUserEntityFromJson(Map<String, dynamic> json) =>
    CurrentUserEntity(
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      profiePic: json['profilePic'] as String,
      emai: json['email'] as String,
      bio: json['bio'] as String,
    );


UpdatedCurrentUserEntity _$UpdatedCurrentUserEntityFromJson(
        Map<String, dynamic> json) =>
    UpdatedCurrentUserEntity(
      newUsername: json['username'] as String?,
      newBio: json['bio'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
