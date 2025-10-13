part of 'call_bloc.dart';

sealed class CallState {}

final class CallInitial extends CallState {}

//New offer state
final class NewOfferState extends CallState {
  final Map<String, dynamic> data;
  NewOfferState({required this.data});
}

//Callee answered offer state
final class CalleeAnsweredState extends CallState {
  final Map<String, dynamic> data;

  CalleeAnsweredState({required this.data});
}

//Fetch candidate state
final class FetchCandidateState extends CallState {
  final List<dynamic> candidates;

  FetchCandidateState({required this.candidates});
}

//Call ended state
final class CallEndedState extends CallState {}

//Call connecting state
final class CallConnectingState extends CallState {}

//Call connected state
final class CallConnectedState extends CallState {}

//Call ringing state
final class CallRingingState extends CallState {}

//Call declined state
final class CallDeclinedState extends CallState {}
