// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searched_user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchedUserEntity _$SearchedUserEntityFromJson(Map<String, dynamic> json) =>
    SearchedUserEntity(
      profilePic: json['profilePic'] as String,
      userId: (json['id'] as num).toInt(),
      username: json['username'] as String,
      bio: json['bio'] as String,
      isRequested: json['isRequested'] as bool,
      isAdded: json['isAdded'] as bool,
    );