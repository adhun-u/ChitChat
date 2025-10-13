part of 'group_bloc.dart';

sealed class GroupEvent {}

//For clearing all list related to this grop
final class ClearGroupListEvent extends GroupEvent {}

//For creating group
final class CreateGroupEvent extends GroupEvent {
  final String groupName;
  final String groupBio;
  final String groupImagePath;
  final int currentUserId;

  CreateGroupEvent({
    required this.groupName,
    required this.groupBio,
    required this.currentUserId,
    required this.groupImagePath,
  });
}

//For fetching all groups
final class FetchGroupsEvent extends GroupEvent {
  final int currentUserId;

  FetchGroupsEvent({required this.currentUserId});
}

//For searching groups
final class SearchGroupsEvent extends GroupEvent {
  final String groupName;

  SearchGroupsEvent({required this.groupName});
}

//For loading more search results
final class LoadMoreGroupSearchResutlEvent extends GroupEvent {}

//For sending a request to the group
final class SendRequestEvent extends GroupEvent {
  final String groupName;
  final String groupId;
  final int groupAdminId;

  SendRequestEvent({
    required this.groupName,
    required this.groupId,
    required this.groupAdminId,
  });
}

//For fetching added users of a group
final class FetchGroupAddedUsersEvent extends GroupEvent {
  final String groupId;
  final int currentUseId;
  final bool shouldCallApi;
  FetchGroupAddedUsersEvent({
    required this.groupId,
    required this.currentUseId,
    required this.shouldCallApi,
  });
}

//For fetching requested users of group
final class FetchGroupRequestsEvent extends GroupEvent {
  final String groupId;
  final bool shouldCallApi;
  FetchGroupRequestsEvent({required this.groupId, required this.shouldCallApi});
}

//For editing group info
final class EditGroupInfoEvent extends GroupEvent {
  final String groupId;
  final String newGroupName;
  final String newGroupImagePath;
  final String newGroupBio;

  EditGroupInfoEvent({
    required this.groupId,
    required this.newGroupName,
    required this.newGroupImagePath,
    required this.newGroupBio,
  });
}

//For fetching added users only
final class FetchUsersToAddMemberEvent extends GroupEvent {
  final String groupId;

  FetchUsersToAddMemberEvent({required this.groupId});
}

//For adding a member to group
final class AddMemberToGroupEvent extends GroupEvent {
  final String groupId;
  final int userId;
  final String username;
  final String userBio;
  final String profilePic;

  AddMemberToGroupEvent({
    required this.groupId,
    required this.userId,
    required this.username,
    required this.userBio,
    required this.profilePic,
  });
}

//For accept a group request
final class AcceptGroupRequestEvent extends GroupEvent {
  final String groupId;
  final int userId;
  final String groupName;
  final String groupImage;
  AcceptGroupRequestEvent({
    required this.groupId,
    required this.userId,
    required this.groupName,
    required this.groupImage,
  });
}

//For declining a group request
final class DeclineGroupRequestEvent extends GroupEvent {
  final String groupId;
  final int userId;

  DeclineGroupRequestEvent({required this.groupId, required this.userId});
}

//For removing a member from group
final class RemoveMemberEvent extends GroupEvent {
  final String groupId;
  final int userId;

  RemoveMemberEvent({required this.groupId, required this.userId});
}

//For adding current group members count
final class AddGroupMembersCountEvent extends GroupEvent {
  final int membersCount;

  AddGroupMembersCountEvent({required this.membersCount});
}

//For searching a users while adding
final class SearchMembersToAddEvent extends GroupEvent {
  final String searchText;
  SearchMembersToAddEvent({required this.searchText});
}

//For leaving from a group
final class LeaveFromGroupEvent extends GroupEvent {
  final String groupId;
  final int currentGroupMembersCount;
  final int currentUserId;
  LeaveFromGroupEvent({
    required this.groupId,
    required this.currentGroupMembersCount,
    required this.currentUserId,
  });
}

//For fetching group media items
final class FetchGroupMediaItems extends GroupEvent {
  final String groupId;
  final int? limit;
  FetchGroupMediaItems({required this.groupId, this.limit});
}

//For loading more requested users of specific group
final class LoadMoreGroupRequestsEvent extends GroupEvent {
  final String groupId;

  LoadMoreGroupRequestsEvent({required this.groupId});
}

//For loading more group members of specific group
final class LoadMoreGroupMembersEvent extends GroupEvent {
  final String groupId;

  LoadMoreGroupMembersEvent({required this.groupId});
}

//For loading more users to add as member event
final class LoadMoreUsersToAddMemberEvent extends GroupEvent {
  final String groupId;

  LoadMoreUsersToAddMemberEvent({required this.groupId});
}

//For loading more groups event
final class LoadMoreGroupsEvent extends GroupEvent {
  final int currentUserId;

  LoadMoreGroupsEvent({required this.currentUserId});
}

//For changing last message time of specific group
final class ChangeLastGroupMessageTimeEvent extends GroupEvent {
  final String time;
  final String groupId;

  ChangeLastGroupMessageTimeEvent({required this.time, required this.groupId});
}

//For changing the position when current sends any message
final class ChangeGroupPositionEvent extends GroupEvent {
  final String groupId;
  final String messageType;
  final String imageText;
  final String textMessage;
  final String time;
  ChangeGroupPositionEvent({
    required this.groupId,
    required this.textMessage,
    required this.imageText,
    required this.messageType,
    required this.time,
  });
}

//For changing the position when someone sends any message
final class ChangeGroupOrderEvent extends GroupEvent {
  final String lastMessage;
  final String groupName;
  final String groupBio;
  final String groupId;
  final int groupAdminUserId;
  final String groupImageUrl;
  final String groupCreatedAt;
  final int membersLength;
  final String lastMessageType;
  final String lastImageText;
  final int unreadMessagesCount;
  final String lastMessageTime;

  ChangeGroupOrderEvent({
    required this.lastMessage,
    required this.groupName,
    required this.groupBio,
    required this.groupId,
    required this.groupAdminUserId,
    required this.groupImageUrl,
    required this.groupCreatedAt,
    required this.membersLength,
    required this.lastMessageType,
    required this.lastImageText,
    required this.unreadMessagesCount,
    required this.lastMessageTime,
  });
}
