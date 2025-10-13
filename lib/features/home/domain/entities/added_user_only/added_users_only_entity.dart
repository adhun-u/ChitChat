import 'package:json_annotation/json_annotation.dart';
part 'added_users_only_entity.g.dart';

@JsonSerializable()
class AddedUsersOnlyEntity {
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'userId')
  final int userId;
  @JsonKey(name: 'bio')
  final String? userBio;
  @JsonKey(name: 'profilePic')
  final String? profilePic;

  AddedUsersOnlyEntity({
    required this.username,
    required this.userId,
    required this.userBio,
    required this.profilePic,
  });

  factory AddedUsersOnlyEntity.fromJson(Map<String, dynamic> json) {
    return _$AddedUsersOnlyEntityFromJson(json);
  }
}
