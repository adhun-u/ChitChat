import 'package:json_annotation/json_annotation.dart';
part 'sent_user_entity.g.dart';

@JsonSerializable()
class SentUserEntity {
  @JsonKey(name: 'sentUserId')
  final int sentUserId;
  @JsonKey(name: 'sentUsername')
  final String sentUsername;
  @JsonKey(name: 'sentUserProfilePic')
  final String? sentUserProfilePic;
  @JsonKey(name: 'sentUserbio')
  final String? sentUserbio;
  @JsonKey(name: 'sentDate')
  final String sentDate;

  SentUserEntity({
    required this.sentUserId,
    required this.sentUsername,
    required this.sentUserProfilePic,
    required this.sentUserbio,
    required this.sentDate,
  });

  factory SentUserEntity.fromJson(Map<String, dynamic> json) {
    return _$SentUserEntityFromJson(json);
  }
}
