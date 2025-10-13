class AddedUserWithLastMessageModel {
  final int userId;
  final String username;
  final String profilePic;
  final String userbio;
  final String lastMessage;
  final String lastTime;
  final int unreadMessageCount;
  final String messageType;
  final bool isSeen;
  final bool isMe;
  AddedUserWithLastMessageModel({
    required this.userId,
    required this.username,
    required this.userbio,
    required this.profilePic,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadMessageCount,
    required this.messageType,
    required this.isSeen,
    required this.isMe,
  });
}

class AddedUserOnlyModel {
  final int userId;
  final String username;
  final String userBio;
  final String profilePic;

  AddedUserOnlyModel({
    required this.userId,
    required this.username,
    required this.userBio,
    required this.profilePic,
  });
}
