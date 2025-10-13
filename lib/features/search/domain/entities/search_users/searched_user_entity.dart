import 'package:json_annotation/json_annotation.dart';
part 'searched_user_entity.g.dart';

@JsonSerializable()
class SearchedUserEntity {
  @JsonKey(name: 'id')
  final int userId;
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'profilePic')
  final String profilePic;
  @JsonKey(name: 'bio')
  final String bio;
  @JsonKey(name: 'isRequested')
  final bool isRequested;
  @JsonKey(name : 'isAdded')
  final bool isAdded;

  SearchedUserEntity({
    required this.profilePic,
    required this.userId,
    required this.username,
    required this.bio,
    required this.isRequested,
    required this.isAdded,
  });

  factory SearchedUserEntity.fromJson(Map<String, dynamic> json) =>
      _$SearchedUserEntityFromJson(json);
}
