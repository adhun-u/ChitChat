class UnreadMessageModel {
  final int senderId;
  final String time;
  final int unreadMessagesCount;
  UnreadMessageModel({
    required this.senderId,
    required this.time,
    required this.unreadMessagesCount,
  });
}
