import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/data/repo_imple/current_user_repo_imple.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

class CurrentUserProvider extends ChangeNotifier {
  //Creating an instance for CurrentUserRepoImple
  final CurrentUserRepoImple _currentUserRepoImple = CurrentUserRepoImple();
  String? errorMessage;
  //jwt token
  String? token;
  CurrentUserModel currentUser = CurrentUserModel(
    userId: 0,
    username: "",
    profilePic: "",
    bio: "",
    email: "",
  );
  bool fetchingCurrentDetailsLoading = false;
  bool updateDetailsLoading = false;
  bool updatePasswordLoading = false;

  CurrentUserProvider({required this.token});

  //Fetching current user's details
  Future<void> fetchCurrentUser({
    Function(CurrentUserModel currentUser)? onCurrentUserFetched,
  }) async {
    errorMessage = null;
    fetchingCurrentDetailsLoading = true;
    if (token == null) {
      final String? token = await getToken();
      this.token = token;
    }
    notifyListeners();
    if (token == null) {
      errorMessage = "Something went wrong";
      fetchingCurrentDetailsLoading = false;
      notifyListeners();
      return;
    }
    final Either<CurrentUserModel?, ErrorMessageModel?> result =
        await _currentUserRepoImple.fetchCurrentUser(token: token!);
    //Checking whether it returns success state or error state

    result.fold(
      //Success state
      (currentUserModel) {
        if (currentUserModel != null) {
          fetchingCurrentDetailsLoading = false;
          currentUser = currentUserModel;
          errorMessage = null;
          notifyListeners();
          if (onCurrentUserFetched != null) {
            onCurrentUserFetched(currentUserModel);
          }
          return;
        }
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          fetchingCurrentDetailsLoading = false;
          errorMessage = errorModel.message;
          notifyListeners();
        }
      },
    );
  }

  //Updating current user's details
  Future<Either<UpdatedUserDetailsModel, ErrorMessageModel>> updateUserDetails({
    required String newName,
    required String newBio,
    required String imagePath,
  }) async {
    updateDetailsLoading = true;
    notifyListeners();
    if (token == null) {
      updateDetailsLoading = false;
      notifyListeners();
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    final Either<UpdatedUserDetailsModel, ErrorMessageModel> result =
        await _currentUserRepoImple.updateCurrentUserDetails(
          token: token!,
          imagePath: imagePath,
          username: newName,
          bio: newBio,
        );

    final String oldName = currentUser.username;
    final String oldBio = currentUser.bio;
    final String oldImageUrl = currentUser.profilePic;

    result.fold((details) {
      currentUser = CurrentUserModel(
        userId: currentUser.userId,
        username:
            details.newUsername != null && details.newUsername!.isNotEmpty
                ? details.newUsername!
                : oldName,
        profilePic:
            details.newImageUrl != null && details.newImageUrl!.isNotEmpty
                ? details.newImageUrl!
                : oldImageUrl,
        bio:
            details.newBio != null && details.newBio!.isNotEmpty
                ? details.newBio!
                : oldBio,
        email: currentUser.email,
      );

      notifyListeners();
    }, (_) {});
    updateDetailsLoading = false;
    notifyListeners();
    return result;
  }

  //Updating current user's password
  Future<Either<SuccessMessageModel, ErrorMessageModel>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    updatePasswordLoading = true;
    notifyListeners();

    if (token == null) {
      updatePasswordLoading = false;
      notifyListeners();
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }

    final Either<SuccessMessageModel, ErrorMessageModel> result =
        await _currentUserRepoImple.updatePassword(
          token: token!,
          currentPassword: oldPassword,
          newPassword: newPassword,
        );

    updatePasswordLoading = false;
    notifyListeners();
    return result;
  }
}
