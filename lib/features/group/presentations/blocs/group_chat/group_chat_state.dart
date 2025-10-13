part of 'group_chat_bloc.dart';

sealed class GroupChatState {
  const GroupChatState();
}

final class GroupChatInitial extends GroupChatState {}

//Fetch group chat success state
final class FetchGroupChatSuccessState extends GroupChatState {
  final Map<String, GroupChatStorageModel> chats;

  FetchGroupChatSuccessState({required this.chats});
}

//Fetch group chat error state
final class FetchGroupChatErrorState extends GroupChatState {
  final String message;

  FetchGroupChatErrorState({required this.message});
}

//Fetch group chat loading state
final class FetchGroupChatLoadingState extends GroupChatState {}

//Message indicator for indicating when a new message comes
final class MessageIndicator extends GroupChatState {
  final int senderId;
  final String chatId;
  MessageIndicator({required this.senderId, required this.chatId});
}

//Message seen indicator
final class MessageSeenIndicatorState extends GroupChatState {
  final String groupId;

  MessageSeenIndicatorState({required this.groupId});
}

//Text message sending error
final class GroupTextMessageSendingErrorState extends GroupChatState {}

//Fetch seen info loading state
final class FetchSeenInfoLoadingState extends GroupChatState {}

//Fetch seen info success state
final class FetchSeenInfoSuccessState extends GroupChatState {}

//Connect firebase loading state
final class ConnectFirebaseLoadingState extends GroupChatState {}

//Connect firebase success state
final class ConnectFirebaseSuccessState extends GroupChatState {}

//Connect firebase error state
final class ConnectFirebaseErrorState extends GroupChatState {}

//Clear all group chats loading state
final class ClearAllGroupChatLoadingState extends GroupChatState {}

//Clear all group chats success state
final class ClearAllGroupChatSuccessState extends GroupChatState {}

//Clear all group chats error state
final class ClearAllGroupChatErrorState extends GroupChatState {}

//Unread message count
final class UnreadGroupMessagesCountState extends GroupChatState {
  final int unreadMessagesCount;
  final String groupId;

  UnreadGroupMessagesCountState({
    required this.unreadMessagesCount,
    required this.groupId,
  });
}

//Last added message state
final class LastAddedMessageState extends GroupChatState {
  final String groupId;

  LastAddedMessageState({required this.groupId});
}

//Typing indicator
final class GroupChatTypingIndicator extends GroupChatState {
  final String indication;

  GroupChatTypingIndicator({required this.indication});
}

//Not typing indicator
final class GroupChatNotTypingIndicator extends GroupChatState {}

//Recording indicator
final class GroupChatRecordingIndicator extends GroupChatState {
  final String indication;

  GroupChatRecordingIndicator({required this.indication});
}

//No recording indicator
final class GroupChatNotRecordingIndicator extends GroupChatState {}

//Upload file error state
final class UploadGroupFileErrorState extends GroupChatState {}

//Upload image success state
final class UploadGroupChatImageSuccessState extends GroupChatState {
  final String imageUrl;
  final String imageText;
  final String chatId;

  UploadGroupChatImageSuccessState({
    required this.imageUrl,
    required this.imageText,
    required this.chatId,
  });
}

//Upload image error state
final class UploadGroupChatImageErrorState extends GroupChatState {
  final String chatId;

  UploadGroupChatImageErrorState({required this.chatId});
}

//Upload image loading state
final class UploadGroupChatImageLoadingState extends GroupChatState {
  final String chatId;
  UploadGroupChatImageLoadingState({required this.chatId});
}

//Upload audio success state
final class UploadGroupAudioSuccessState extends GroupChatState {
  final String audioUrl;
  final String chatId;
  UploadGroupAudioSuccessState({required this.audioUrl, required this.chatId});
}

//Upload audio error state
final class UploadGroupAudioErrorState extends GroupChatState {
  final String chatId;

  UploadGroupAudioErrorState({required this.chatId});
}

//Upload audio loading state
final class UploadGroupAudioLoadingState extends GroupChatState {
  final String chatId;
  UploadGroupAudioLoadingState({required this.chatId});
}

//Upload voice loading state
final class UploadGroupVoiceLoadingState extends GroupChatState {
  final String chatId;

  UploadGroupVoiceLoadingState({required this.chatId});
}

//Upload voice success state
final class UploadGroupVoiceSuccessState extends GroupChatState {
  final String voiceUrl;
  final String chatId;

  UploadGroupVoiceSuccessState({required this.voiceUrl, required this.chatId});
}

//Upload voice error state
final class UploadGroupVoiceErrorState extends GroupChatState {
  final String chatId;

  UploadGroupVoiceErrorState({required this.chatId});
}

//Save group chat file success state
final class SaveGroupChatFileSuccessState extends GroupChatState {
  final String chatId;

  SaveGroupChatFileSuccessState({required this.chatId});
}

//Save group chat file error state
final class SaveGroupChatFileErrorState extends GroupChatState {
  final String chatId;

  SaveGroupChatFileErrorState({required this.chatId});
}

//Group call indication
final class GroupCallIndication extends GroupChatState {
  final bool isInCall;

  GroupCallIndication({required this.isInCall});
}

//Selected group chats state
final class SelectedGroupChatsState extends GroupChatState {
  final Map<String, SelectedGroupChatModel> selectedChats;

  SelectedGroupChatsState({required this.selectedChats});
}

//Delete group chat from everyone loading state
final class DeleteGroupChatFromEveryOneLoadingState extends GroupChatState {}

//Deleting group chat from everyone error state
final class DeleteGroupChatFromEveryOneErrorState extends GroupChatState {}

//Deleting group chat from everyone success state
final class DeleteGroupChatFromEveryOneSuccessState extends GroupChatState {}

//Text message success state
final class GroupTextMessageSuccessState extends GroupChatState {
  final String groupId;
  final String text;
  final String lastTime;
  GroupTextMessageSuccessState({
    required this.groupId,
    required this.text,
    required this.lastTime,
  });
}

//New message state
final class NewGroupMessageState extends GroupChatState {
  final GroupChatStorageModel newChat;

  NewGroupMessageState({required this.newChat});
}

//Group details with message state
final class GroupDetailsWithMessageState extends GroupChatState {
  final String groupName;
  final String groupImageUrl;
  final String groupBio;
  final int groupAdminUserId;
  final String groupId;
  final String groupCreatedDate;
  final int membersLength;
  final String lastTextMessage;
  final String imageText;
  final String lastMessageType;
  final String lastMessageTime;
  final int unreadMessageCount;

  GroupDetailsWithMessageState({
    required this.groupName,
    required this.groupImageUrl,
    required this.groupBio,
    required this.groupId,
    required this.groupAdminUserId,
    required this.groupCreatedDate,
    required this.membersLength,
    required this.lastTextMessage,
    required this.imageText,
    required this.lastMessageType,
    required this.lastMessageTime,
    required this.unreadMessageCount,
  });
}
