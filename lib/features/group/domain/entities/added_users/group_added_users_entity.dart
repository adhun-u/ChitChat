import 'package:json_annotation/json_annotation.dart';
part 'group_added_users_entity.g.dart';

@JsonSerializable()
class GroupAddedUsersEntity {
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'userId')
  final int userId;
  @JsonKey(name: 'profilePic')
  final String imageUrl;
  @JsonKey(name: 'bio')
  final String bio;

  GroupAddedUsersEntity({
    required this.username,
    required this.userId,
    required this.imageUrl,
    required this.bio,
  });

  factory GroupAddedUsersEntity.fromJson(Map<String, dynamic> json) {
    return _$GroupAddedUsersEntityFromJson(json);
  }
}
