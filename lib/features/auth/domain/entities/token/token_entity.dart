import 'package:json_annotation/json_annotation.dart';
part 'token_entity.g.dart';

@JsonSerializable()
class TokenEntity {
  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'token')
  final String token;

  TokenEntity({required this.token, required this.message});

  factory TokenEntity.fromJson(Map<String, dynamic> json) {
    return _$TokenEntityFromJson(json);
  }
}
