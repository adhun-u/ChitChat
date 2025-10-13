import 'package:json_annotation/json_annotation.dart';
part 'groups_entity.g.dart';

@JsonSerializable()
class GroupsEntity {
  @JsonKey(name: 'groupId')
  final String groupId;
  @JsonKey(name: 'groupName')
  final String groupName;
  @JsonKey(name: 'groupBio')
  final String? groupBio;
  @JsonKey(name: 'groupImageUrl')
  final String? groupImage;
  @JsonKey(name: 'groupAdminUserId')
  final int groupAdminUserId;
  @JsonKey(name: 'createdAt')
  final String createdAt;
  @JsonKey(name: 'groupMembersCount')
  final int groupMembersCount;
  @JsonKey(name: 'lastMessageTime')
  final String lastMessageTime;

  GroupsEntity({
    required this.groupId,
    required this.groupName,
    required this.groupBio,
    required this.groupImage,
    required this.groupAdminUserId,
    required this.createdAt,
    required this.groupMembersCount,
    required this.lastMessageTime,
  });

  factory GroupsEntity.fromJson(Map<String, dynamic> json) {
    return _$GroupsEntityFromJson(json);
  }
}
