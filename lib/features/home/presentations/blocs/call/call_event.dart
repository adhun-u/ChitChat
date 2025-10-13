part of 'call_bloc.dart';

sealed class CallEvent {}

//For creating an offer to call
final class ConnectCallSocket extends CallEvent {
  final int currentUserId;
  final int oppositeUserId;
  final String currentUserProfilePic;
  ConnectCallSocket({
    required this.currentUserId,
    required this.oppositeUserId,
    required this.currentUserProfilePic,
  });
}

//For adding offer to call
final class CreateCallOfferEvent extends CallEvent {
  final String offer;
  final int currentUserId;
  final int calleeId;
  final String callType;
  final String currentUsername;
  CreateCallOfferEvent({
    required this.offer,
    required this.currentUserId,
    required this.calleeId,
    required this.callType,
    required this.currentUsername,
  });
}

//For answering the call if caller create offer
final class AnswerCallOfferEvent extends CallEvent {
  final int callerId;
  final int currentUserId;
  final String data;

  AnswerCallOfferEvent({
    required this.callerId,
    required this.currentUserId,
    required this.data,
  });
}

//For getting the offer that caller created
final class GetOfferEvent extends CallEvent {
  final int currentUserId;
  final int userId;

  GetOfferEvent({required this.currentUserId, required this.userId});
}

//For getting the answer that callee sent
final class GetAnswerCallOfferEvent extends CallEvent {
  final Map<String, dynamic> data;
  GetAnswerCallOfferEvent({required this.data});
}

//For getting the candidates for finishing the connection
final class GetCandidatesEvent extends CallEvent {
  final List<CandidateEntity> candidates;

  GetCandidatesEvent({required this.candidates});
}

//For closing call websocket connection
final class CloseCallWebSocketConnection extends CallEvent {}

//For emitting the offer that caller created
final class _EmitOfferEvent extends CallEvent {
  final Map<String, dynamic> data;

  _EmitOfferEvent({required this.data});
}

//For emitting the answer that callee answered
final class _EmitAnswerEvent extends CallEvent {
  final Map<String, dynamic> data;
  final int currentUserId;
  final int calleeId;
  _EmitAnswerEvent({
    required this.data,
    required this.currentUserId,
    required this.calleeId,
  });
}

//For posting candidate info
final class PostCandidateEvent extends CallEvent {
  final String data;
  final int callerId;
  final int calleeId;
  PostCandidateEvent({
    required this.data,
    required this.callerId,
    required this.calleeId,
  });
}

//For emitting the candidates info
final class _EmitCandidateInfoEvent extends CallEvent {
  final List<dynamic> candidates;

  _EmitCandidateInfoEvent({required this.candidates});
}

//For emitting call ended state
final class _EmitCallIndicationEvent extends CallEvent {
  final String type;

  _EmitCallIndicationEvent({required this.type});
}

//For sending call indication
final class SendCallIndicationEvent extends CallEvent {
  final int callerId;
  final int calleeId;
  final String type;
  SendCallIndicationEvent({
    required this.callerId,
    required this.calleeId,
    required this.type,
  });
}

//For starting the timer to count 30 seconds 
final class StartTimerEvent extends CallEvent{}