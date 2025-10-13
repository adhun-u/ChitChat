import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/features/group/data/repo_imple/group_call_repo_imple.dart';
import 'package:dartz/dartz.dart';
part 'group_call_event.dart';
part 'group_call_state.dart';

class GroupCallBloc extends Bloc<GroupCallEvent, GroupCallState> {

  final GroupCallRepoImple _groupCallRepoImple = GroupCallRepoImple();
  Timer? _timer;
  GroupCallBloc() : super(GroupCallInitial()) {
    //To join or create a room
    on<JoinGroupCallEvent>(_joinRoom);
    //To start timer
    on<StartGroupCallTimer>((_, emit) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timer.tick == 35) {
          add(_EmitGroupCallTimeOutEvent());
        }
      });
    });
    //To emit the state when timeouts
    on<_EmitGroupCallTimeOutEvent>((_, emit) {
      emit(GroupCallTimeOutState());
    });
    //To stop timer
    on<StopGroupCallTimer>((_, _) {
      _timer?.cancel();
    });
  }
  //-------------- JOIN ROOM BLOC -------------
  void _joinRoom(JoinGroupCallEvent event, Emitter<GroupCallState> emit) async {
     final String? token = await getToken();
    emit(JoinGroupCallLoadingState());
    if (token == null) {
      return emit(
        JoinGroupCallErrorState(errorMessage: 'Something went wrong'),
      );
    }

    final Either<String, ErrorMessageModel> result = await _groupCallRepoImple
        .createRoom(
          groupName: event.groupName,
          userId: event.currentUserId,
          profilePic: event.profilePic,
          groupProfilePic: event.groupProfilePic,
          username: event.username,
          groupId: event.groupId,
          callType: event.callType,
          token: token,
        );

    //Checking whether it returns success state or error state
    result.fold(
      (token) {
        return emit(JoinGroupCallSuccessState(token: token));
      },
      (error) {
        return emit(JoinGroupCallErrorState(errorMessage: error.message));
      },
    );
  }
}
