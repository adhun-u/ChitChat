import 'package:json_annotation/json_annotation.dart';
part 'search_group_entity.g.dart';

@JsonSerializable()
class SearchGroupEntity {
  @JsonKey(name: 'groupId')
  final String groupId;
  @JsonKey(name: 'groupName')
  final String groupName;
  @JsonKey(name: 'groupBio')
  final String groupBio;
  @JsonKey(name: 'groupImageUrl')
  final String groupImage;
  @JsonKey(name: 'groupAdminUserId')
  final int groupAdminUserId;
  @JsonKey(name: 'isCurrentUserAdded')
  final bool isCurrentUserAdded;
  @JsonKey(name: 'isRequestSent')
  final bool isRequestSent;

  SearchGroupEntity({
    required this.groupId,
    required this.groupName,
    required this.groupBio,
    required this.groupImage,
    required this.groupAdminUserId,
    required this.isCurrentUserAdded,
    required this.isRequestSent
  });

  factory SearchGroupEntity.fromJson(Map<String, dynamic> json) {
    return _$SearchGroupEntityFromJson(json);
  }
}
