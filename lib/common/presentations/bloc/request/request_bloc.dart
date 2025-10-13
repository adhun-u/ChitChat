import 'package:bloc/bloc.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/data/repo_imple/request_user_repo_imple.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
part 'request_event.dart';
part 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  //Creating an instance for RequestUserRepoImple
  final RequestUserRepoImple _requestUserRepoImple = RequestUserRepoImple();
  RequestBloc() : super(RequestInitial()) {
    //Sent request event
    on<SentRequestEvent>(sentRequest);
  }

  //---------------- SEND REQUEST BLOC -----------------------
  Future<void> sentRequest(
    SentRequestEvent event,
    Emitter<RequestState> emit,
  ) async {
    emit(SentRequestLoadingState(userId: event.requestedUserId));
 final String? token = await getToken();
    if (token == null) {
      return emit(
        SentRequestErrorState(
          errorMessage: "Something went wrong",
          userId: event.requestedUserId,
        ),
      );
    }
    final Either<SuccessMessageModel?, ErrorMessageModel?> result =
        await _requestUserRepoImple.sentRequest(
          requestedUserId: event.requestedUserId,
          requestedUsername: event.requestedUsername,
          requestedUserProfilePic: event.requestedUserProfilePic,
          requestedUserbio: event.requestedUserbio,
          token: token,
          requestedDate: DateTime.now().toString(),
        );

    //Checking whether it returns success state or error state
    result.fold(
      //Success state
      (requestMessage) {
        if (requestMessage != null) {
          emit(
            SentRequestSuccessState(
              userId: event.requestedUserId,
              message: requestMessage.message,
            ),
          );
        }
        return emit(RequestInitial());
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(
            SentRequestErrorState(
              errorMessage: errorModel.message,
              userId: event.requestedUserId,
            ),
          );
        }
      },
    );
  }
}
