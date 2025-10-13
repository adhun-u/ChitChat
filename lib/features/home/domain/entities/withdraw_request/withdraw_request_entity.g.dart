// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_request_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawRequestEntity _$WithdrawRequestEntityFromJson(
        Map<String, dynamic> json) =>
    WithdrawRequestEntity(
      message: json['message'] as String,
      withdrawnUserId: (json['withdrawnUserId'] as num).toInt(),
    );