import 'package:json_annotation/json_annotation.dart';
part 'send_request_entity.g.dart';

@JsonSerializable()
class SendRequestEntity {
  @JsonKey(name: 'adminId')
  final int adminId;
  @JsonKey(name: 'groupId')
  final String groupId;
  @JsonKey(name: 'groupName')
  final String groupName;

  SendRequestEntity({
    required this.adminId,
    required this.groupId,
    required this.groupName,
  });

  Map<String, dynamic> toJson() {
    return _$SendRequestEntityToJson(this);
  }
}
