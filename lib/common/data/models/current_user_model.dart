class CurrentUserModel {
  final int userId;
  final String username;
  final String profilePic;
  final String bio;
  final String email;

  CurrentUserModel({
    required this.userId,
    required this.username,
    required this.profilePic,
    required this.bio,
    required this.email,
  });
}

class UpdatedUserDetailsModel {
  final String? newUsername;
  final String? newBio;
  final String? newImageUrl;

  UpdatedUserDetailsModel({
    required this.newUsername,
    required this.newBio,
    required this.newImageUrl,
  });
}
