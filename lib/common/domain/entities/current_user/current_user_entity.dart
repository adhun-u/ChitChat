import 'package:json_annotation/json_annotation.dart';
part 'current_user_entity.g.dart';

@JsonSerializable()
class CurrentUserEntity {
  @JsonKey(name: 'userId')
  final int userId;
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'profilePic')
  final String profiePic;
  @JsonKey(name: 'email')
  final String emai;
  @JsonKey(name: 'bio')
  final String bio;

  CurrentUserEntity({
    required this.userId,
    required this.username,
    required this.profiePic,
    required this.emai,
    required this.bio,
  });

  factory CurrentUserEntity.fromJson(Map<String, dynamic> json) {
    return _$CurrentUserEntityFromJson(json);
  }
}

@JsonSerializable()
class UpdatedCurrentUserEntity {
  @JsonKey(name: 'username')
  final String? newUsername;
  @JsonKey(name: 'bio')
  final String? newBio;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  UpdatedCurrentUserEntity({
    required this.newUsername,
    required this.newBio,
    required this.imageUrl,
  });

  factory UpdatedCurrentUserEntity.fromJson(Map<String, dynamic> json) {
    return _$UpdatedCurrentUserEntityFromJson(json);
  }
}
