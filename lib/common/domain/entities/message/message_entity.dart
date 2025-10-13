import 'package:json_annotation/json_annotation.dart';
part 'message_entity.g.dart';

@JsonSerializable()
class MessageEntity {
  @JsonKey(name: 'message')
  final String message;

  MessageEntity({required this.message});

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return _$MessageEntityFromJson(json);
  }
}
