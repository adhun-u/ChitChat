part of 'group_call_bloc.dart';

sealed class GroupCallState {}

final class GroupCallInitial extends GroupCallState {}

//Join group call loading state
final class JoinGroupCallLoadingState extends GroupCallState {}

//Join group call success state
final class JoinGroupCallSuccessState extends GroupCallState {
  final String token;

  JoinGroupCallSuccessState({required this.token});
}

//Join group call error state
final class JoinGroupCallErrorState extends GroupCallState {
  final String errorMessage;

  JoinGroupCallErrorState({required this.errorMessage});
}

//Group call time out state
final class GroupCallTimeOutState extends GroupCallState{
  
}
