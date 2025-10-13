// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallEntity _$CallEntityFromJson(Map<String, dynamic> json) => CallEntity(
      data: json['data'] as String?,
      type: json['type'] as String?,
      callType: json['callType'] as String?,
      candidates: (json['candidates'] as List<dynamic>?)
          ?.map((e) => CandidateEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );


CandidateEntity _$CandidateEntityFromJson(Map<String, dynamic> json) =>
    CandidateEntity(
      type: json['type'] as String,
      data: json['data'] as String,
    );
