import 'package:json_annotation/json_annotation.dart';
part 'login_google_entity.g.dart';

@JsonSerializable()
class LoginGoogleEntity {
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'deviceToken')
  final String deviceToken;

  LoginGoogleEntity({
    required this.email,
    required this.username,
    required this.deviceToken,
  });

  Map<String, dynamic> toJson() => _$LoginGoogleEntityToJson(this);
}
