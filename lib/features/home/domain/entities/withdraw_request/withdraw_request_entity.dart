import 'package:json_annotation/json_annotation.dart';
part 'withdraw_request_entity.g.dart';

@JsonSerializable()
class WithdrawRequestEntity {
  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'withdrawnUserId')
  final int withdrawnUserId;

  WithdrawRequestEntity({required this.message, required this.withdrawnUserId});

  factory WithdrawRequestEntity.fromJson(Map<String, dynamic> json) {
    return _$WithdrawRequestEntityFromJson(json);
  }
}
