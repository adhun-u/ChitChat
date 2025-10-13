import 'package:json_annotation/json_annotation.dart';
part 'login_email_entity.g.dart';

@JsonSerializable()
class LoginEmailEntity {
  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'password')
  final String password;
  @JsonKey(name: 'deviceToken')
  final String deviceToken;

  LoginEmailEntity({
    required this.email,
    required this.password,
    required this.deviceToken,
  });

  Map<String, dynamic> toJson() {
    return _$LoginEmailEntityToJson(this);
  }
}
