part of 'request_bloc.dart';

sealed class RequestEvent {}

//Send request event
final class SentRequestEvent extends RequestEvent {
  int requestedUserId;
  String requestedUsername;
  String requestedUserProfilePic;
  String requestedUserbio;

  SentRequestEvent({
    required this.requestedUserId,
    required this.requestedUserProfilePic,
    required this.requestedUserbio,
    required this.requestedUsername,
  });
}
