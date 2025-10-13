part of 'friends_bloc.dart';

sealed class FriendsEvent {}

//For fetching requested users event
final class FetchRequestedUsersEvent extends FriendsEvent {
  final bool shouldCallApi;
  FetchRequestedUsersEvent({required this.shouldCallApi});
}

//For accepting request event
final class AcceptRequestedEvent extends FriendsEvent {
  final int userId;

  AcceptRequestedEvent({required this.userId});
}

//For fetching sent request users event
final class FetchSentRequestEvent extends FriendsEvent {
  final bool shouldCallApi;

  FetchSentRequestEvent({required this.shouldCallApi});
}

//For withdrawing a request event
final class WithdrawRequestEvent extends FriendsEvent {
  final int userId;
  WithdrawRequestEvent({required this.userId});
}

//For declining a request
final class DeclineRequestEvent extends FriendsEvent {
  final int userId;

  DeclineRequestEvent({required this.userId});
}

//For loading more requested users
final class LoadMoreRequestedUsersEvent extends FriendsEvent {}

//For loading more sent users
final class LoadMoreSentUsersEvent extends FriendsEvent{}