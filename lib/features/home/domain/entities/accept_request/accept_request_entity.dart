import 'package:json_annotation/json_annotation.dart';
part 'accept_request_entity.g.dart';

@JsonSerializable()
class AcceptRequestEntity {
  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'requestedUserId')
  final int requestedUserId;

  AcceptRequestEntity({required this.message, required this.requestedUserId});

  factory AcceptRequestEntity.fromJson(Map<String, dynamic> json) {
    return _$AcceptRequestEntityFromJson(json);
  }
}
