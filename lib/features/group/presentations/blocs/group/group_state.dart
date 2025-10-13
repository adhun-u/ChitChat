part of 'group_bloc.dart';

sealed class GroupState {}

final class GroupInitial extends GroupState {}

//Create group success state
final class CreateGroupSuccessState extends GroupState {
  final String message;
  CreateGroupSuccessState({required this.message});
}

//Create group error stae
final class CreateGroupErrorState extends GroupState {
  final String message;
  CreateGroupErrorState({required this.message});
}

//Create group loading state
final class CreateGroupLoadingState extends GroupState {}

//Fetch groups loading state
final class FetchGroupsLoadingState extends GroupState {}

//Fetch groups success state
final class FetchGroupsSuccessState extends GroupState {
  final List<GroupModel> groups;

  FetchGroupsSuccessState({required this.groups});
}

//Fetch groups error state
final class FetchGroupsErrorState extends GroupState {
  final String message;

  FetchGroupsErrorState({required this.message});
}

//Search group loading state
final class SearchGroupLoadingState extends GroupState {}

//Search group success state
final class SearchGroupSuccessState extends GroupState {
  final List<SearchGroupModel> groups;
  SearchGroupSuccessState({required this.groups});
}

//Search group error state
final class SearchGroupErrorState extends GroupState {
  final String message;
  SearchGroupErrorState({required this.message});
}

//Send request loading state
final class SendRequestLoadingState extends GroupState {
  final String groupId;

  SendRequestLoadingState({required this.groupId});
}

//Send request success state
final class SendRequestSuccessState extends GroupState {
  final String groupId;

  SendRequestSuccessState({required this.groupId});
}

//Send request error state
final class SendRequestErrorState extends GroupState {
  final String message;
  SendRequestErrorState({required this.message});
}

//Fetch group added users loading state
final class FetchGroupAddedUsersLoadingState extends GroupState {}

//Fetch group added users success state
final class FetchGroupAddedUsersSuccessState extends GroupState {
  final List<GroupAddedUserModel> addedUsers;

  FetchGroupAddedUsersSuccessState({required this.addedUsers});
}

//Fetch group added users error state
final class FetchGroupAddedUsersErrorState extends GroupState {
  final String errorMessage;

  FetchGroupAddedUsersErrorState({required this.errorMessage});
}

//Fetch group requests loading state
final class FetchGroupRequestsLoadingState extends GroupState {}

//Fetch group requests success state
final class FetchGroupRequestsSuccessState extends GroupState {
  final List<GroupRequestUserModel> requests;

  FetchGroupRequestsSuccessState({required this.requests});
}

//Fetch group requests error state
final class FetchGroupRequestsErrorState extends GroupState {
  final String message;

  FetchGroupRequestsErrorState({required this.message});
}

//Edit group loading state
final class EditGroupLoadingState extends GroupState {}

//Edit group success state
final class EditGroupSuccessState extends GroupState {
  final String message;

  EditGroupSuccessState({required this.message});
}

//Edit group error state
final class EditGroupErrorState extends GroupState {
  final String message;

  EditGroupErrorState({required this.message});
}

//Fetch added users only loading state
final class FetchAddedUsersOnlyLoadingState extends GroupState {}

//Fetch added users only success state
final class FetchAddedUsersOnlySuccessState extends GroupState {
  final List<AddedUserOnlyModel> addedUsers;

  FetchAddedUsersOnlySuccessState({required this.addedUsers});
}

//Fetch added users only error state
final class FetchAddedUsersOnlyErrorState extends GroupState {
  final String message;

  FetchAddedUsersOnlyErrorState({required this.message});
}

//Add member loading state
final class AddMemberLoadingState extends GroupState {
  final int userId;

  AddMemberLoadingState({required this.userId});
}

//Add member success state
final class AddMemberSuccessState extends GroupState {
  final String message;
  final int userId;

  AddMemberSuccessState({required this.message, required this.userId});
}

//Add member error state
final class AddMemberErrorState extends GroupState {
  final String message;
  final int userId;
  AddMemberErrorState({required this.message, required this.userId});
}

//Accept group request loading state
final class AcceptGroupRequestLoadingState extends GroupState {
  final String groupId;
  final int userId;
  AcceptGroupRequestLoadingState({required this.groupId, required this.userId});
}

//Accept group request success state
final class AcceptGroupRequestSuccessState extends GroupState {
  final String groupId;
  final int userId;
  AcceptGroupRequestSuccessState({required this.groupId, required this.userId});
}

//Accept group request error state
final class AcceptGroupRequestErrorState extends GroupState {
  final String message;
  final int userId;
  AcceptGroupRequestErrorState({required this.message, required this.userId});
}

//Decline group request loading state
final class DeclineGroupRequestLoadingState extends GroupState {
  final int userId;

  DeclineGroupRequestLoadingState({required this.userId});
}

//Decline group request success state
final class DeclineGroupRequestSuccessState extends GroupState {
  final String message;
  final int userId;
  DeclineGroupRequestSuccessState({
    required this.message,
    required this.userId,
  });
}

//Decline group request error state
final class DeclineGroupRequestErrorState extends GroupState {
  final int userId;

  DeclineGroupRequestErrorState({required this.userId});
}

//Remove member loading state
final class RemoveMemberLoadingState extends GroupState {}

//Remove member success state
final class RemoveMemberSuccessState extends GroupState {}

//Remove member error state
final class RemoveMemberErrorState extends GroupState {}

//Fetch group members count success state
final class FetchGroupMembersCountSuccessState extends GroupState {
  final int membersCount;
  FetchGroupMembersCountSuccessState({required this.membersCount});
}

//Leave loading state
final class LeaveLoadingState extends GroupState {}

//Leave success state
final class LeaveSuccessState extends GroupState {}

//Leave error state
final class LeaveErrorState extends GroupState {}

//Group media items
final class GroupMediaItemsSuccessState extends GroupState {
  final List<GroupChatStorageModel> mediaItems;

  GroupMediaItemsSuccessState({required this.mediaItems});
}

//Load more loading state
final class LoadMoreGroupSearchResultLoadingState extends GroupState {}

//Load more success state
final class LoadMoreGroupSearchResultSuccessState extends GroupState {}

//Load more error state
final class LoadMoreGroupSearchResultErrorState extends GroupState {}

//Load more group requests loading state
final class LoadMoreGroupRequestsLoadingState extends GroupState {}

//Load more group requests success state
final class LoadMoreGroupRequestsSuccessState extends GroupState {}

//Load more group requests error state
final class LoadMoreGroupRequestsErrorState extends GroupState {}

//Load more group members loading state
final class LoadMoreGroupMembersLoadingState extends GroupState {}

//Load more group members success state
final class LoadMoreGroupMembersSuccessState extends GroupState {}

//Load more group members error state
final class LoadMoreGroupMembersErrorState extends GroupState {}

//Load more users to add member loading state
final class LoadMoreUserToAddMemberLoadingState extends GroupState {}

//Load more users to add member success state
final class LoadMoreUserToAddMemberSuccessState extends GroupState {}

//Load more users to add member error state
final class LoadMoreUserToAddMemberErrorState extends GroupState {}

//Load more groups loading state
final class LoadMoreGroupsLoadingState extends GroupState {}

//Load more groups success state
final class LoadMoreGroupsSuccessState extends GroupState {}

//Load more groups error state
final class LoadMoreGroupsErrorState extends GroupState {}
