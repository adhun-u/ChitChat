import 'package:bloc/bloc.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/features/home/data/models/accept_request_model.dart';
import 'package:chitchat/features/home/data/models/request_user_model.dart';
import 'package:chitchat/features/home/data/models/sent_request_user_model.dart';
import 'package:chitchat/features/home/data/models/withdraw_request_model.dart';
import 'package:chitchat/features/home/data/repo_imple/requested_users_repo_imple.dart';
import 'package:dartz/dartz.dart';
part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  //Creating an instance for RequestedUserRepoImple
  final RequestedUsersRepoImple _requestedUsersRepoImple =
      RequestedUsersRepoImple();

  final List<SentRequestUserModel> _sentRequestUsers = [];
  final List<RequestUserModel> _requestedUsers = [];

  int _currentPageForRequestedUsers = 1;
  bool _fullyFetchedRequestedUsers = false;
  final int _limit = 40;
  int _currentPageForSentUsers = 1;
  bool _fullyFetchedSentUsers = false;
  FriendsBloc() : super(FriendsInitial()) {
    //To fetch requested users event
    on<FetchRequestedUsersEvent>(fetchRequestedUsers);
    //To accept request event
    on<AcceptRequestedEvent>(acceptRequest);
    //To fetch sent request users event
    on<FetchSentRequestEvent>(fetchSentRequestUsers);
    //To withdraw request event
    on<WithdrawRequestEvent>(withdrawRequest);
    //To decline a request
    on<DeclineRequestEvent>(_declineRequest);
    //To load more requested users data
    on<LoadMoreRequestedUsersEvent>(_loadMoreRequestedUsers);
    //To load more sent users data
    on<LoadMoreSentUsersEvent>(_loadMoreSentUsers);
  }

  //------------- FETCH REQUESTED USERS BLOC ---------------------
  Future<void> fetchRequestedUsers(
    FetchRequestedUsersEvent event,
    Emitter<FriendsState> emit,
  ) async {
    if (!event.shouldCallApi) {
      return emit(
        FetchRequestedUsersSuccessState(requestedUsers: _requestedUsers),
      );
    }
    final String? token = await getToken();
    if (token != null) {
      emit(FetchRequestedUsersLoadingState());

      final Either<List<RequestUserModel>?, ErrorMessageModel?> result =
          await _requestedUsersRepoImple.fetchRequested(
            token: token,
            limit: _limit,
            page: _currentPageForRequestedUsers,
          );

      //Checking whether it returns success state or error state
      result.fold(
        //Success state
        (requestedUsers) {
          if (requestedUsers != null) {
            _requestedUsers.clear();
            _requestedUsers.addAll(requestedUsers);

            if (requestedUsers.length < _limit) {
              _fullyFetchedRequestedUsers = true;
            } else {
              _currentPageForRequestedUsers = _currentPageForRequestedUsers + 1;
            }
          }
          return emit(
            FetchRequestedUsersSuccessState(requestedUsers: _requestedUsers),
          );
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(
              FetchRequestedUsersErrorState(errorMessage: errorModel.message),
            );
          }
        },
      );
    } else {
      emit(FetchRequestedUsersErrorState(errorMessage: 'Something went wrong'));
    }
  }

  //------------------ LOAD MORE REQUESTED USERS BLOC --------------------
  void _loadMoreRequestedUsers(
    LoadMoreRequestedUsersEvent event,
    Emitter<FriendsState> emit,
  ) async {
    if (!_fullyFetchedRequestedUsers) {
      emit(LoadMoreRequestedUsersLoadingState());
      final String? token = await getToken();
      if (token == null) {
        return emit(LoadMoreRequestedUsersErrorState());
      }

      final Either<List<RequestUserModel>?, ErrorMessageModel?> result =
          await _requestedUsersRepoImple.fetchRequested(
            token: token,
            limit: _limit,
            page: _currentPageForRequestedUsers,
          );

      result.fold(
        (requestedUsers) {
          if (requestedUsers != null) {
            _requestedUsers.addAll(requestedUsers);

            if (requestedUsers.length < _limit) {
              _fullyFetchedRequestedUsers = true;
            } else {
              _currentPageForRequestedUsers = _currentPageForRequestedUsers + 1;
            }

            emit(LoadMoreRequestedUsersSuccessState());
            emit(
              FetchRequestedUsersSuccessState(requestedUsers: _requestedUsers),
            );
          }
        },
        (error) {
          emit(LoadMoreRequestedUsersErrorState());
        },
      );
    }
  }

  //------------------ ACCEPT REQUEST BLOC -----------------------
  Future<void> acceptRequest(
    AcceptRequestedEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(RequestAcceptLoadingState(userId: event.userId));
    final String? token = await getToken();
    if (token != null) {
      final result = await _requestedUsersRepoImple.acceptRequsted(
        requestedUserId: event.userId,
        token: token,
      );

      //Checking whether it returns success state or error state
      result.fold(
        //Success state
        (acceptRequestModel) {
          if (acceptRequestModel != null) {
            //Removing the user from _requestedUsers list
            _requestedUsers.removeWhere((user) {
              return user.requestedUserId == user.requestedUserId;
            });
            emit(
              FetchRequestedUsersSuccessState(requestedUsers: _requestedUsers),
            );
            return emit(
              RequestAcceptSuccessState(acceptRequestModel: acceptRequestModel),
            );
          }
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(
              RequestAcceptErrorState(errorMessage: errorModel.message),
            );
          }
        },
      );
    } else {
      return emit(NullState());
    }
  }

  //------------------- FETCH SENT REQUEST USERS BLOC ---------------------------
  Future<void> fetchSentRequestUsers(
    FetchSentRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FetchSentRequestLoadingState());

    if (!event.shouldCallApi) {
      return emit(
        FetchSentRequestSuccessState(sentRequestUsers: _sentRequestUsers),
      );
    }
    final String? token = await getToken();
    if (token != null) {
      final Either<List<SentRequestUserModel>?, ErrorMessageModel?> result =
          await _requestedUsersRepoImple.fetchSentRequestUsers(
            token: token,
            limit: _limit,
            page: _currentPageForSentUsers,
          );

      //Checking whether it returns success state or error state
      result.fold(
        //Success state
        (sentUsers) {
          if (sentUsers != null) {
            _sentRequestUsers.clear();
            _sentRequestUsers.addAll(sentUsers);

            if (sentUsers.length < _limit) {
              _fullyFetchedSentUsers = true;
            } else {
              _currentPageForSentUsers = _currentPageForSentUsers + 1;
            }
          }

          return emit(
            FetchSentRequestSuccessState(sentRequestUsers: _sentRequestUsers),
          );
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(
              FetchSentRequestErrorState(errorMessage: errorModel.message),
            );
          }
        },
      );
    } else {
      return emit(NullState());
    }
  }

  //------------------- LOAD MORE SENT USERS ------------------
  void _loadMoreSentUsers(
    LoadMoreSentUsersEvent event,
    Emitter<FriendsState> emit,
  ) async {
    if (!_fullyFetchedSentUsers) {
      emit(LoadMoreSentUsersLoadingState());
      final String? token = await getToken();
      if (token == null) {
        return emit(LoadMoreSentUsersErrorState());
      }

      final Either<List<SentRequestUserModel>?, ErrorMessageModel?> result =
          await _requestedUsersRepoImple.fetchSentRequestUsers(
            token: token,
            limit: _limit,
            page: _currentPageForSentUsers,
          );

      result.fold(
        (sentRequestUsers) {
          if (sentRequestUsers != null) {
            _sentRequestUsers.addAll(sentRequestUsers);

            if (sentRequestUsers.length < _limit) {
              _fullyFetchedSentUsers = true;
            } else {
              _currentPageForSentUsers = _currentPageForSentUsers + 1;
            }

            emit(LoadMoreSentUsersSuccessState());
            emit(
              FetchSentRequestSuccessState(sentRequestUsers: _sentRequestUsers),
            );
          }
        },
        (error) {
          return emit(LoadMoreSentUsersErrorState());
        },
      );
    }
  }

  //----------- WITHDRAW REQUEST BLOC -----------------
  Future<void> withdrawRequest(
    WithdrawRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(RequestWithdrawLoadingState(userId: event.userId));
    final String? token = await getToken();
    if (token == null) {
      return emit(
        RequestWithdrawErrorState(
          errorMessage: 'Something went wrong',
          userId: event.userId,
        ),
      );
    }

    final Either<WithdrawRequestModel?, ErrorMessageModel?> result = await _requestedUsersRepoImple.withdrawRequest(
      token: token,
      userId: event.userId,
    );

    //Checking whether the result was success state or error state
    result.fold(
      //Success state
      (withdrawRequestModel) {
        if (withdrawRequestModel != null) {
          //Removing the user from _sentRequest user
          _sentRequestUsers.removeWhere((user) {
            return user.sentUserId == withdrawRequestModel.withdrawnUserId;
          });
          emit(
            FetchSentRequestSuccessState(sentRequestUsers: _sentRequestUsers),
          );
          return emit(
            RequestWithdrawSuccessState(
              message: withdrawRequestModel.message,
              withdrawnUserId: withdrawRequestModel.withdrawnUserId,
            ),
          );
        }
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(
            RequestWithdrawErrorState(
              errorMessage: errorModel.message,
              userId: event.userId,
            ),
          );
        }
      },
    );
  }

  //---------------------- DECLINE REQUEST BLOC --------------
  Future<void> _declineRequest(
    DeclineRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(DeclineLoadingState(userId: event.userId));
    final String? token = await getToken();
    if (token == null) {
      return emit(
        DeclineErrorState(
          userId: event.userId,
          message: "Something went wrong",
        ),
      );
    }

    final Either<SuccessMessageModel?, ErrorMessageModel?> result =
        await _requestedUsersRepoImple.declineRequest(
          token: token,
          declinedUserId: event.userId,
        );

    //Checking whether it returns success or error state
    result.fold(
      (success) {
        if (success != null) {
          //Removing the user from _requests list
          _requestedUsers.removeWhere((user) {
            return user.requestedUserId == event.userId;
          });
          emit(
            DeclineSuccessState(userId: event.userId, message: success.message),
          );
          return emit(
            FetchRequestedUsersSuccessState(requestedUsers: _requestedUsers),
          );
        }
      },
      (error) {
        if (error != null) {
          return emit(
            DeclineErrorState(userId: event.userId, message: error.message),
          );
        }
      },
    );
  }
}
