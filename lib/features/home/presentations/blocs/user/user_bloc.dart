import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/features/home/data/models/added_user_model.dart';
import 'package:chitchat/features/home/data/repo_imple/user_repo_imple.dart';
import 'package:dartz/dartz.dart';
part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  //Creating an instance for FetchUserRepoImple
  final UserRepoImple _userRepoImple = UserRepoImple();

  final int _limit = 40;
  int _currentPage = 1;
  bool _fullyFetched = false;

  Map<int, AddedUserWithLastMessageModel> friendsWithLastMessage = {};
  UserBloc() : super(UserInitial()) {
    //To fetch added user with last message
    on<FetchAddedUsersWithLastMessageEvent>(_fetchAddedUsersWithLastMessage);
    //To load more friends with last message
    on<LoadMoreFriendsWithLastMessageEvent>(_loadMoreFriends);
    //To change the order of the users according to the last message time
    on<ChangeUsersOrderEvent>(_changeOrder);
    //To remove a user from friends
    on<RemoveUserEvent>(_removeUser);
    //To change last message time
    on<ChangeLastMessageTimeEvent>(_changeLastMessageTime);
    //To change the position of a user that current user chats
    on<ChangePositionOfUserEvent>(_changePosition);
  }

  //-------- FETCH ADDED USERS WITH LAST MESSAGE BLOC ----------------
  Future<void> _fetchAddedUsersWithLastMessage(
    FetchAddedUsersWithLastMessageEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(FetchAddedUserWithLastMessageLoadingState());
 final String? token = await getToken();
    if (token == null) {
      return emit(
        FetchAddedUserWithLastMessageErrorState(
          errorMessage: "Something went wrong",
        ),
      );
    }
    _currentPage = 1;
    _fullyFetched = false;
    final Either<List<AddedUserWithLastMessageModel>?, ErrorMessageModel?>
    result = await _userRepoImple.fetchAddedUsersWithLastMessage(
      token: token,
      currentUserId: event.currentUserId,
      limit: _limit,
      page: _currentPage,
    );

    //Checking whether it returns success state or error state
    result.fold(
      //Success state
      (friends) {
        if (friends != null) {
          friendsWithLastMessage.clear();
          for (var friend in friends) {
            friendsWithLastMessage[friend.userId] = friend;
          }
          if (friends.length < _limit) {
            _fullyFetched = true;
          } else {
            _currentPage++;
          }
          return emit(
            FetchAddedUserWithLastMessageSuccessState(
              addedUsers: friendsWithLastMessage.values.toList(),
            ),
          );
        }
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(
            FetchAddedUserWithLastMessageErrorState(
              errorMessage: errorModel.message,
            ),
          );
        }
      },
    );
  }

  //----------- LOAD MORE FRIENDS BLOC ---------------
  void _loadMoreFriends(
    LoadMoreFriendsWithLastMessageEvent event,
    Emitter<UserState> emit,
  ) async {
    if (!_fullyFetched) {
      emit(LoadMoreFriendsWithLastMessageLoadingState());
       final String? token = await getToken();
      if (token == null) {
        return emit(LoadMoreFriendsWithLastMessageErrorState());
      }

      final Either<List<AddedUserWithLastMessageModel>?, ErrorMessageModel?>
      result = await _userRepoImple.fetchAddedUsersWithLastMessage(
        token: token,
        currentUserId: event.currentUserId,
        limit: _limit,
        page: _currentPage,
      );

      result.fold(
        (friends) {
          if (friends != null) {
            for (var friend in friends) {
              if (!friendsWithLastMessage.containsKey(friend.userId)) {
                friendsWithLastMessage[friend.userId] = friend;
              }
            }

            if (friends.length < _limit) {
              _fullyFetched = true;
              emit(LoadMoreFriendsWithLastMessageSuccessState());
            } else {
              _currentPage++;
            }

            return emit(
              FetchAddedUserWithLastMessageSuccessState(
                addedUsers: friendsWithLastMessage.values.toList(),
              ),
            );
          }
        },
        (error) {
          return emit(LoadMoreFriendsWithLastMessageErrorState());
        },
      );
    }
  }

  //------------- CHANGE ORDER BLOC -------------------
  void _changeOrder(ChangeUsersOrderEvent event, Emitter<UserState> emit) {
    List<int> keys = friendsWithLastMessage.keys.toList();

    final bool contains = friendsWithLastMessage.containsKey(event.userId);

    if (keys.isNotEmpty && contains) {
      keys = [];
      final AddedUserWithLastMessageModel? friend = friendsWithLastMessage
          .remove(event.userId);

      if (friend != null) {
        //Changing the order
        final Map<int, AddedUserWithLastMessageModel> user = {
          event.userId: AddedUserWithLastMessageModel(
            userId: event.userId,
            username: event.username,
            userbio: friend.userbio,
            profilePic: friend.profilePic,
            lastMessage: event.lastMessage,
            lastTime: event.time,
            unreadMessageCount: event.unreadMessageCount,
            messageType: event.messageType,
            isSeen: false,
            isMe: false,
          ),
        };
        friendsWithLastMessage = {
          event.userId: user.values.toList()[0],
          ...friendsWithLastMessage,
        };
        emit(
          FetchAddedUserWithLastMessageSuccessState(
            addedUsers: friendsWithLastMessage.values.toList(),
          ),
        );
      }
    } else {
      //Inserting new one
      final AddedUserWithLastMessageModel newFriend =
          AddedUserWithLastMessageModel(
            userId: event.userId,
            username: event.username,
            userbio: event.userbio,
            profilePic: event.profilePic,
            lastMessage: event.lastMessage,
            lastTime: event.time,
            unreadMessageCount: 1,
            messageType: event.messageType,
            isSeen: false,
            isMe: false,
          );

      friendsWithLastMessage = {
        newFriend.userId: newFriend,
        ...friendsWithLastMessage,
      };

      emit(
        FetchAddedUserWithLastMessageSuccessState(
          addedUsers: friendsWithLastMessage.values.toList(),
        ),
      );
    }
  }

  //------------ REMOVE USER BLOC ----------------
  void _removeUser(RemoveUserEvent event, Emitter<UserState> emit) async {
    emit(RemoveUserLoadingState(userId: event.userId));
 final String? token = await getToken();
    if (token == null) {
      return emit(RemoveUserErrorState(userId: event.userId));
    }

    final Either<SuccessMessageModel, ErrorMessageModel> result =
        await _userRepoImple.removeUser(token: token, userId: event.userId);

    result.fold(
      (success) {
        friendsWithLastMessage.remove(event.userId);
        emit(
          FetchAddedUserWithLastMessageSuccessState(
            addedUsers: friendsWithLastMessage.values.toList(),
          ),
        );
        return emit(RemoveUserSuccessState(userId: event.userId));
      },
      (error) {
        emit(RemoveUserErrorState(userId: event.userId));
      },
    );
  }

  //------------- CHANGE LAST MESSAGE TIME BLOC ---------------
  void _changeLastMessageTime(
    ChangeLastMessageTimeEvent event,
    Emitter<UserState> emit,
  ) async {
     final String? token = await getToken();
    if (token != null) {
      final Either<SuccessMessageModel, ErrorMessageModel> result =
          await _userRepoImple.changeLastMessageTime(
            oppositeUserId: event.userId,
            token: token,
          );

      result.fold(
        (success) {
          printDebug("Changed successfully");
        },
        (error) {
          printDebug("Something went wrong while changing last message time ");
        },
      );
    }
  }

  //---------------- CHANGE POSITION BLOC --------------
  void _changePosition(
    ChangePositionOfUserEvent event,
    Emitter<UserState> emit,
  ) async {
    //First of all removing the user from the position where the user is , then adding to first position
    final AddedUserWithLastMessageModel? removedFriend = friendsWithLastMessage
        .remove(event.userId);

    if (removedFriend != null) {
      final String lastMessage =
          event.lastMessageType == "text"
              ? event.lastTextMessage
              : event.lastMessageType == "image"
              ? event.lastImageText
              : "";
      friendsWithLastMessage = {
        removedFriend.userId: AddedUserWithLastMessageModel(
          userId: removedFriend.userId,
          username: removedFriend.username,
          userbio: removedFriend.userbio,
          profilePic: removedFriend.profilePic,
          lastMessage: lastMessage,
          lastTime: event.lastMessageTime,
          unreadMessageCount: 0,
          messageType: event.lastMessageType,
          isSeen: false,
          isMe: true,
        ),
        ...friendsWithLastMessage,
      };

      emit(
        FetchAddedUserWithLastMessageSuccessState(
          addedUsers: friendsWithLastMessage.values.toList(),
        ),
      );
    } else {
      log('The friend is null');
    }
  }
}
