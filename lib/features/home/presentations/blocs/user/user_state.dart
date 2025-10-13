part of 'user_bloc.dart';

sealed class UserState {}

final class UserInitial extends UserState {}

//Fetch added user with last message success state
final class FetchAddedUserWithLastMessageSuccessState extends UserState {
  final List<AddedUserWithLastMessageModel> addedUsers;
  FetchAddedUserWithLastMessageSuccessState({required this.addedUsers});
}

//Fetch added user with last message error state
final class FetchAddedUserWithLastMessageErrorState extends UserState {
  final String errorMessage;
  FetchAddedUserWithLastMessageErrorState({required this.errorMessage});
}

//Fetch added user with last message loading state
final class FetchAddedUserWithLastMessageLoadingState extends UserState {}

//Load more friends with last message loading state
final class LoadMoreFriendsWithLastMessageLoadingState extends UserState {}

//Load more friends with last message error state
final class LoadMoreFriendsWithLastMessageErrorState extends UserState {}

//Load more friends with last message success state
final class LoadMoreFriendsWithLastMessageSuccessState extends UserState {}

//Remove user loading state
final class RemoveUserLoadingState extends UserState {
  final int userId;

  RemoveUserLoadingState({required this.userId});
}

//Remove user success state
final class RemoveUserSuccessState extends UserState {
  final int userId;

  RemoveUserSuccessState({required this.userId});
}

//Remove user error state
final class RemoveUserErrorState extends UserState {
  final int userId;

  RemoveUserErrorState({required this.userId});
}
