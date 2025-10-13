import 'package:bloc/bloc.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/features/group/data/datasource/group_chat_storage.dart';
import 'package:chitchat/features/group/data/models/group_edited_model.dart';
import 'package:chitchat/features/group/data/models/group_model.dart';
import 'package:chitchat/features/group/data/repo_imple/group_chat_repo_imple.dart';
import 'package:chitchat/features/group/data/repo_imple/group_repo_imple.dart';
import 'package:chitchat/features/group/domain/entities/chat_storage/group_chat_storage_model.dart';
import 'package:chitchat/features/home/data/models/added_user_model.dart';
import 'package:dartz/dartz.dart';
part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  //Creating an instance of GroupRepoImple to access group related function such as add , remove member
  final GroupRepoImple _groupRepoImple = GroupRepoImple();
  //Createing an instance of GroupChatRepoImple for getting chat related functins
  final GroupChatRepoImple _groupChatRepoImple = GroupChatRepoImple();
  //Groups
  Map<String, GroupModel> addedGroups = {};
  //Group members
  Map<int, GroupAddedUserModel> groupMembers = {};
  //Group requests
  final Map<int, GroupRequestUserModel> _requests = {};
  //Searched groups
  final Map<String, SearchGroupModel> _searchedGroups = {};

  final List<AddedUserOnlyModel> _addedUsers = [];

  final int _limit = 40;
  int _currentPage = 1;
  int _currentPageForGroupRequests = 1;
  int _currentPageForGroupMembers = 1;
  int _currentPageForUsers = 1;
  int _currentPageForGroups = 1;

  bool _fullFetched = false;
  bool _fullFetchedGroupRequests = false;
  bool _fullyFetchedGroupMembers = false;
  bool _fullyFetchedUsers = false;
  bool _fullyFetchedGroups = false;

  String prevSearchedGroupName = "";

  int currentGroupMembersCount = 0;
  final GroupChatStorage _storage = GroupChatStorage();
  GroupBloc() : super(GroupInitial()) {
    //To clear lists
    on<ClearGroupListEvent>((event, emit) {
      groupMembers.clear();
      _requests.clear();
    });
    //To current group members count
    on<AddGroupMembersCountEvent>((event, emit) {
      currentGroupMembersCount = event.membersCount;
      emit(
        FetchGroupMembersCountSuccessState(
          membersCount: currentGroupMembersCount,
        ),
      );
    });
    //To create group
    on<CreateGroupEvent>(_createGroup);
    //To fetch groups
    on<FetchGroupsEvent>(_fetchGroups);
    //To search groups
    on<SearchGroupsEvent>(_searchGroups);
    //To load more search results
    on<LoadMoreGroupSearchResutlEvent>(_loadMoreSearchResults);
    //To send request
    on<SendRequestEvent>(_sendRequest);
    //To fetch members of a group
    on<FetchGroupAddedUsersEvent>(_fetchGroupMembers);
    //To fetch group requests
    on<FetchGroupRequestsEvent>(_fetchGroupRequests);
    //To edit group info
    on<EditGroupInfoEvent>(_editGroup);
    //To fetch added user only
    on<FetchUsersToAddMemberEvent>(_fetchUsersToAddMember);
    //To add a member to group
    on<AddMemberToGroupEvent>(_addMember);
    //To accept a group request
    on<AcceptGroupRequestEvent>(_acceptGroupRequest);
    //To decline a group request
    on<DeclineGroupRequestEvent>(_declineGroupRequest);
    //To remove a member from group
    on<RemoveMemberEvent>(_removeMember);
    //To search someone while adding
    on<SearchMembersToAddEvent>(_searchMembersToAdd);
    //To exit from a group
    on<LeaveFromGroupEvent>(_leaveFromGroup);
    //To fetch group media items
    on<FetchGroupMediaItems>(_fetchMediaItems);
    //To load more group requests
    on<LoadMoreGroupRequestsEvent>(_loadMoreGroupRequests);
    //To load more group members
    on<LoadMoreGroupMembersEvent>(_loadMoreGroupMembers);
    //To laod more users to add member
    on<LoadMoreUsersToAddMemberEvent>(_loadMoreUsersToAddMember);
    //To load more groups
    on<LoadMoreGroupsEvent>(_loadMoreGroups);
    //To change last message time
    on<ChangeLastGroupMessageTimeEvent>(_changeLastMessageTime);
    //To change group position when current sends message
    on<ChangeGroupPositionEvent>(_changePosition);
    //To change group position when someone sends any message
    on<ChangeGroupOrderEvent>(_changeGroupOrder);
  }

  //------------ CREATE GROUP BLOC --------------
  Future<void> _createGroup(
    CreateGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(CreateGroupLoadingState());
 final String? token = await getToken();
    if (token == null) {
      return emit(CreateGroupErrorState(message: 'Something went wrong'));
    }
    final Either<SuccessMessageModel?, ErrorMessageModel?> result =
        await _groupRepoImple.createGroup(
          token: token,
          groupName: event.groupName,
          groupBio: event.groupBio,
          imagePath: event.groupImagePath,
          currentUserId: event.currentUserId,
        );

    //Checking whether it returns success state or error state
    result.fold(
      (successModel) {
        if (successModel != null) {
          return emit(CreateGroupSuccessState(message: successModel.message));
        }
      },
      (errorModel) {
        if (errorModel != null) {
          return emit(CreateGroupErrorState(message: errorModel.message));
        }
      },
    );
  }

  //----------------- FETCH GROUPS BLOC -----------------
  Future<void> _fetchGroups(
    FetchGroupsEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(FetchGroupsLoadingState());
     final String? token = await getToken();
    if (token == null) {
      return emit(FetchGroupsErrorState(message: 'Something went wrong'));
    }
    _currentPageForGroups = 1;
    final Either<List<GroupModel>?, ErrorMessageModel?> result =
        await _groupRepoImple.fetchGroups(
          token: token,
          currentUserId: event.currentUserId,
          limit: _limit,
          page: _currentPageForGroups,
        );

    //Checking whether it returns success state or error state
    result.fold(
      //Success state
      (groups) {
        if (groups != null) {
          for (var group in groups) {
            addedGroups[group.groupId] = group;
          }
          if (groups.length < _limit) {
            _fullyFetchedGroups = true;
          } else {
            _currentPageForGroups = _currentPageForGroups + 1;
          }
          return emit(
            FetchGroupsSuccessState(groups: addedGroups.values.toList()),
          );
        }
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(FetchGroupsErrorState(message: errorModel.message));
        }
      },
    );
  }

  //---------------- SEARCH GROUP BLOC ---------------
  Future<void> _searchGroups(
    SearchGroupsEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(SearchGroupLoadingState());
 final String? token = await getToken();
    if (token == null) {
      return emit(SearchGroupErrorState(message: 'Something went wrong'));
    }
    final Either<List<SearchGroupModel>?, ErrorMessageModel?> result =
        await _groupRepoImple.searchGroup(
          token: token,
          groupName: event.groupName,
          limit: _limit,
          page: _currentPage,
        );

    //Checking whether it return success state or error state
    result.fold(
      //Success state
      (groups) {
        prevSearchedGroupName = event.groupName;
        if (groups != null) {
          if (groups.length < _limit) {
            _fullFetched = true;
          } else {
            _currentPage = _currentPage + 1;
          }
          for (var group in groups) {
            _searchedGroups[group.groupId] = group;
          }
          return emit(
            SearchGroupSuccessState(groups: _searchedGroups.values.toList()),
          );
        }
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(SearchGroupErrorState(message: errorModel.message));
        }
      },
    );
  }

  //--------------- LOAD MORE SEARCH RESULTS BLOC ---------------
  void _loadMoreSearchResults(
    LoadMoreGroupSearchResutlEvent event,
    Emitter<GroupState> emit,
  ) async {
    if (!_fullFetched) {
      emit(LoadMoreGroupSearchResultLoadingState());
       final String? token = await getToken();
      if (token == null) {
        return emit(LoadMoreGroupSearchResultErrorState());
      }

      final Either<List<SearchGroupModel>?, ErrorMessageModel?> result =
          await _groupRepoImple.searchGroup(
            token: token,
            groupName: prevSearchedGroupName,
            limit: _limit,
            page: _currentPage,
          );

      result.fold(
        (groups) {
          if (groups != null) {
            if (groups.length < _limit) {
              _fullFetched = true;
            } else {
              _currentPage = _currentPage + 1;
            }
            for (var group in groups) {
              _searchedGroups[group.groupId] = group;
            }
          }
          emit(
            SearchGroupSuccessState(groups: _searchedGroups.values.toList()),
          );
          emit(LoadMoreGroupSearchResultSuccessState());
        },
        (error) {
          emit(LoadMoreGroupSearchResultErrorState());
        },
      );
    }
  }

  //---------------- SEND REQUEST BLOC --------------
  Future<void> _sendRequest(
    SendRequestEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(SendRequestLoadingState(groupId: event.groupId));
 final String? token = await getToken();
    if (token == null) {
      return emit(SendRequestErrorState(message: 'Something went wrong'));
    }
    final Either<String?, ErrorMessageModel?> result = await _groupRepoImple
        .requestGroup(
          token: token,
          groupName: event.groupName,
          groupId: event.groupId,
          groupAdminId: event.groupAdminId,
        );

    //Checking whether it returns success state or error state
    result.fold(
      //Success state
      (groupId) {
        if (groupId != null) {
          return emit(SendRequestSuccessState(groupId: groupId));
        }
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(SendRequestErrorState(message: errorModel.message));
        }
      },
    );
  }

  //------------------ FETCH ADDED USERS BLOC ------------
  Future<void> _fetchGroupMembers(
    FetchGroupAddedUsersEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(FetchGroupAddedUsersLoadingState());
 final String? token = await getToken();
    if (token == null) {
      return emit(
        FetchGroupAddedUsersErrorState(errorMessage: 'Something went wrong'),
      );
    }
    _currentPageForGroupMembers = 1;
    _fullyFetchedGroupMembers = false;
    //Calling api only if shouldCallApi is true , otherwise emitting only _groupMembers list
    if (event.shouldCallApi) {
      final Either<List<GroupAddedUserModel>?, ErrorMessageModel?> result =
          await _groupRepoImple.fetchGroupAddedUsers(
            token: token,
            groupId: event.groupId,
            limit: _limit,
            page: _currentPageForGroupMembers,
          );

      //Checking whether it returns success state or error state
      result.fold(
        //Success state
        (addedUsers) {
          if (addedUsers != null) {
            groupMembers.clear();
            for (var member in addedUsers) {
              groupMembers[member.userId] = member;
            }
            if (addedUsers.length < _limit) {
              _fullyFetchedGroupMembers = true;
            } else {
              _currentPageForGroupMembers++;
            }
          }
          return emit(
            FetchGroupAddedUsersSuccessState(
              addedUsers: groupMembers.values.toList(),
            ),
          );
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(
              FetchGroupAddedUsersErrorState(errorMessage: errorModel.message),
            );
          }
        },
      );
    } else {
      return emit(
        FetchGroupAddedUsersSuccessState(
          addedUsers: groupMembers.values.toList(),
        ),
      );
    }
  }

  //------------------ FETCH GROUP REQUESTS BLOC -----------
  Future<void> _fetchGroupRequests(
    FetchGroupRequestsEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(FetchGroupRequestsLoadingState());
 final String? token = await getToken();
    if (token == null) {
      return emit(
        FetchGroupRequestsErrorState(message: 'Something went wrong'),
      );
    }

    _currentPageForGroupRequests = 1;
    _fullFetchedGroupRequests = false;
    //Calling api if shouldCalliApi is true , otherwise only emitting the _requests list
    if (event.shouldCallApi) {
      final Either<List<GroupRequestUserModel>?, ErrorMessageModel?> result =
          await _groupRepoImple.fetchGroupRequests(
            token: token,
            groupId: event.groupId,
            limit: _limit,
            page: _currentPageForGroupRequests,
          );

      //Checking whether the result returns success or not
      result.fold(
        //Success state
        (requests) {
          if (requests != null) {
            _requests.clear();
            for (var requestedUser in requests) {
              _requests[requestedUser.userId] = requestedUser;
            }
            if (requests.length < _limit) {
              _fullFetchedGroupRequests = true;
            } else {
              _currentPageForGroupRequests++;
            }
          }
          return emit(
            FetchGroupRequestsSuccessState(requests: _requests.values.toList()),
          );
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(
              FetchGroupRequestsErrorState(message: errorModel.message),
            );
          }
        },
      );
    } else {
      return emit(
        FetchGroupRequestsSuccessState(requests: _requests.values.toList()),
      );
    }
  }

  //------------- EDIT GROUP INFO BLOC ----------------
  Future<void> _editGroup(
    EditGroupInfoEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(EditGroupLoadingState());
 final String? token = await getToken();
    if (token == null) {
      return emit(EditGroupErrorState(message: 'Something went wrong'));
    }

    final Either<GroupEditedModel, ErrorMessageModel> result =
        await _groupRepoImple.editGroupInfo(
          token: token,
          groupId: event.groupId,
          newGroupName: event.newGroupName,
          newGroupBio: event.newGroupBio,
          newGroupImagePath: event.newGroupImagePath,
        );

    //Checking whether it returns success state or error statet
    result.fold(
      (groupEditedDetails) {
        final GroupModel? group = addedGroups[groupEditedDetails.groupId];
        if (group != null) {
          final String oldGroupImageUrl = group.groupImageUrl;
          final String oldGroupName = group.groupName;
          final String oldGroupBio = group.groupBio;
          addedGroups[group.groupId] = GroupModel(
            groupId: group.groupId,
            groupName:
                groupEditedDetails.newGroupName != null &&
                        groupEditedDetails.newGroupName!.isNotEmpty
                    ? groupEditedDetails.newGroupName!
                    : oldGroupName,
            groupImageUrl:
                groupEditedDetails.newGroupImageUrl != null &&
                        groupEditedDetails.newGroupImageUrl!.isNotEmpty
                    ? groupEditedDetails.newGroupImageUrl!
                    : oldGroupImageUrl,
            groupBio:
                groupEditedDetails.newGroupBio != null &&
                        groupEditedDetails.newGroupBio!.isNotEmpty
                    ? groupEditedDetails.newGroupBio!
                    : oldGroupBio,
            groupAdminUserId: group.groupAdminUserId,
            createdAt: group.createdAt,
            membersCount: group.membersCount,
            isMe: group.isMe,
            isSeenLastMessage: group.isSeenLastMessage,
            lastMessage: group.lastMessage,
            lastMessageTime: group.lastMessageTime,
            lastMessageType: group.lastMessageType,
            lastImageText: group.lastImageText,
            unreadMessagesCount: group.unreadMessagesCount,
          );

          emit(FetchGroupsSuccessState(groups: addedGroups.values.toList()));
        }
        return emit(EditGroupSuccessState(message: "Updated successfully"));
      },
      (error) {
        return emit(EditGroupErrorState(message: error.message));
      },
    );
  }

  //------------- FETCH USERS TO ADD MEMBER ONLY BLOC ---------------
  Future<void> _fetchUsersToAddMember(
    FetchUsersToAddMemberEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(FetchAddedUsersOnlyLoadingState());

     final String? token = await getToken();
    if (token == null) {
      return emit(
        FetchAddedUsersOnlyErrorState(message: 'Something went wrong'),
      );
    }

    _currentPageForUsers = 1;
    _fullyFetchedUsers = false;
    final Either<List<AddedUserOnlyModel>?, ErrorMessageModel?> result =
        await _groupRepoImple.fetchUsersToAddMember(
          token: token,
          groupId: event.groupId,
          limit: _limit,
          page: _currentPageForUsers,
        );
    //Checking whether it returns success state or error state
    result.fold(
      (addedUsers) {
        if (addedUsers != null) {
          _addedUsers.clear();
          _addedUsers.addAll(addedUsers);
          if (addedUsers.length < _limit) {
            _fullyFetchedUsers = true;
          } else {
            _currentPageForUsers++;
          }
          emit(FetchAddedUsersOnlySuccessState(addedUsers: _addedUsers));
          return;
        }
      },
      (error) {
        if (error != null) {
          return emit(FetchAddedUsersOnlyErrorState(message: error.message));
        }
      },
    );
  }

  //-------------- ADD MEMBER TO GROUP BLOC -------------
  Future<void> _addMember(
    AddMemberToGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(AddMemberLoadingState(userId: event.userId));
     final String? token = await getToken();
    if (token == null) {
      return emit(
        AddMemberErrorState(
          message: 'Something went wrong',
          userId: event.userId,
        ),
      );
    }

    final Either<SuccessMessageModel?, ErrorMessageModel?> result =
        await _groupRepoImple.addMember(
          token: token,
          groupId: event.groupId,
          userId: event.userId,
        );
    //Checking whether it returns success state or error state
    result.fold(
      (success) async {
        if (success != null) {
          emit(
            AddMemberSuccessState(
              message: success.message,
              userId: event.userId,
            ),
          );
          //Adding to added users
          groupMembers[event.userId] = GroupAddedUserModel(
            username: event.username,
            userId: event.userId,
            profilePic: event.profilePic,
            userBio: event.userBio,
          );
          currentGroupMembersCount = currentGroupMembersCount + 1;
          emit(
            FetchGroupMembersCountSuccessState(
              membersCount: currentGroupMembersCount,
            ),
          );
          emit(
            FetchGroupAddedUsersSuccessState(
              addedUsers: groupMembers.values.toList(),
            ),
          );

          await _groupChatRepoImple.addMemberToFireStore(
            userId: event.userId,
            groupId: event.groupId,
          );
        }
      },
      (error) {
        if (error != null) {
          return emit(
            AddMemberErrorState(message: error.message, userId: event.userId),
          );
        }
      },
    );
  }

  //--------------- ACCEPT GROUP REQUEST BLOC ----------------
  Future<void> _acceptGroupRequest(
    AcceptGroupRequestEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(
      AcceptGroupRequestLoadingState(
        groupId: event.groupId,
        userId: event.userId,
      ),
    );
     final String? token = await getToken();
    if (token == null) {
      return emit(
        AcceptGroupRequestErrorState(
          message: 'Something went wrong',
          userId: event.userId,
        ),
      );
    }

    final Either<SuccessMessageModel?, ErrorMessageModel?> result =
        await _groupRepoImple.acceptGroupRequest(
          token: token,
          userId: event.userId,
          groupId: event.groupId,
          groupImage: event.groupImage,
          groupName: event.groupName,
        );

    //Checking whether the result is success or failer
    result.fold(
      (success) async {
        if (success != null) {
          //Removing the request from requests list if the request is accepted
          _requests.remove(event.userId);
          emit(
            AcceptGroupRequestSuccessState(
              groupId: event.groupId,
              userId: event.userId,
            ),
          );
          emit(
            FetchGroupMembersCountSuccessState(
              membersCount: currentGroupMembersCount + 1,
            ),
          );
          emit(
            FetchGroupRequestsSuccessState(requests: _requests.values.toList()),
          );
        }
      },
      (error) {
        if (error != null) {
          return emit(
            AcceptGroupRequestErrorState(
              message: 'Something went wrong',
              userId: event.userId,
            ),
          );
        }
      },
    );
  }

  //----------------------- DECLINE GROUP REQUEST BLOC --------------------
  Future<void> _declineGroupRequest(
    DeclineGroupRequestEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(DeclineGroupRequestLoadingState(userId: event.userId));
 final String? token = await getToken();
    if (token == null) {
      return emit(DeclineGroupRequestErrorState(userId: event.userId));
    }

    final Either<SuccessMessageModel?, ErrorMessageModel?> result =
        await _groupRepoImple.declineGroupRequest(
          token: token,
          userId: event.userId,
          groupId: event.groupId,
        );

    //Checking whether the result return success state or error state
    result.fold(
      //Success
      (_) {
        //Removing the request from requests list
        _requests.remove(event.userId);

        emit(
          DeclineGroupRequestSuccessState(
            message: 'Declined successfully',
            userId: event.userId,
          ),
        );
        return emit(
          FetchGroupRequestsSuccessState(requests: _requests.values.toList()),
        );
      },
      //Error
      (_) {
        return emit(DeclineGroupRequestErrorState(userId: event.userId));
      },
    );
  }

  //----------------- REMOVE MEMBER BLOC --------------
  Future<void> _removeMember(
    RemoveMemberEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(RemoveMemberLoadingState());
 final String? token = await getToken();
    if (token == null) {
      return emit(RemoveMemberErrorState());
    }

    final Either<SuccessMessageModel?, ErrorMessageModel?> result =
        await _groupRepoImple.removeGroupMember(
          token: token,
          groupId: event.groupId,
          userId: event.userId,
        );

    result.fold(
      (success) async {
        emit(RemoveMemberSuccessState());
        groupMembers.remove(event.userId);
        currentGroupMembersCount = currentGroupMembersCount - 1;
        emit(
          FetchGroupMembersCountSuccessState(
            membersCount: currentGroupMembersCount,
          ),
        );
        emit(
          FetchGroupAddedUsersSuccessState(
            addedUsers: groupMembers.values.toList(),
          ),
        );
      },
      (error) {
        return emit(RemoveMemberErrorState());
      },
    );
  }

  //------------------ SEARCH MEMBERS TO ADD BLOC ---------------------
  Future<void> _searchMembersToAdd(
    SearchMembersToAddEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(FetchAddedUsersOnlyLoadingState());

    return emit(
      FetchAddedUsersOnlySuccessState(
        addedUsers:
            //Searching users
            _addedUsers.where((user) {
              return user.username.contains(event.searchText);
            }).toList(),
      ),
    );
  }

  //------------------ LEAVE FROM GROUP BLOC ----------
  Future<void> _leaveFromGroup(
    LeaveFromGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(LeaveLoadingState());
     final String? token = await getToken();
    if (token == null) {
      return emit(LeaveErrorState());
    }
    final Either<SuccessMessageModel, ErrorMessageModel> result =
        await _groupRepoImple.leaveGroup(
          groupId: event.groupId,
          token: token,
          currentMembersCount: event.currentGroupMembersCount,
          currentUserId: event.currentUserId,
        );

    result.fold(
      (success) {
        //Removing it from the map and notifying UI
        addedGroups.remove(event.groupId);
        emit(FetchGroupsSuccessState(groups: addedGroups.values.toList()));
        return emit(LeaveSuccessState());
      },
      (error) {
        return emit(LeaveErrorState());
      },
    );
  }

  //-------------------- FETCH MEDIA ITEMS BLOC --------------
  void _fetchMediaItems(FetchGroupMediaItems event, Emitter<GroupState> emit) {
    final List<GroupChatStorageModel> mediaItems = _storage.fetchMediaItems(
      groupId: event.groupId,
      limit: event.limit,
    );

    emit(GroupMediaItemsSuccessState(mediaItems: mediaItems));
  }

  //--------------------- LOAD MORE GROUP REQUESTS BLOC ----------------
  void _loadMoreGroupRequests(
    LoadMoreGroupRequestsEvent event,
    Emitter<GroupState> emit,
  ) async {
    if (!_fullFetchedGroupRequests) {
      emit(LoadMoreGroupRequestsLoadingState());
 final String? token = await getToken();
      if (token == null) {
        return emit(LoadMoreGroupRequestsErrorState());
      }

      final Either<List<GroupRequestUserModel>?, ErrorMessageModel?> result =
          await _groupRepoImple.fetchGroupRequests(
            token: token,
            groupId: event.groupId,
            limit: _limit,
            page: _currentPageForGroupRequests,
          );

      result.fold(
        (requests) {
          if (requests != null) {
            for (var requestedUser in requests) {
              _requests[requestedUser.userId] = requestedUser;
            }

            emit(LoadMoreGroupRequestsSuccessState());
            emit(
              FetchGroupRequestsSuccessState(
                requests: _requests.values.toList(),
              ),
            );
            if (requests.length < _limit) {
              _fullFetchedGroupRequests = true;
            } else {
              _currentPageForGroupRequests++;
            }
          }
        },
        (error) {
          return emit(LoadMoreGroupRequestsErrorState());
        },
      );
    }
  }

  //-------------------- LOAD MORE GROUP MEMBERS BLOC ----------------
  void _loadMoreGroupMembers(
    LoadMoreGroupMembersEvent event,
    Emitter<GroupState> emit,
  ) async {
    if (_fullyFetchedGroupMembers) {
      emit(LoadMoreGroupMembersLoadingState());
       final String? token = await getToken();
      if (token == null) {
        return emit(LoadMoreGroupMembersErrorState());
      }

      final Either<List<GroupAddedUserModel>?, ErrorMessageModel?> result =
          await _groupRepoImple.fetchGroupAddedUsers(
            token: token,
            groupId: event.groupId,
            limit: _limit,
            page: _currentPageForGroupMembers,
          );

      result.fold(
        (members) {
          if (members != null) {
            for (var member in members) {
              groupMembers[member.userId] = member;
            }
          }
        },
        (error) {
          emit(LoadMoreGroupMembersErrorState());
        },
      );
    }
  }

  //------------------- LOAD MORE USERS TO ADD MEMBER BLOC --------------
  void _loadMoreUsersToAddMember(
    LoadMoreUsersToAddMemberEvent event,
    Emitter<GroupState> emit,
  ) async {
    if (!_fullyFetchedUsers) {
      emit(LoadMoreUserToAddMemberLoadingState());
       final String? token = await getToken();
      if (token == null) {
        return emit(LoadMoreGroupMembersErrorState());
      }

      final Either<List<AddedUserOnlyModel>?, ErrorMessageModel?> result =
          await _groupRepoImple.fetchUsersToAddMember(
            token: token,
            limit: _limit,
            page: _currentPageForUsers,
            groupId: event.groupId,
          );

      result.fold(
        (users) {
          if (users != null) {
            _addedUsers.addAll(users);

            if (users.length < _limit) {
              _fullyFetchedUsers = true;
            } else {
              _currentPageForUsers++;
            }

            emit(LoadMoreUserToAddMemberSuccessState());
            emit(FetchAddedUsersOnlySuccessState(addedUsers: _addedUsers));
          }
        },
        (error) {
          return emit(LoadMoreUserToAddMemberErrorState());
        },
      );
    }
  }

  //------------------ LOAD MORE GROUPS BLOC ----------------
  void _loadMoreGroups(
    LoadMoreGroupsEvent event,
    Emitter<GroupState> emit,
  ) async {
    if (!_fullyFetchedGroups) {
      emit(LoadMoreGroupsLoadingState());
       final String? token = await getToken();
      if (token != null) {
        //Fetching more groups
        final Either<List<GroupModel>?, ErrorMessageModel?> result =
            await _groupRepoImple.fetchGroups(
              token: token,
              currentUserId: event.currentUserId,
              limit: _limit,
              page: _currentPageForGroups,
            );

        result.fold(
          (groups) {
            if (groups != null) {
              for (var group in groups) {
                if (!addedGroups.containsKey(group.groupId)) {
                  addedGroups[group.groupId] = group;
                }
              }
              if (groups.length < _limit) {
                _fullyFetchedGroups = true;

                emit(
                  FetchGroupsSuccessState(groups: addedGroups.values.toList()),
                );
              } else {
                _currentPageForGroups = _currentPageForGroups + 1;
              }
            }

            return emit(
              FetchGroupsSuccessState(groups: addedGroups.values.toList()),
            );
          },
          (error) {
            return emit(LoadMoreGroupsErrorState());
          },
        );
      } else {
        emit(LoadMoreGroupsErrorState());
      }
    }
  }

  //------------------- CHANGE LAST MESSAGE TIME BLOC -----------------
  void _changeLastMessageTime(
    ChangeLastGroupMessageTimeEvent event,
    Emitter<GroupState> emit,
  ) async {
    //Parsing the time
    final DateTime? lastTime = DateTime.tryParse(event.time);
 final String? token = await getToken();
    if (lastTime != null && token != null) {
      final Either<SuccessMessageModel, ErrorMessageModel> result =
          await _groupRepoImple.changeLastMessageTime(
            time: lastTime.toUtc().toIso8601String(),
            groupId: event.groupId,
            token: token,
          );

      result.fold(
        (success) {
          printDebug("Group last message changed successfully");
        },
        (error) {
          printDebug("Group last message error ");
        },
      );
    }
  }

  //-------------------- CHANGE GROUP POSITION BLOC ----------------
  void _changePosition(
    ChangeGroupPositionEvent event,
    Emitter<GroupState> emit,
  ) {
    final GroupModel? groupToChange = addedGroups.remove(event.groupId);

    if (groupToChange != null) {
      final GroupModel newGroup = GroupModel(
        groupId: groupToChange.groupId,
        groupName: groupToChange.groupName,
        groupImageUrl: groupToChange.groupImageUrl,
        groupBio: groupToChange.groupBio,
        lastMessage: event.textMessage,
        isSeenLastMessage: false,
        lastImageText: event.imageText,
        lastMessageType: event.messageType,
        lastMessageTime: event.time,
        unreadMessagesCount: 0,
        isMe: true,
        groupAdminUserId: groupToChange.groupAdminUserId,
        membersCount: groupToChange.membersCount,
        createdAt: groupToChange.createdAt,
      );
      //Adding the group as first which is removed
      addedGroups = {groupToChange.groupId: newGroup, ...addedGroups};

      emit(FetchGroupsSuccessState(groups: addedGroups.values.toList()));
    }
  }

  //------------------- CHANGE GROUP ORDER BLOC -------------
  void _changeGroupOrder(
    ChangeGroupOrderEvent event,
    Emitter<GroupState> emit,
  ) {
    printDebug("Entered in change order group");

    addedGroups.remove(event.groupId);

    //Adding the group to first position when new messages come from that group
    final GroupModel newGroup = GroupModel(
      groupId: event.groupId,
      groupName: event.groupName,
      groupImageUrl: event.groupImageUrl,
      groupBio: event.groupBio,
      lastMessage: event.lastMessage,
      isSeenLastMessage: false,
      lastImageText: event.lastImageText,
      lastMessageType: event.lastMessageType,
      lastMessageTime: event.lastMessageTime,
      unreadMessagesCount: event.unreadMessagesCount,
      isMe: false,
      groupAdminUserId: event.groupAdminUserId,
      membersCount: event.membersLength,
      createdAt: event.groupCreatedAt,
    );

    addedGroups = {newGroup.groupId: newGroup, ...addedGroups};

    emit(FetchGroupsSuccessState(groups: addedGroups.values.toList()));
  }
}
