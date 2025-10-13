import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/data/repo_imple/file_manager_repo_imple.dart';
import 'package:chitchat/common/data/repo_imple/websocket_repo_imple.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/features/home/data/datasource/chat_storage.dart';
import 'package:chitchat/features/home/data/models/chat_model.dart';
import 'package:chitchat/features/home/data/models/unread_message_model.dart';
import 'package:chitchat/features/home/data/repo_imple/chat_repo_imple.dart';
import 'package:chitchat/features/home/data/repo_imple/user_repo_imple.dart';
import 'package:chitchat/features/home/domain/entities/chat/chat_entity.dart';
import 'package:chitchat/features/home/domain/entities/chat_storage/chat_storage_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  //Creating an instance of WebsocketRepoImple for accessing , sending and receving message via websockets
  final WebsocketRepoImple _websocketRepoImple = WebsocketRepoImple();
  //Creating an instance of ChatRepoImple for calling chat related apis
  final ChatRepoImple _chatRepoImple = ChatRepoImple();
  //Creating an instance of FileManagerRepoImple for calling file related apis
  final FileManagerRepoImple _fileManagerRepoImple = FileManagerRepoImple();
  //Creating an instance of ChatStorageDB for getting the access of local storage and local chats
  final ChatStorageDB _chatStorage = ChatStorageDB();
  //Creating an instance UserRepoImple for getting user's related functions
  final UserRepoImple _userRepoImple = UserRepoImple();

  final Map<String, ChatStorageDBModel> _chats = {};
  final Map<String, LastMessageModel> lastMessage = {};
  final Map<String, SelectedChatModel> selectedChats = {};
  final Map<String, UnreadMessageModel> unreadMessagesCounts = {};

  bool isReceiverInOnline = false;

  ChatBloc() : super(ChatInitial()) {
    //Connect socket event
    on<ConnectSocketEvent>(connectSocket);
    //Send message event
    on<SendMessageEvent>(sendMessage);
    //Disconnect socket event
    on<DisconnectSocketEvent>((event, emit) {
      _websocketRepoImple.getSink().close();
    });
    //Retrieving all chats
    on<RetrieveChatEvent>(retrieveChat);
    //Getting all messages when incoming message event is triggered
    on<IncomingMessageEvent>(getSocketMessage);
    //Fetch all temporary messages
    on<FetchTempMessagesEvent>(getTempMessages);
    //Getting indicatior when user typing
    on<IncomingIndicatorEvent>(getIndicator);
    //Indicate typing
    on<IndicateEvent>(sendIndicator);
    //To enter in chat connection
    on<EnterChatConnectionEvent>(enterChatConnection);
    //To exit from chat connection
    on<ExitFromChatConnectionEvent>(exitConnection);
    //To indicate online
    on<OnlineIndicationEvent>(getOnlineStatus);
    //Seen indication
    on<IndicateSeenEvent>(getSeenIndicator);
    //To remove unread message count
    on<RemoveUnreadMessagesCount>(removeUnreadMessageCount);
    //To fetch seen info
    on<FetchSeenInfoEvent>(fetchSeenInfo);
    //To save seen info
    on<SaveSeenInfoEvent>(saveSeenInfo);
    //To file as message
    on<UploadFileEvent>(uploadFile);
    //To save image
    on<SaveFileEvent>(saveFile);
    //To get unread message count
    on<GetUnreadMessageCountEvent>((event, emit) {
      final int anotherUserId =
          event.senderId != event.currentUserId
              ? event.senderId
              : event.receiverId;
      //Getting current unread messages details
      UnreadMessageModel? unreadMessageDetails =
          unreadMessagesCounts["${event.currentUserId}$anotherUserId"];
      int currentUnreadMessageCount = 1;
      //Parsing the date and time to get utf and iso string date time
      final DateTime messageTime = DateTime.parse(event.time);
      //If the user does not exist , then creating one otherwise updating it
      if (unreadMessageDetails == null) {
        unreadMessagesCounts["${event.currentUserId}$anotherUserId"] =
            UnreadMessageModel(
              senderId: event.senderId,
              time: messageTime.toUtc().toString(),
              unreadMessagesCount: 1,
            );
      } else {
        unreadMessagesCounts.update("${event.currentUserId}$anotherUserId", (
          unreadMessageDetails,
        ) {
          int unreadMessageCount = unreadMessageDetails.unreadMessagesCount;
          unreadMessageCount = unreadMessageCount + 1;
          currentUnreadMessageCount = unreadMessageCount;

          return UnreadMessageModel(
            senderId: unreadMessageDetails.senderId,
            time: unreadMessageDetails.time,
            unreadMessagesCount: currentUnreadMessageCount,
          );
        });
      }
      emit(
        UnreadMessageCountState(
          unreadMessagesCount: currentUnreadMessageCount,
          senderId: event.senderId,
        ),
      );
    });
    //To fetch messages count
    on<FetchMessageCountEvent>(_fetchMessageCount);
    //To fetch media from local storage
    on<FetchMediaEvent>(_fetchMedia);
    //To clear all chats with current user with the user whom want to clear
    on<ClearAllChatsEvent>((event, emit) {
      emit(RetrieveChatSuccessState(chats: []));
      _chats.clear();
      _chatStorage.deleteAllChat(
        currentUserId: event.currentUserId,
        oppositeUserId: event.oppositeUserId,
      );
    });
    //To select chats
    on<SelectChatEvent>((event, emit) {
      //If the chat is already selected , then removing it from the map
      if (!selectedChats.containsKey(event.chatId)) {
        selectedChats[event.chatId] = SelectedChatModel(
          isSeen: event.isSeen,
          senderId: event.senderId,
        );
        emit(SelectChatState(selectedChats: selectedChats));
      } else {
        selectedChats.remove(event.chatId);
        emit(SelectChatState(selectedChats: selectedChats));
      }
    });
    //To change seen info in selected chats
    on<ChangeSeenInfoInSelectedChatsEvent>((event, emit) {
      selectedChats.updateAll((key, selectedChat) {
        return SelectedChatModel(isSeen: true, senderId: selectedChat.senderId);
      });
    });
    //To deselect chat
    on<DeSelectChatEvent>((event, emit) {
      selectedChats.clear();
      emit(SelectChatState(selectedChats: {}));
    });
    //To delete the selected chats from local
    on<DeleteForMeEvent>((event, emit) {
      selectedChats.forEach((key, value) {
        _chats.remove(key);
      });
      emit(RetrieveChatSuccessState(chats: _chats.values.toList()));
      //Deleting the selected chats from local storage
      _chatStorage.deleteSelectedChats(selectedChats.keys.toList());
      selectedChats.clear();
      emit(SelectChatState(selectedChats: selectedChats));
    });
    //To delete the selected chat from database
    on<DeleteForEveryone>(_deleteChatForEveryOne);
    //To cancel uploading process
    on<CancelUploadingProcess>((event, emit) {
      //Removing the uploading status from chats
      _fileManagerRepoImple.cancel();
      _chats.remove(event.chatId);
      emit(RetrieveChatSuccessState(chats: _chats.values.toList()));
    });
    //To send call history info
    on<SendCallHistoryInfo>(_sendCallHistory);
  }

  //------------- CONNECT WEBSOCKET BLOC -------------
  Future<void> connectSocket(
    ConnectSocketEvent event,
    Emitter<ChatState> emit,
  ) async {
    //Connecting the web socket
    await _websocketRepoImple.connectSocket(
      currentUserId: event.currentUserId,
      username: event.username,
      profilePic: event.profilepic,
    );

    _websocketRepoImple.getMessage().listen((chat) {
      try {
        //Getting the messages
        final Map<String, dynamic> message =
            jsonDecode(chat) as Map<String, dynamic>;

        //Getting if the sender is typing
        if (message['indication'] == "Typing" ||
            message['indication'] == "Not typing" ||
            message['indication'] == "Recording" ||
            message['indication'] == "Not recording") {
          add(
            IncomingIndicatorEvent(
              indication: message['indication'],
              receiverId: message['receiverId'],
            ),
          );
        } else if (message['type'] == "seen") {
          add(
            IndicateSeenEvent(
              receiverId: message['receiverId'],
              senderId: message['senderId'],
            ),
          );
        }
        //Checking if the chat type is "status"
        else if (message['type'] == "status") {
          isReceiverInOnline = message['isOnline'];
          add(OnlineIndicationEvent(isOnline: message['isOnline']));
        } else {
          final ChatEntity chatEntity = ChatEntity.fromJson(message);

          final int anotherUserId =
              chatEntity.senderId != event.currentUserId
                  ? chatEntity.senderId
                  : chatEntity.receiverId;

          if (message['isRead'] == false) {
            if (chatEntity.type != "audioCall" &&
                chatEntity.type != "videoCall") {
              final DateTime parsedTime = DateTime.parse(chatEntity.time);
              lastMessage["${event.currentUserId}$anotherUserId"] =
                  LastMessageModel(
                    textMessage: chatEntity.textMessage ?? "",
                    messageType: chatEntity.type,
                    time: parsedTime.toUtc().toIso8601String(),
                    audioDuration: chatEntity.audioDuration ?? "",
                    imageText: chatEntity.imageText ?? "",
                    voiceDuration: chatEntity.voiceDuration ?? "",
                  );
              add(
                GetUnreadMessageCountEvent(
                  senderId: message['senderId'],
                  time: message['time'],
                  currentUserId: event.currentUserId,
                  receiverId: message['receiverId'],
                ),
              );
            }
          }
          add(
            IncomingMessageEvent(
              chat: ChatModel(
                senderName: chatEntity.senderName ?? "",
                senderProfilePic: chatEntity.senderProfilePic ?? "",
                chatId: chatEntity.chatId,
                senderId: chatEntity.senderId,
                receiverId: chatEntity.receiverId,
                type: chatEntity.type,
                textMessage: chatEntity.textMessage,
                time: chatEntity.time,
                imageText: chatEntity.imageText,
                imageUrl: chatEntity.imageUrl,
                voiceUrl: chatEntity.voiceUrl,
                voiceDuration: chatEntity.voiceDuration,
                audioUrl: chatEntity.audioUrl ?? "",
                audioDuration: chatEntity.audioDuration ?? "",
                audioTitle: chatEntity.audioTitle ?? "",
                videoTitle: chatEntity.videoTitle ?? "",
                videoUrl: chatEntity.videoUrl ?? "",
                videoDuration: chatEntity.videoDuration ?? "",
                isSeen: chatEntity.isSeen,
                isRead: chatEntity.isRead,
                parentAudioDuration: chatEntity.parentAudioDuration ?? "",
                parentMessageSenderId: chatEntity.parentMessageSenderId ?? 0,
                parentMessageType: chatEntity.parentMessageType ?? "",
                parentText: chatEntity.parentText ?? "",
                parentVoiceDuration: chatEntity.parentVoiceDuration ?? "",
                repliedMessage: chatEntity.repliedMessage,
                senderBio: chatEntity.senderBio ?? "",
              ),
            ),
          );
        }
      } catch (e, st) {
        printDebug('Stack trace : $st');
        printDebug('Socket message error : $e');
      }
    });
  }

  //--------------- ENTER CHAT CONNECTION BLOC --------------
  void enterChatConnection(
    EnterChatConnectionEvent event,
    Emitter<ChatState> emit,
  ) {
    _websocketRepoImple.enterChatConnection(
      isInChatConnection: true,
      receiverId: event.receiverId,
    );
  }

  //------------- SEND MESSAGE BLOC ---------------------
  void sendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    final String? token = await getToken();
    try {
      final DateTime time = DateTime.now();
      final String chatId = Uuid().v8();
      _websocketRepoImple.sendMessage(
        ChatModel(
          chatId: chatId,
          senderName: event.senderName,
          senderProfilePic: event.senderProfilePic,
          senderId: event.senderId,
          senderBio: event.senderBio,
          receiverId: event.receiverId,
          type: event.type,
          textMessage: event.message,
          time: time.toString(),
          imageText: "",
          imageUrl: event.imageUrl,
          voiceUrl: "",
          voiceDuration: "",
          audioUrl: "",
          audioDuration: "",
          videoUrl: "",
          videoDuration: "",
          audioTitle: "",
          videoTitle: "",
          isSeen: false,
          isRead: true,
          parentAudioDuration: "",
          parentMessageSenderId: event.parentMessageSenderId,
          parentMessageType: event.parentMessageType,
          parentText: event.parentText,
          parentVoiceDuration: "",
          repliedMessage: event.repliedMessage,
        ),
      );

      lastMessage["${event.senderId}${event.receiverId}"] = LastMessageModel(
        textMessage: event.message ?? "",
        messageType: "text",
        time: time.toUtc().toIso8601String(),
        audioDuration: "",
        imageText: "",
        voiceDuration: "",
      );

      if (token != null) {
        await _userRepoImple.changeLastMessageTime(
          oppositeUserId: event.receiverId,
          token: token,
        );
      }
    } catch (e) {
      emit(SendMessageErrorState(errorMessage: 'Something went wrong'));
    }
  }

  //------------------ RETRIEVE CHAT BLOC ----------------------------
  Future<void> retrieveChat(
    RetrieveChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(RetrieveChatLoadingState());
    try {
      _chats.clear();
      //Retrieving all chats of current user with the particular receiver
      final List<ChatStorageDBModel> savedChats = await _chatStorage
          .getSavedChats(
            senderId: event.senderId,
            receiverId: event.receiverId,
          );
      for (var savedChat in savedChats) {
        _chats[savedChat.chatId] = ChatStorageDBModel(
          chatId: savedChat.chatId,
          senderId: savedChat.senderId,
          receiverId: savedChat.receiverId,
          type: savedChat.type,

          imageText: savedChat.imageText ?? '',
          imagePath: savedChat.imagePath ?? "",

          voiceDuration: savedChat.voiceDuration,
          voicePath: savedChat.voicePath,
          isSeen: savedChat.isSeen,
          isRead: savedChat.isRead,

          audioDuration: savedChat.audioDuration,
          audioPath: savedChat.audioPath,
          audioTitle: savedChat.audioTitle,
          date: savedChat.date,
          isDownloaded: savedChat.isDownloaded,
          message: savedChat.message ?? "",
          parentAudioDuration: savedChat.parentAudioDuration,
          parentMessageSenderId: savedChat.parentMessageSenderId,
          parentMessageType: savedChat.parentMessageType,
          parentText: savedChat.parentText,
          parentVoiceDuration: savedChat.parentVoiceDuration,
          repliedMessage: savedChat.repliedMessage,
        );
      }
      return emit(RetrieveChatSuccessState(chats: _chats.values.toList()));
    } catch (e) {
      printDebug(e);
      return emit(RetrieveChatErrorState(errorMessage: 'Something went wrong'));
    }
  }

  //------------- GET SOCKET MESSAGE BLOC --------------------
  void getSocketMessage(
    IncomingMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final ChatStorageDBModel chat = ChatStorageDBModel(
        chatId: event.chat.chatId,
        senderId: event.chat.senderId,
        receiverId: event.chat.receiverId,
        type: event.chat.type,
        message: event.chat.textMessage ?? "",
        imagePath: event.chat.imageUrl,
        imageText: event.chat.imageText,
        date: event.chat.time,
        audioPath: event.chat.audioUrl,
        audioDuration: event.chat.audioDuration,
        audioTitle: event.chat.audioTitle,
        voicePath: event.chat.voiceUrl ?? "",
        voiceDuration: event.chat.voiceDuration ?? "",
        isSeen: event.chat.isSeen,
        isRead: event.chat.isRead,
        isDownloaded: false,
        parentAudioDuration: event.chat.parentAudioDuration,
        parentMessageSenderId: event.chat.parentMessageSenderId,
        parentMessageType: event.chat.parentMessageType,
        parentText: event.chat.parentText,
        parentVoiceDuration: event.chat.parentVoiceDuration,
        repliedMessage: event.chat.repliedMessage,
      );
      _chats[chat.chatId] = chat;
      if (event.chat.type != "audioCall" && event.chat.type != "videoCall") {
        emit(SocketMessagesState(chat: event.chat));
      }
      //Emitting chats after added a new chat
      emit(RetrieveChatSuccessState(chats: _chats.values.toList()));
      //After emitting new state , saving the new message
      await _chatStorage.saveChat(chat: chat);
    } catch (e) {
      printDebug("Socket message error : $e");
      return emit(RetrieveChatErrorState(errorMessage: 'Something went wrong'));
    }
  }

  //------------ FETCH TEMP MESSAGES BLOC --------------
  Future<void> getTempMessages(
    FetchTempMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(FetchTemporaryMessagesLoadingState());
    final String? token = await getToken();
    if (token != null) {
      final Either<List<dynamic>?, ErrorMessageModel?> result =
          await _chatRepoImple.fetchTempMessages(token: token);
      //Checking whether it returns success state or error state
      result.fold(
        //Success state
        (chatEntities) async {
          if (chatEntities != null && chatEntities.isNotEmpty) {
            for (var chatJson in chatEntities) {
              //Parsing chat data from chatEntities
              final ChatEntity chatEntity = ChatEntity.fromJson(chatJson);

              final ChatStorageDBModel chat = ChatStorageDBModel(
                chatId: chatEntity.chatId,
                senderId: chatEntity.senderId,
                receiverId: chatEntity.receiverId,
                type: chatEntity.type,
                message: chatEntity.textMessage,
                imagePath: chatEntity.imageUrl,
                imageText: chatEntity.imageText,
                date: chatEntity.time,
                isSeen: chatEntity.isSeen,
                isRead: chatEntity.isRead,
                audioPath: chatEntity.audioUrl ?? "",
                audioDuration: chatEntity.audioDuration ?? "",
                audioTitle: chatEntity.audioTitle ?? "",
                voicePath: chatEntity.voiceUrl ?? "",
                voiceDuration: chatEntity.voiceDuration ?? "",
                isDownloaded: false,
                parentAudioDuration: chatEntity.parentAudioDuration ?? "",
                parentMessageSenderId: chatEntity.parentMessageSenderId ?? 0,
                parentMessageType: chatEntity.parentMessageType ?? "",
                parentText: chatEntity.parentText ?? "",
                parentVoiceDuration: chatEntity.parentVoiceDuration ?? "",
                repliedMessage: chatEntity.repliedMessage,
              );
              _chats[chat.chatId] = chat;
              _chatStorage.saveChat(chat: chat);
            }
            //Fetching seen info if the temp messages is not empty
            final Either<SuccessMessageModel?, ErrorMessageModel?> seenResult =
                await _chatRepoImple.fetchSeenIndication(
                  token: token,
                  receiverId: event.receiverId,
                );
            //Checking whether the result is success or not
            seenResult.fold(
              //Success state
              (_) {
                printDebug("Success");
              },
              //Error state
              (errorModel) {
                if (errorModel != null) {
                  return emit(
                    FetchTemporaryMessagesErrorState(
                      errorMessage: errorModel.message,
                    ),
                  );
                }
              },
            );
            _chatRepoImple.deleteSeenIndication(
              token: token,
              receiverId: event.receiverId,
            );
            _chatRepoImple.deleteTempMessages(token: token);
          } else {
            return emit(FetchTemporaryMessagesSuccessState());
          }
        },
        //Error state
        (errorModel) {
          if (errorModel != null) {
            return emit(
              FetchTemporaryMessagesErrorState(
                errorMessage: errorModel.message,
              ),
            );
          }
        },
      );
    } else {
      return emit(NullState());
    }
  }

  //---------- GET SOCKET INDICATOR BLOC ---------------
  Future<void> getIndicator(
    IncomingIndicatorEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.indication == "Typing") {
      emit(TypeIndicatorState());
    } else if (event.indication == "Not typing") {
      emit(NotTypingIndicatorState());
    } else if (event.indication == "Recording") {
      emit(RecordingIndicateState());
    } else if (event.indication == "Not recording") {
      emit(NotRecordingState());
    }
    return emit(OnlineIndicationState(isOnline: isReceiverInOnline));
  }

  //---------- SEND INDICATOR BLOC ----------------
  Future<void> sendIndicator(
    IndicateEvent event,
    Emitter<ChatState> emit,
  ) async {
    _websocketRepoImple.sendIndication(
      receiverId: event.receiverId,
      indication: event.indication,
      senderId: event.senderId,
    );
  }

  //--------------- EXIT CONNECTION BLOC -----------
  void exitConnection(
    ExitFromChatConnectionEvent event,
    Emitter<ChatState> emit,
  ) {
    isReceiverInOnline = false;
    _websocketRepoImple.exitFromChatConnection();
  }

  //--------------- GET ONLINE STATUS BLOC -------------
  void getOnlineStatus(OnlineIndicationEvent event, Emitter<ChatState> emit) {
    return emit(OnlineIndicationState(isOnline: isReceiverInOnline));
  }

  //-------------- GET SEEN INDICATION BLOC ---------------
  void getSeenIndicator(IndicateSeenEvent event, Emitter<ChatState> emit) {
    _chatStorage.changeSeenStatus(
      receiverId: event.receiverId,
      senderId: event.senderId,
    );
    emit(IndicateSeenState(userId: event.receiverId));
  }

  //-------------- REMOVE UNREAD MESSAGE COUNT BLOC -------------
  void removeUnreadMessageCount(
    RemoveUnreadMessagesCount event,
    Emitter<ChatState> emit,
  ) {
    if (unreadMessagesCounts.containsKey(
      "${event.currentUserId}${event.receiverId}",
    )) {
      unreadMessagesCounts.update("${event.currentUserId}${event.receiverId}", (
        unreadMessageDetails,
      ) {
        return UnreadMessageModel(
          senderId: unreadMessageDetails.senderId,
          time: unreadMessageDetails.time,
          unreadMessagesCount: 0,
        );
      });
    }
    _chatStorage.changeReadStatusAsTrue(
      receiverId: event.receiverId,
      currentUserId: event.currentUserId,
    );
    emit(
      UnreadMessageCountState(
        unreadMessagesCount: 0,
        senderId: event.receiverId,
      ),
    );
  }

  //---------------- FETCH SEEN INFO BLOC -------------
  Future<void> fetchSeenInfo(
    FetchSeenInfoEvent event,
    Emitter<ChatState> emit,
  ) async {
    //Checking if there is any unseen message
    final int unseenMessageCount = _chatStorage.getUnseenMessageCount(
      senderId: event.currentUserId,
      receiverId: event.receiverId,
    );
    //If there is an unseen message
    if (unseenMessageCount != 0) {
      final String? token = await getToken();
      if (token != null) {
        final result = await _chatRepoImple.fetchSeenIndication(
          token: token,
          receiverId: event.receiverId,
        );
        result.fold(
          ((_) {
            //Deleting the seen info when the result emits success state
            _chatRepoImple.deleteSeenIndication(
              token: token,
              receiverId: event.receiverId,
            );
            return emit(FetchSeenInfoSuccessState());
          }),
          (errorMessage) {
            if (errorMessage != null) {
              return emit(
                FetchSeenInfoErrorState(errorMessage: errorMessage.message),
              );
            }
          },
        );
      } else {
        return emit(
          FetchSeenInfoErrorState(errorMessage: 'Something went wrong'),
        );
      }
    } else {
      return emit(NullState());
    }
  }

  //------------------ SAVE SEEN INFO BLOC --------------
  Future<void> saveSeenInfo(
    SaveSeenInfoEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(SaveSeenInfoLoadinState());
    final String? token = await getToken();
    if (token == null) {
      return emit(SaveSeenInfoErrorState(errorMessage: 'Something went wrong'));
    }
    final result = await _chatRepoImple.saveSeenInfo(
      token: token,
      senderId: event.senderId,
    );
    //Checking whether it returns success state or error state
    result.fold(
      //Success state
      (_) {
        return emit(SaveSeenInfoSuccessState());
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(SaveSeenInfoErrorState(errorMessage: errorModel.message));
        }
      },
    );
  }

  //---------------- UPLOAD FILE BLOC --------------
  Future<void> uploadFile(
    UploadFileEvent event,
    Emitter<ChatState> emit,
  ) async {
    final String? token = await getToken();
    if (token == null) {
      return emit(UploadFileError(errorMessage: 'Something went wrong'));
    }

    final DateTime time = DateTime.now();
    final String chatId = Uuid().v8();

    //For uploading the file
    _chats[chatId] = ChatStorageDBModel(
      chatId: chatId,
      senderId: event.senderId,
      receiverId: event.receiverId,
      type: "${event.type}Upload",
      imagePath: event.filePath,
      imageText: event.text,
      voicePath: event.filePath,
      voiceDuration: event.voiceDuration,
      audioPath: event.filePath,
      audioDuration: event.audioDuration,
      audioTitle: event.audioTitle,
      isSeen: false,
      isRead: false,
      date: time.toString(),
      isDownloaded: false,
      message: "",
      parentAudioDuration: event.parentAudioDuration,
      parentMessageSenderId: event.parentMessageSenderId,
      parentMessageType: event.parentMessageType,
      parentText: event.parentText,
      parentVoiceDuration: event.parentVoiceDuration,
      repliedMessage: event.replyMessage,
    );

    emit(RetrieveChatSuccessState(chats: _chats.values.toList()));
    if (event.type == "image") {
      emit(UploadImageLoadingState(chatId: chatId));
    } else if (event.type == "audio") {
      emit(UploadAudioLoadingState(chatId: chatId));
    } else if (event.type == "voice") {
      emit(UploadVoiceLoadingState(chatId: chatId));
    }
    final Either<
      ({String fileType, String fileUrl, String publicId})?,
      ErrorMessageModel?
    >
    result = await _fileManagerRepoImple.uploadFile(
      token: token,
      filePath: event.filePath,
      fileType: event.type,
    );
    //Checking whether the result returns success state or error state
    result.fold(
      //Success state
      (fileDetails) {
        if (fileDetails != null) {
          if (event.type == "image") {
            return emit(
              UploadImageSuccessState(
                imageText: event.text,
                imageUrl: fileDetails.fileUrl,
                publicId: fileDetails.publicId,
                type: "image",
              ),
            );
          } else if (event.type == "audio") {
            return emit(
              UploadAudioSuccessState(
                audioUrl: fileDetails.fileUrl,
                publicId: fileDetails.publicId,
              ),
            );
          } else if (event.type == "voice") {
            return emit(
              UploadVoiceSuccessState(
                voiceUrl: fileDetails.fileUrl,
                publicId: fileDetails.publicId,
              ),
            );
          }
        }
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(UploadFileError(errorMessage: errorModel.message));
        }
      },
    );
  }

  //-------------------- SAVE FILE BLOC --------------
  Future<void> saveFile(SaveFileEvent event, Emitter<ChatState> emit) async {
    emit(SaveFileLoadingState(chatId: event.chatId));
    final ChatStorageDBModel chat = ChatStorageDBModel(
      chatId: event.chatId,
      senderId: event.senderId,
      receiverId: event.receiverId,
      type: event.type,
      imageText: event.imageText,
      imagePath: event.imagePath,
      voicePath: event.voicePath,
      voiceDuration: event.voiceDuration,
      audioDuration: event.type == "audio" ? event.audioVideoDuration : "",
      audioPath: event.audioPath,
      audioTitle: event.type == "audio" ? event.audioVideoTitle : "",
      isSeen: false,
      isRead: true,
      date: event.time,
      isDownloaded: true,
      message: "",
      parentAudioDuration: event.parentAudioDuration,
      parentMessageSenderId: event.parentMessageSenderId,
      parentMessageType: event.parentMessageType,
      parentText: event.parentText,
      parentVoiceDuration: event.parentVoiceDuration,
      repliedMessage: event.repliedMessage,
    );
    //Replacing the upload media with new downloaded media
    _chats.update(chat.chatId, (_) {
      return chat;
    });
    //Emitting all chats
    emit(RetrieveChatSuccessState(chats: _chats.values.toList()));
    //Deleting old file which is coming only with url
    _chatStorage.deleteSingleChat(chatId: event.chatId);
    //Saving new image with image path
    _chatStorage.saveChat(
      chat: ChatStorageDBModel(
        chatId: chat.chatId,
        senderId: chat.senderId,
        receiverId: chat.receiverId,
        type: chat.type,
        message: chat.message,
        imagePath: chat.imagePath,
        imageText: chat.imageText,
        date: chat.date,
        isSeen: chat.isSeen,
        isRead: chat.isRead,
        isDownloaded: true,
        audioPath: chat.audioPath,
        audioDuration: chat.audioDuration,
        audioTitle: chat.audioTitle,
        voicePath: chat.voicePath,
        voiceDuration: chat.voiceDuration,
        parentAudioDuration: event.parentAudioDuration,
        parentMessageSenderId: event.parentMessageSenderId,
        parentMessageType: event.parentMessageType,
        parentText: event.parentText,
        parentVoiceDuration: event.parentVoiceDuration,
        repliedMessage: event.repliedMessage,
      ),
    );
    /*If sender is current user , then sending the file to socket connection otherwise the current user will be receiver
    who is gonna save this file and receiver does not have to send it back to sender
    */
    emit(
      SaveFileSuccessState(
        senderId: chat.senderId,
        fileUrl: event.fileUrl,
        fileType: chat.type,
        imageText: chat.imageText ?? "",
        time: chat.date,
        chatId: chat.chatId,
        publicId: event.publicId,
      ),
    );
    //Parsing the string data and time
    final DateTime? time = DateTime.tryParse(chat.date);
    if (time != null) {
      final int anotherUserId =
          event.senderId != event.currentUserId
              ? event.senderId
              : event.receiverId;
      lastMessage["${event.currentUserId}$anotherUserId"] = LastMessageModel(
        textMessage: "",
        messageType: chat.type,
        time: time.toUtc().toIso8601String(),
        audioDuration: chat.audioDuration,
        imageText: chat.imageText ?? "",
        voiceDuration: chat.voiceDuration,
      );
    }
    if (chat.senderId == event.currentUserId) {
      _websocketRepoImple.sendMessage(
        ChatModel(
          chatId: chat.chatId,
          senderId: chat.senderId,
          receiverId: chat.receiverId,
          senderName: event.senderName,
          senderProfilePic: event.senderProfilePic,
          type: chat.type,
          textMessage: "",
          time: chat.date,
          imageText: chat.imageText,
          imageUrl: event.type == "image" ? event.fileUrl : "",
          voiceUrl: event.type == "voice" ? event.fileUrl : "",
          voiceDuration: event.voiceDuration,
          audioUrl: event.type == "audio" ? event.fileUrl : "",
          audioDuration: event.type == "audio" ? event.audioVideoDuration : "",
          audioTitle: event.type == "audio" ? event.audioVideoTitle : "",
          videoUrl: event.type == "video" ? event.fileUrl : "",
          videoTitle: event.type == "video" ? event.audioVideoTitle : "",
          videoDuration: "",
          isSeen: chat.isSeen,
          isRead: chat.isRead,
          parentAudioDuration: event.parentAudioDuration,
          parentMessageSenderId: event.parentMessageSenderId,
          parentMessageType: event.parentMessageType,
          parentText: event.parentText,
          parentVoiceDuration: event.parentVoiceDuration,
          repliedMessage: event.repliedMessage,
          senderBio: event.senderBio,
        ),
      );
    }
  }

  //-------------------- FETCH TOTAL MESSAGE COUNT BLOC ----------------------------
  Future<void> _fetchMessageCount(
    FetchMessageCountEvent event,
    Emitter<ChatState> emit,
  ) async {
    //Getting every message count

    //Total message count
    final int totalMessageCount = _chatStorage.getTotalMessageCount(
      currentUserId: event.currentUserId,
      receiverId: event.receiverId,
    );
    //Total images count
    final int totalImagesCount = _chatStorage.getTotalImageCount(
      currentUserId: event.currentUserId,
      receiverId: event.receiverId,
    );
    //Total audios count
    final int totalAudiosCount = _chatStorage.getTotalAudiosCount(
      currentUserId: event.currentUserId,
      receiverId: event.receiverId,
    );

    return emit(
      MessageCountState(
        totalMessageCount: totalMessageCount,
        totalImagesCount: totalImagesCount,
        totalAudiosCount: totalAudiosCount,
      ),
    );
  }

  //------------------ FETCH MEDIA BLOC ---------------------
  void _fetchMedia(FetchMediaEvent event, Emitter<ChatState> emit) {
    emit(FetchMediaLoadingState());
    try {
      //Fetching media from local storage
      final List<ChatStorageDBModel> media = _chatStorage.getMedia(
        currentUserId: event.currentUserId,
        oppositeUserId: event.oppositeUserId,
        limit: event.limit,
      );

      return emit(FetchMediaSuccessState(media: media));
    } catch (_) {
      return emit(FetchMediaErrorState());
    }
  }

  //----------------- DELETE FOR EVERYONE BLOC -----------
  void _deleteChatForEveryOne(
    DeleteForEveryone event,
    Emitter<ChatState> emit,
  ) async {
    emit(DeleteForEveryoneLoadingState());
    final String? token = await getToken();
    if (token != null) {
      final String chatId = selectedChats.keys.toList()[0];
      final Either<SuccessMessageModel, ErrorMessageModel> result =
          await _chatRepoImple.deleteSingleChat(chatId: chatId, token: token);

      //Folding it for checking whether it returns success state or error state
      result.fold(
        //Success
        (_) {
          //Removing the chat from local storage
          _chatStorage.deleteSingleChat(chatId: chatId);
          selectedChats.remove(chatId);
          _chats.remove(chatId);
          emit(SelectChatState(selectedChats: selectedChats));
          emit(RetrieveChatSuccessState(chats: _chats.values.toList()));
          return emit(DeleteForEveryoneSuccessState());
        },
        //Error
        (_) {
          return emit(DeleteForEveryoneErrorState());
        },
      );
    } else {
      emit(DeleteForEveryoneErrorState());
    }
  }

  //----------------- SEND CALL HISTORY INFO BLOC -----------
  void _sendCallHistory(SendCallHistoryInfo event, Emitter<ChatState> emit) {
    final String currentTime = DateTime.now().toString();
    final String chatId = Uuid().v8();
    _websocketRepoImple.sendMessage(
      ChatModel(
        chatId: chatId,
        senderId: event.callerId,
        senderName: "",
        senderProfilePic: "",
        senderBio: "",
        receiverId: event.calleeId,
        type: event.callType,
        textMessage: "",
        time: currentTime,
        imageText: "",
        imageUrl: "",
        voiceUrl: "",
        voiceDuration: "",
        audioUrl: "",
        audioDuration: "",
        audioTitle: "",
        videoTitle: "",
        videoUrl: "",
        videoDuration: "",
        isSeen: true,
        isRead: true,
        repliedMessage: false,
        parentAudioDuration: "",
        parentMessageSenderId: 0,
        parentMessageType: "",
        parentText: "",
        parentVoiceDuration: "",
      ),
    );
  }
}
