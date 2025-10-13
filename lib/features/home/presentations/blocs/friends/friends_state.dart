part of 'friends_bloc.dart';

sealed class FriendsState {}

final class FriendsInitial extends FriendsState {}

//Fetch requested users success state
final class FetchRequestedUsersSuccessState extends FriendsState {
  final List<RequestUserModel> requestedUsers;

  FetchRequestedUsersSuccessState({required this.requestedUsers});
}

//Fetch requested users error state
final class FetchRequestedUsersErrorState extends FriendsState {
  final String errorMessage;

  FetchRequestedUsersErrorState({required this.errorMessage});
}

//Fetch requested users loading state
final class FetchRequestedUsersLoadingState extends FriendsState {}

//Null state for avoiding loading state
final class NullState extends FriendsState {}

//Request accepted success state
final class RequestAcceptSuccessState extends FriendsState {
  final AcceptRequestModel acceptRequestModel;
  RequestAcceptSuccessState({required this.acceptRequestModel});
}

//Request accepted error state
final class RequestAcceptErrorState extends FriendsState {
  final String errorMessage;

  RequestAcceptErrorState({required this.errorMessage});
}

//Request accept loading state
final class RequestAcceptLoadingState extends FriendsState {
  final int userId;

  RequestAcceptLoadingState({required this.userId});
}

//Fetch sent request successs state
final class FetchSentRequestSuccessState extends FriendsState {
  final List<SentRequestUserModel> sentRequestUsers;
  FetchSentRequestSuccessState({required this.sentRequestUsers});
}

//Fetch sent request error state
final class FetchSentRequestErrorState extends FriendsState {
  final String errorMessage;
  FetchSentRequestErrorState({required this.errorMessage});
}

//Fetch sent request loading state
final class FetchSentRequestLoadingState extends FriendsState {}

//Request withdraw success state
final class RequestWithdrawSuccessState extends FriendsState {
  final int withdrawnUserId;
  final String message;

  RequestWithdrawSuccessState({
    required this.message,
    required this.withdrawnUserId,
  });
}

//Request withdraw loading state
final class RequestWithdrawLoadingState extends FriendsState {
  final int userId;

  RequestWithdrawLoadingState({required this.userId});
}

//Request withdraw error state
final class RequestWithdrawErrorState extends FriendsState {
  final String errorMessage;
  final int userId;
  RequestWithdrawErrorState({required this.errorMessage, required this.userId});
}

//Decline success state
final class DeclineSuccessState extends FriendsState {
  final int userId;
  final String message;

  DeclineSuccessState({required this.userId, required this.message});
}

//Decline loading state
final class DeclineLoadingState extends FriendsState {
  final int userId;
  DeclineLoadingState({required this.userId});
}

//Decline error state
final class DeclineErrorState extends FriendsState {
  final int userId;
  final String message;

  DeclineErrorState({required this.userId, required this.message});
}

//Load more requested users success state
final class LoadMoreRequestedUsersSuccessState extends FriendsState {}

//Load more requested users loading state
final class LoadMoreRequestedUsersLoadingState extends FriendsState {}

//Load more requested users error state
final class LoadMoreRequestedUsersErrorState extends FriendsState {}

//Load more sent users success state
final class LoadMoreSentUsersSuccessState extends FriendsState {}

//Load more sent users loading state
final class LoadMoreSentUsersLoadingState extends FriendsState {}

//Load more sent users error state
final class LoadMoreSentUsersErrorState extends FriendsState {}
