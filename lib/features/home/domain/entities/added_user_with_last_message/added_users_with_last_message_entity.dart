import 'package:json_annotation/json_annotation.dart';
part 'added_users_with_last_message_entity.g.dart';

@JsonSerializable()
class AddedUsersWithLastMessageEntity {
  @JsonKey(name: 'userId')
  final int userId;
  @JsonKey(name: 'username')
  final String username;
  @JsonKey(name: 'profilePic')
  final String profilePic;
  @JsonKey(name: 'bio')
  final String? bio;
  @JsonKey(name: 'pendingMessageCount')
  final int pendingMessageCount;
  @JsonKey(name: 'lastPendingMessage')
  final String lastPendingMessage;
  @JsonKey(name: 'time')
  final String time;
  @JsonKey(name: 'type')
  final String messageType;
  @JsonKey(name: 'imageText')
  final String imageText;

  AddedUsersWithLastMessageEntity({
    required this.userId,
    required this.username,
    required this.profilePic,
    required this.bio,
    required this.lastPendingMessage,
    required this.pendingMessageCount,
    required this.time,
    required this.messageType,
    required this.imageText,
  });

  factory AddedUsersWithLastMessageEntity.fromJson(Map<String, dynamic> json) {
    return _$AddedUsersWithLastMessageEntityFromJson(json);
  }
}
