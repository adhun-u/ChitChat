import 'package:json_annotation/json_annotation.dart';
part 'register_email_entity.g.dart';

@JsonSerializable()
class RegisterEmailEntity {
  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'password')
  final String password;
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'deviceToken')
  final String deviceToken;

  RegisterEmailEntity({
    required this.email,
    required this.password,
    required this.username,
    required this.deviceToken
  });

  Map<String, dynamic> toJson() => _$RegisterEmailEntityToJson(this);
}
