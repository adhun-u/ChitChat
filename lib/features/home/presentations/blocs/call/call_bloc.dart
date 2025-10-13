import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:chitchat/common/data/repo_imple/call_websocket_repo_imple.dart';
import 'package:chitchat/features/home/domain/entities/call/call_entity.dart';
part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final CallWebsocketRepoImple _websocketRepoImple = CallWebsocketRepoImple();
  StreamSubscription? _subscription;

  Timer? _timer;
  @override
  Future<void> close() async {
    _subscription?.cancel();
    return super.close();
  }

  CallBloc() : super(CallInitial()) {
    //To connect and send sdp for implementing webrtc
    on<ConnectCallSocket>(_connectCallSocket);
    //To create an offer to call callee
    on<CreateCallOfferEvent>((event, emit) async {
      emit(CallInitial());
      await _websocketRepoImple.sendData(
        data: event.offer,
        callerId: event.currentUserId,
        calleeId: event.calleeId,
        type: "CREATE-OFFER",
        callType: event.callType,
        currentUsername: event.currentUsername,
      );
    });
    //To post answer
    on<AnswerCallOfferEvent>((event, _) {
      log('Answer event called');
      _websocketRepoImple.sendData(
        data: event.data,
        callerId: event.callerId,
        calleeId: event.currentUserId,
        type: "POST-ANSWER",
        callType: "",
        currentUsername: "",
      );
    });
    //To close the websocket connection
    on<CloseCallWebSocketConnection>((_, _) async {
      await _websocketRepoImple.getSink().close();
    });
    //To get the offer that caller created
    on<GetOfferEvent>((event, _) async {
      await _websocketRepoImple.sendData(
        data: "",
        callerId: event.userId,
        calleeId: event.currentUserId,
        type: "GET-OFFER",
        callType: "audio",
        currentUsername: "",
      );
    });
    on<_EmitOfferEvent>((event, emit) {
      //Emitting the offer that caller created
      emit(NewOfferState(data: event.data));
    });
    on<_EmitAnswerEvent>((event, emit) async {
      //Emitting the answer that callee made
      emit(CalleeAnsweredState(data: event.data));
    });
    //To post candidate info to finish webrtc connection
    on<PostCandidateEvent>((event, _) {
      _websocketRepoImple.sendData(
        data: event.data,
        callerId: event.callerId,
        calleeId: event.calleeId,
        type: "POST-CANDIDATE",
        callType: "audio",
        currentUsername: "",
      );
    });
    //To emit candidates
    on<_EmitCandidateInfoEvent>((event, emit) {
      emit(FetchCandidateState(candidates: event.candidates));
    });
    //To send call ended state
    on<SendCallIndicationEvent>((event, emit) async {
      await _websocketRepoImple.sendData(
        data: "",
        callerId: event.callerId,
        calleeId: event.calleeId,
        type: event.type,
        callType: "audio",
        currentUsername: "",
      );
    });
    //To emit call ended indication
    on<_EmitCallIndicationEvent>((event, emit) {
      if (event.type == "CALL-END") {
        emit(CallEndedState());
      } else if (event.type == "CALL-CONNECTING") {
        emit(CallConnectingState());
      } else if (event.type == "CALL-CONNECTED") {
        emit(CallConnectedState());
      } else if (event.type == "RINGING") {
        emit(CallRingingState());
      } else if (event.type == "DECLINE") {
        emit(CallDeclinedState());
      }
    });

    //To start timer
    on<StartTimerEvent>((_, _) {
      _startTimer();
    });
  }

  //For starting the timer to count 30 seconds and end the call if callee is not connected with internet
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick == 33) {
        add(_EmitCallIndicationEvent(type: "CALL-END"));
      }
    });
  }

  //---------------- CONNECT CALL SOCKET BLOC --------------
  Future<void> _connectCallSocket(
    ConnectCallSocket event,
    Emitter<CallState> emit,
  ) async {
    await _websocketRepoImple.connectCallWebSocket(
      currentUserId: event.currentUserId,
      currentUserProfilePic: event.currentUserProfilePic,
      oppositeUserId: event.oppositeUserId,
    );

    //Getting stream of the data that is sending and receiving
    _subscription = _websocketRepoImple.getStream().listen((socketMsg) async {
      final Map<String, dynamic> callData =
          jsonDecode(socketMsg) as Map<String, dynamic>;

      if (callData['type'] == "GET-OFFER") {
        final Map<String, dynamic> data =
            jsonDecode(callData['data']) as Map<String, dynamic>;

        add(_EmitOfferEvent(data: data));
      }
      if (callData['type'] == "POST-ANSWER") {
        final Map<String, dynamic> data =
            jsonDecode(callData['data']) as Map<String, dynamic>;

        add(
          _EmitAnswerEvent(
            data: data,
            currentUserId: event.currentUserId,
            calleeId: event.oppositeUserId,
          ),
        );
      }
      if (callData['type'] == "GET-CANDIDATE") {
        try {
          final List<dynamic> candidates =
              callData['candidates'] as List<dynamic>;

          add(_EmitCandidateInfoEvent(candidates: candidates));
        } catch (e) {
          log('Catch error in bloc : $e');
        }
      }
      if (callData['type'] == "CALL-END" ||
          callData['type'] == "CALL-CONNECTING" ||
          callData['type'] == "CALL-CONNECTED" ||
          callData['type'] == "RINGING" ||
          callData['type'] == "DECLINE") {
        _timer?.cancel();
        _timer = null;
        add(_EmitCallIndicationEvent(type: callData['type']));
      }
    });
  }
}
