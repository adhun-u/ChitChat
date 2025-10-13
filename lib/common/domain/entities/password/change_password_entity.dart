import 'package:json_annotation/json_annotation.dart';
part 'change_password_entity.g.dart';

@JsonSerializable()
class ChangePasswordEntity {
  @JsonKey(name: 'currentPassword')
  final String currentPassword;
  @JsonKey(name: 'newPassword')
  final String newPassword;

  ChangePasswordEntity({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return _$ChangePasswordEntityToJson(this);
  }
}
