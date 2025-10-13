import 'package:json_annotation/json_annotation.dart';
part 'seen_indication_entity.g.dart';

@JsonSerializable()
class SeenIndicationEntity {
  @JsonKey(name: 'senderId')
  final int senderId;
  @JsonKey(name: 'receiverId')
  final int receiverId;
  SeenIndicationEntity({
    required this.senderId,
    required this.receiverId,
  });

  factory SeenIndicationEntity.fromJson(Map<String, dynamic> json) {
    return _$SeenIndicationEntityFromJson(json);
  }
}
