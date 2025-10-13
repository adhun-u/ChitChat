import 'package:json_annotation/json_annotation.dart';
part 'register_with_google_entity.g.dart';

@JsonSerializable()
class RegisterWithGoogleEntity {
  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'profilepic')
  final String? profilePic;
  @JsonKey(name: 'deviceToken')
  final String deviceToken;

  RegisterWithGoogleEntity({
    required this.email,
    required this.username,
    required this.profilePic,
    required this.deviceToken
  });

  Map<String, dynamic> toJson() => _$RegisterWithGoogleEntityToJson(this);
}
