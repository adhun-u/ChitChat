class GroupModel {
  final String groupId;
  final String groupName;
  final String groupImageUrl;
  final String groupBio;
  final String lastMessage;
  final String lastMessageTime;
  final bool isSeenLastMessage;
  final String lastImageText;
  final String lastMessageType;
  final bool isMe;
  final int unreadMessagesCount;
  final int groupAdminUserId;
  final String createdAt;
  final int membersCount;
  
  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.groupImageUrl,
    required this.groupBio,
    required this.lastMessage,
    required this.isSeenLastMessage,
    required this.lastImageText,
    required this.lastMessageType,
    required this.lastMessageTime,
    required this.unreadMessagesCount,
    required this.isMe,
    required this.groupAdminUserId,
    required this.membersCount,
    required this.createdAt,
  });
}

class SearchGroupModel {
  final String groupId;
  final String groupName;
  final String groupImageUrl;
  final String groupBio;
  final int groupAdminUserId;
  final bool isCurrentUserAdded;
  final bool isRequestSent;
  SearchGroupModel({
    required this.groupId,
    required this.groupName,
    required this.groupImageUrl,
    required this.groupBio,
    required this.groupAdminUserId,
    required this.isCurrentUserAdded,
    required this.isRequestSent,
  });
}

class GroupAddedUserModel {
  final int userId;
  final String username;
  final String profilePic;
  final String userBio;

  GroupAddedUserModel({
    required this.username,
    required this.userId,
    required this.profilePic,
    required this.userBio,
  });
}

class GroupRequestUserModel {
  final String groupId;
  final String groupName;
  final String username;
  final String imageUrl;
  final int userId;
  final String userBio;

  GroupRequestUserModel({
    required this.groupId,
    required this.groupName,
    required this.username,
    required this.imageUrl,
    required this.userId,
    required this.userBio,
  });
}
