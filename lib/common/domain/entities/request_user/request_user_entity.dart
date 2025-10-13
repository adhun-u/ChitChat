import 'package:json_annotation/json_annotation.dart';
part 'request_user_entity.g.dart';

@JsonSerializable()
class RequestUserEntity {
  @JsonKey(name: 'requestedUserId')
  final int requestedUserId;
  @JsonKey(name: 'requestedUsername')
  final String requestedUsername;
  @JsonKey(name: 'requestedUserProfilePic')
  final String requestedUserProfilePic;
  @JsonKey(name: 'requestedUserbio')
  final String requestedUserbio;
  @JsonKey(name : 'requestedDate')
  final String requestedDate;

  RequestUserEntity({
    required this.requestedUserId,
    required this.requestedUsername,
    required this.requestedUserProfilePic,
    required this.requestedUserbio,
    required this.requestedDate,
  });
  Map<String, dynamic> toJson() => _$RequestUserEntityToJson(this);
}
