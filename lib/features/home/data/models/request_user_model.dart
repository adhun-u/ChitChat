class RequestUserModel {
  final String id;
  final int requestedUserId;
  final String requestedUsername;
  final String requestedUserProfilePic;
  final String requestedUserbio;
  final String requestedDate;
  RequestUserModel({
    required this.id,
    required this.requestedUserId,
    required this.requestedUsername,
    required this.requestedUserProfilePic,
    required this.requestedUserbio,
    required this.requestedDate,
  });
}
