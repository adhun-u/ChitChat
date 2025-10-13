import 'package:json_annotation/json_annotation.dart';
part 'check_username_email_entity.g.dart';

@JsonSerializable()
class CheckEmailEntity {
  @JsonKey(name: 'email')
  final String email;

  CheckEmailEntity({required this.email});
  Map<String, dynamic> toJson() => _$CheckEmailEntityToJson(this);
}
