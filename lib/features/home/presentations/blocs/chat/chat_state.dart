part of 'chat_bloc.dart';

sealed class ChatState {}

final class ChatInitial extends ChatState {}

//Send text message success state
final class SendTextMessageSuccessState extends ChatState {}

//Send text message error state
final class SendTextMessageErrorState extends ChatState {
  final String errorMessage;
  SendTextMessageErrorState({required this.errorMessage});
}

//Null state
final class NullState extends ChatState {}

//Socket messages state
final class SocketMessagesState extends ChatState with EquatableMixin {
  final ChatModel chat;
  SocketMessagesState({required this.chat});
  @override
  List<Object?> get props => [chat.time];
}

//Retrieve chat success state
final class RetrieveChatSuccessState extends ChatState with EquatableMixin {
  final List<ChatStorageDBModel> chats;

  RetrieveChatSuccessState({required this.chats});

  @override
  List<Object?> get props => [chats];
}

//Retrieve chat loading state
final class RetrieveChatLoadingState extends ChatState {}

//Retrieve chat error state
final class RetrieveChatErrorState extends ChatState {
  final String errorMessage;

  RetrieveChatErrorState({required this.errorMessage});
}

//Send message error
final class SendMessageErrorState extends ChatState {
  final String errorMessage;

  SendMessageErrorState({required this.errorMessage});
}

//Fetch temporary message success state
final class FetchTemporaryMessagesSuccessState extends ChatState {}

//Fetch temporary messages loading state
final class FetchTemporaryMessagesLoadingState extends ChatState {}

//Fetch temporary message error state
final class FetchTemporaryMessagesErrorState extends ChatState {
  final String errorMessage;
  FetchTemporaryMessagesErrorState({required this.errorMessage});
}

//Typing indicator
final class TypeIndicatorState extends ChatState {}

//Not typing indicatior
final class NotTypingIndicatorState extends ChatState {}

//Online indication state
final class OnlineIndicationState extends ChatState {
  final bool isOnline;

  OnlineIndicationState({required this.isOnline});
}

//Seen indication state
final class IndicateSeenState extends ChatState {
  final int userId;

  IndicateSeenState({required this.userId});
}

//Recording state
final class RecordingIndicateState extends ChatState {}

//Not recording state
final class NotRecordingState extends ChatState {}

//To get unread message count
final class UnreadMessageCountState extends ChatState {
  final int unreadMessagesCount;
  final int senderId;
  UnreadMessageCountState({
    required this.unreadMessagesCount,
    required this.senderId,
  });
}

//Fetch seen info success state
final class FetchSeenInfoSuccessState extends ChatState {}

//Fetch seen info loading state
final class FetchSeenInfoLoadingState extends ChatState {}

//Fetch seen info error state
final class FetchSeenInfoErrorState extends ChatState {
  final String errorMessage;
  FetchSeenInfoErrorState({required this.errorMessage});
}

//Save seen info loading state
final class SaveSeenInfoLoadinState extends ChatState {}

//Save seen info success state
final class SaveSeenInfoSuccessState extends ChatState {}

//Save seen info error state
final class SaveSeenInfoErrorState extends ChatState {
  final String errorMessage;

  SaveSeenInfoErrorState({required this.errorMessage});
}

//Upload image success state
final class UploadImageSuccessState extends ChatState {
  final String imageUrl;
  final String imageText;
  final String publicId;
  final String type;
  UploadImageSuccessState({
    required this.imageUrl,
    required this.imageText,
    required this.publicId,
    required this.type,
  });
}

//Upload image loading error state
final class UploadImageLoadingState extends ChatState {
  final String chatId;
  UploadImageLoadingState({required this.chatId});
}

//Upload file error state
final class UploadFileError extends ChatState {
  final String errorMessage;

  UploadFileError({required this.errorMessage});
}

//Save file success state
final class SaveFileSuccessState extends ChatState {
  final int senderId;
  final String fileUrl;
  final String fileType;
  final String time;
  final String imageText;
  final String chatId;
  final String publicId;
  SaveFileSuccessState({
    required this.senderId,
    required this.fileUrl,
    required this.fileType,
    required this.imageText,
    required this.time,
    required this.chatId,
    required this.publicId,
  });
}

//Save file loading state
final class SaveFileLoadingState extends ChatState {
  final String chatId;

  SaveFileLoadingState({required this.chatId});
}

//Save file error state
final class SaveFileErrorState extends ChatState {
  final String errorMessage;

  SaveFileErrorState({required this.errorMessage});
}

//Upload audio loading state
final class UploadAudioLoadingState extends ChatState {
  final String chatId;
  UploadAudioLoadingState({required this.chatId});
}

//Upload audio success state
final class UploadAudioSuccessState extends ChatState {
  final String audioUrl;
  final String publicId;
  UploadAudioSuccessState({required this.audioUrl, required this.publicId});
}

//Uploading voice loading state
final class UploadVoiceLoadingState extends ChatState {
  final String chatId;

  UploadVoiceLoadingState({required this.chatId});
}

//Uploading voice success state
final class UploadVoiceSuccessState extends ChatState {
  final String voiceUrl;
  final String publicId;

  UploadVoiceSuccessState({required this.voiceUrl, required this.publicId});
}

//Messages count state
final class MessageCountState extends ChatState {
  final int totalMessageCount;
  final int totalImagesCount;
  final int totalAudiosCount;

  MessageCountState({
    required this.totalMessageCount,
    required this.totalImagesCount,
    required this.totalAudiosCount,
  });
}

//Fetch media success state
final class FetchMediaSuccessState extends ChatState {
  final List<ChatStorageDBModel> media;

  FetchMediaSuccessState({required this.media});
}

//Fetch media loading state
final class FetchMediaLoadingState extends ChatState {}

//Fetch media error state
final class FetchMediaErrorState extends ChatState {}

//Selected chat state
final class SelectChatState extends ChatState {
  final Map<String, SelectedChatModel> selectedChats;

  SelectChatState({required this.selectedChats});
}

//Delete for everyone loading state
final class DeleteForEveryoneLoadingState extends ChatState {}

//Delete for everyone success state
final class DeleteForEveryoneSuccessState extends ChatState {}

//Delete for everyone error state
final class DeleteForEveryoneErrorState extends ChatState {}
