import 'package:json_annotation/json_annotation.dart';
part 'call_entity.g.dart';

@JsonSerializable()
class CallEntity {
  @JsonKey(name: 'data')
  final String? data;
  @JsonKey(name: 'type')
  final String? type;
  @JsonKey(name: 'callType')
  final String? callType;
  @JsonKey(name: 'candidates')
  final List<CandidateEntity>? candidates;

  CallEntity({
    required this.data,
    required this.type,
    required this.callType,
    required this.candidates,
  });

  factory CallEntity.fromJson(Map<String, dynamic> json) {
    return _$CallEntityFromJson(json);
  }
}

@JsonSerializable()
class CandidateEntity {
  @JsonKey(name: 'type')
  final String type;
  @JsonKey(name: 'data')
  final String data;

  CandidateEntity({required this.type, required this.data});

  factory CandidateEntity.fromJson(Map<String, dynamic> json) {
    return _$CandidateEntityFromJson(json);
  }
}
