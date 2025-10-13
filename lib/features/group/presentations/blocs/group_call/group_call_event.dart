part of 'group_call_bloc.dart';

sealed class GroupCallEvent {}

//For joining a call of a group
final class JoinGroupCallEvent extends GroupCallEvent {
  final String groupName;
  final String groupProfilePic;
  final int currentUserId;
  final String username;
  final String profilePic;
  final String groupId;
  final String callType;
  JoinGroupCallEvent({
    required this.groupName,
    required this.groupProfilePic,
    required this.currentUserId,
    required this.username,
    required this.profilePic,
    required this.groupId,
    required this.callType,
  });
}

//For staring and counting the time
final class StartGroupCallTimer extends GroupCallEvent {}

//For stoping the timer
final class StopGroupCallTimer extends GroupCallEvent {}

//For emitting the state when timeouts
final class _EmitGroupCallTimeOutEvent extends GroupCallEvent {}
