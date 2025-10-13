import 'package:json_annotation/json_annotation.dart';
part 'group_edited_entity.g.dart';

@JsonSerializable()
class GroupEditedEntity {
  @JsonKey(name: 'groupName')
  final String? newGroupName;
  @JsonKey(name: 'groupBio')
  final String? newGroupBio;
  @JsonKey(name: 'groupImageUrl')
  final String? newGroupImageUrl;

  GroupEditedEntity({
    required this.newGroupName,
    required this.newGroupBio,
    required this.newGroupImageUrl,
  });

  factory GroupEditedEntity.fromJson(Map<String, dynamic> json) {
    return _$GroupEditedEntityFromJson(json);
  }
}
