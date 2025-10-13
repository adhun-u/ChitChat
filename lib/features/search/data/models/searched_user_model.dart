class SearchedUserModel {
  final String username;
  final int userId;
  final String profilePic;
  final String bio;
  final bool isRequested;
  final bool isAdded;

  SearchedUserModel({
    required this.profilePic,
    required this.userId,
    required this.username,
    required this.bio,
    required this.isAdded,
    required this.isRequested
  });
}
