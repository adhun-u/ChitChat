part of 'user_bloc.dart';

sealed class UserEvent {}

//For fetching added users with message event
final class FetchAddedUsersWithLastMessageEvent extends UserEvent {
  final int currentUserId;
  FetchAddedUsersWithLastMessageEvent({required this.currentUserId});
}

//For changing the order of user according to time when anyone sends message
final class ChangeUsersOrderEvent extends UserEvent {
  final String username;
  final int userId;
  final String userbio;
  final String profilePic;
  final String lastMessage;
  final String messageType;
  final String time;
  final bool isMe;

  final int unreadMessageCount;
  ChangeUsersOrderEvent({
    required this.userId,
    required this.username,
    required this.profilePic,
    required this.userbio,
    required this.lastMessage,
    required this.messageType,
    required this.time,
    required this.isMe,
    required this.unreadMessageCount,
  });
}

//For changing the postion of user that current user chats
final class ChangePositionOfUserEvent extends UserEvent {
  final int userId;
  final String lastTextMessage;
  final String lastMessageType;
  final String lastAudioDuration;
  final String lastVoiceDuration;
  final String lastImageText;
  final String lastMessageTime;

  ChangePositionOfUserEvent({
    required this.userId,
    required this.lastTextMessage,
    required this.lastMessageType,
    required this.lastAudioDuration,
    required this.lastVoiceDuration,
    required this.lastImageText,
    required this.lastMessageTime,
  });
}

//For loading more friends with last message
final class LoadMoreFriendsWithLastMessageEvent extends UserEvent {
  final int currentUserId;

  LoadMoreFriendsWithLastMessageEvent({required this.currentUserId});
}

//For removing a user from friends list
final class RemoveUserEvent extends UserEvent {
  final int userId;

  RemoveUserEvent({required this.userId});
}

//For changing last message time
final class ChangeLastMessageTimeEvent extends UserEvent {
  final String lastMessageTime;
  final int userId;
  ChangeLastMessageTimeEvent({
    required this.lastMessageTime,
    required this.userId,
  });
}
