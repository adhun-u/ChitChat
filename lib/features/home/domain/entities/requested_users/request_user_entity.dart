import 'package:json_annotation/json_annotation.dart';
part 'request_user_entity.g.dart';

@JsonSerializable()
class FetchRequestUserEntity {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'requestedUserId')
  final int requestedUserId;
  @JsonKey(name: 'requestedUsername')
  final String requestedUsername;
  @JsonKey(name: 'profilePic')
  final String? profilePic;
  @JsonKey(name: 'bio')
  final String? userBio;
  @JsonKey(name: 'requestedDate')
  final String requestedDate;

  FetchRequestUserEntity({
    required this.id,
    required this.requestedUserId,
    required this.requestedUsername,
    required this.profilePic,
    required this.userBio,
    required this.requestedDate,
  });

  factory FetchRequestUserEntity.fromJson(Map<String, dynamic> json) {
    return _$FetchRequestUserEntityFromJson(json);
  }
}
