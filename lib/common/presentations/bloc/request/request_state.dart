part of 'request_bloc.dart';

sealed class RequestState {}

final class RequestInitial extends RequestState {}

//Send request success state
final class SentRequestSuccessState extends RequestState with EquatableMixin {
  final int userId;
  final String message;

  SentRequestSuccessState({required this.userId, required this.message});

  @override
  List<Object?> get props => [userId, message];
}

//Send request error state
final class SentRequestErrorState extends RequestState {
  final String errorMessage;
  final int userId;
  SentRequestErrorState({required this.errorMessage, required this.userId});
}

//Send request loading state
final class SentRequestLoadingState extends RequestState {
  final int userId;

  SentRequestLoadingState({required this.userId});
}
