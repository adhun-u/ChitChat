import 'package:json_annotation/json_annotation.dart';
part 'group_requested_users_entity.g.dart';

@JsonSerializable()
class GroupRequestedUsersEntity {
  @JsonKey(name: 'groupId')
  final String groupId;
  @JsonKey(name: 'groupName')
  final String groupName;
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'userId')
  final int userId;
  @JsonKey(name: 'userProfilepic')
  final String imageUrl;
  @JsonKey(name: 'userBio')
  final String userbio;

  GroupRequestedUsersEntity({
    required this.groupId,
    required this.groupName,
    required this.username,
    required this.userId,
    required this.imageUrl,
    required this.userbio,
  });

  factory GroupRequestedUsersEntity.fromJson(Map<String, dynamic> json) {
    return _$GroupRequestedUsersEntityFromJson(json);
  }
}
