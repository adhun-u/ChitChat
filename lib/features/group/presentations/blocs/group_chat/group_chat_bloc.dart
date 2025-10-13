import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/data/repo_imple/file_manager_repo_imple.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/features/group/data/datasource/group_chat_storage.dart';
import 'package:chitchat/features/group/data/models/chat_model.dart';
import 'package:chitchat/features/group/data/repo_imple/group_chat_repo_imple.dart';
import 'package:chitchat/features/group/data/repo_imple/websocket_repo_imple.dart';
import 'package:chitchat/features/group/domain/entities/chat/group_chat_entity.dart';
import 'package:chitchat/features/group/domain/entities/chat_storage/group_chat_storage_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
part 'group_chat_event.dart';
part 'group_chat_state.dart';

class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  final GroupChatRepoImple _groupChatRepoImple = GroupChatRepoImple();
  final GroupWebSocketRepoImple _groupWebsocketRepoImple =
      GroupWebSocketRepoImple();
  final FileManagerRepoImple _fileManagerRepoImple = FileManagerRepoImple();
  final GroupChatStorage _storage = GroupChatStorage();

  StreamSubscription? _streamSubscription;
  //For fetching group chats from local storage
  final Map<String, GroupChatStorageModel> groupChats = {};

  //Creating a variable for preventing unwanted listening
  String _oldDocId = "";
  //Creating a variable for knowing last update doc
  String _lastUpdatedDocId = "";

  //For knowing if current user is in chat page
  final Map<String, bool> _chatPagesDetails = {};
  //For deleting
  final Map<String, SelectedGroupChatModel> selectedChats = {};
  //For detecting that how many unread messages current user have
  final Map<String, UnreadGroupMessageCountModel> _unreadMessagesCounts = {};
  String _lastSocketConnectedGroupId = "";

  GroupChatBloc() : super(GroupChatInitial()) {
    //To send text messsage
    on<SendGroupTextMessage>(_sendTextMessage);
    //To connect with firestore for knowing changes
    on<ConnectWithFireStore>(_connectWithFirestore);
    //To get group chats from local storage
    on<FetchGroupMessagesEvent>(_fetchGroupChats);
    //To get new messages from firestore
    on<_NotifyMessageEvent>(_getFirestoreMessage);
    //To change seen users count
    on<ChangeSeenUserCountEvent>(_changeSeenUserCount);
    //To fetch seen info of a group message
    on<FetchGroupMessageSeenInfoEvent>(_fetchSeenInfo);
    //To clear all chats of a group
    on<ClearAllGroupChatsEvent>(_clearGroupChat);
    //To connect group chat websocket
    on<ConnectGroupChatSocketEvent>(_connectSocket);
    //To close group chat websocket
    on<CloseGroupChatSocketEvent>(_closeConnection);
    //To change seen info in firebase
    on<ChangeSeenInfoInFirebaseEvent>(_changeEveryDoc);
    //To emit indication when socket emit new data
    on<GetIndicationEvent>((event, emit) async {
      if (event.indication == "seen") {
        //Emitting seen indication
        emit(MessageSeenIndicatorState(groupId: event.groupId));
        //Changing seen info as true in local storage
        _storage.changeSeenStatus(
          senderId: event.userId,
          groupId: event.groupId,
        );
        await _groupChatRepoImple.deleteMultipleDocs(senderId: event.userId);
      } else if (event.indicationType == "Typing") {
        //Emitting typing indicator to show someone is typing
        emit(GroupChatTypingIndicator(indication: event.indication));
      } else if (event.indicationType == "Not typing") {
        //Emitting not typing indicator to remove "Typing"
        emit(GroupChatNotTypingIndicator());
      } else if (event.indicationType == "Recording") {
        //Emitting recording indicator to show someone is recording audio
        emit(GroupChatRecordingIndicator(indication: event.indication));
      } else if (event.indicationType == "Not recording") {
        //Emitting not recording indicator to remove recording
        emit(GroupChatNotRecordingIndicator());
      } else if (event.indication == "call") {
        //Emitting the data whether the group is in call or not
        if (event.isInCall != null) {
          emit(GroupCallIndication(isInCall: event.isInCall!));
        }
      }
    });
    //To send indication to socket connection
    on<SendIndicationEvent>((event, emit) {
      _groupWebsocketRepoImple.sendGroupSeenIndication(
        indication: event.indication,
        groupId: event.groupId,
        userId: event.userId,
        indicationType: event.indicationType,
      );
    });
    //To change page status
    on<EnterInChatPageEvent>((event, emit) {
      _chatPagesDetails[event.groupId] = true;
    });
    //To upload file for sending file as message
    on<UploadGroupChatFileEvent>(_uploadFile);
    //To save and send a file to other members of this group
    on<SaveGroupChatFileEvent>(_saveGroupChatFile);
    //To select chats to delete
    on<SelectGroupChatEvent>((event, emit) {
      if (!selectedChats.containsKey(event.chatId)) {
        selectedChats[event.chatId] = SelectedGroupChatModel(
          isSeen: event.isSeen,
          senderId: event.senderId,
        );
      } else {
        selectedChats.remove(event.chatId);
      }
      emit(SelectedGroupChatsState(selectedChats: selectedChats));
    });
    //To deselect selected chats
    on<DeSelectGroupChats>((event, emit) {
      selectedChats.clear();
      emit(SelectedGroupChatsState(selectedChats: selectedChats));
    });
    //To change seen info in seleted group chats
    on<ChangeSeenInfoInGroupSelectedChatsEvent>((event, emit) {
      if (selectedChats.containsKey(event.chatId)) {
        selectedChats.update(event.chatId, (selectedChat) {
          return SelectedGroupChatModel(
            senderId: selectedChat.senderId,
            isSeen: true,
          );
        });
      }
      emit(SelectedGroupChatsState(selectedChats: selectedChats));
    });
    //To delete all selected chats from local storage
    on<DeleteGroupChatsForMeEvent>((event, emit) {
      //Removing  from local storage
      _storage.deleteSelectedChats(ids: selectedChats.keys.toList());
      //Removing from group chats
      groupChats.removeWhere((key, value) {
        return selectedChats.containsKey(key);
      });

      selectedChats.clear();
      emit(FetchGroupChatSuccessState(chats: groupChats));
      emit(SelectedGroupChatsState(selectedChats: selectedChats));
    });
    //To delete the seleted chat from firebase store
    on<DeleteGroupChatForEveryOneEvent>(_deleteGroupChat);
    //To cancel uploading process
    on<CancelGroupMediaUploadProcess>((event, emit) {
      groupChats.remove(event.chatId);
      emit(FetchGroupChatSuccessState(chats: groupChats));
    });
    //To emit file save state
    on<_EmitOtherGroupChatState>((event, emit) {
      emit(event.state);
    });
    //To emit unread message count
    on<_EmitUnreadMessageCount>((event, emit) {
      //Getting current count
      final UnreadGroupMessageCountModel? currentCountDetails =
          _unreadMessagesCounts[event.groupId];
      final int currentCount =
          currentCountDetails != null
              ? currentCountDetails.unreadMessagesCount
              : 0;
      final int unreadMessageCount = currentCount + 1;

      _unreadMessagesCounts[event.groupId] = UnreadGroupMessageCountModel(
        unreadMessagesCount: unreadMessageCount,
        groupId: event.groupId,
      );

      emit(
        UnreadGroupMessagesCountState(
          unreadMessagesCount: unreadMessageCount,
          groupId: event.groupId,
        ),
      );
    });
    //To remove unread message count
    on<RemoveUnreadGroupMessagesCount>((event, emit) {
      emit(
        UnreadGroupMessagesCountState(
          unreadMessagesCount: 0,
          groupId: event.groupId,
        ),
      );
    });

    //To add call history in firestore
    on<AddGroupCallHistroyEvent>((event, emit) async {
      final String chatId = Uuid().v8();
      final String currentTime = DateTime.now().toString();

      final GroupChatStorageModel callHistory = GroupChatStorageModel(
        groupId: event.groupId,
        chatId: chatId,
        senderId: event.currentUserId,
        senderName: event.currentUserName,
        messageType: event.callType,
        textMessage: "",
        imagePath: "",
        imageText: "",
        audioPath: "",
        audioDuration: "",
        audioTitle: "",
        voicePath: "",
        voiceDuration: "",
        time: currentTime,
        isSeen: true,
        isRead: true,
        isMediaDownloaded: true,
        repliedMessage: false,
        parentAudioDuration: "",
        parentMessageSenderId: 0,
        parentMessageSenderName: "",
        parentMessageType: "",
        parentText: "",
        parentVoiceDuration: "",
      );
      groupChats[chatId] = callHistory;

      emit(FetchGroupChatSuccessState(chats: groupChats));

      await _groupChatRepoImple.sendMessage(
        groupChat: GroupChatModel(
          senderId: callHistory.senderId,
          senderName: callHistory.senderName,
          groupId: callHistory.groupId,
          chatId: chatId,
          messageType: callHistory.messageType,
          textMessage: "",
          imageUrl: "",
          imageText: "",
          voiceUrl: "",
          voiceDuration: "",
          audioUrl: "",
          audioDuration: "",
          audioTitle: "",
          videoUrl: "",
          videoDuration: "",
          videoTitle: "",
          time: currentTime,
          isSeen: true,
          isRead: true,
          repliedMessage: false,
          parentAudioDuration: "",
          parentMessageSenderId: 0,
          parentMessageSenderName: "",
          parentMessageType: "",
          parentText: "",
          parentVoiceDuration: "",
        ),
        totalMembersCount: 0,
        groupName: "",
        groupBio: "",
        groupImageUrl: "",
        groupAdminUserId: 0,
        groupCreatedDate: "",
      );
    });
  }

  //------------------- SEND TEXT MESSAGE BLOC ----------------
  Future<void> _sendTextMessage(
    SendGroupTextMessage event,
    Emitter<GroupChatState> emit,
  ) async {
    final String time = DateTime.now().toString();
    final GroupChatModel groupChat = GroupChatModel(
      senderId: event.currentUserId,
      groupId: event.groupId,
      senderName: event.currentUsername,
      chatId: "",
      messageType: "text",
      textMessage: event.textMessage,
      imageUrl: "",
      imageText: "",
      voiceUrl: "",
      voiceDuration: "",
      audioUrl: "",
      audioDuration: "",
      audioTitle: "",
      videoUrl: "",
      videoDuration: "",
      videoTitle: "",
      time: time,
      isSeen: false,
      isRead: true,
      parentAudioDuration: event.parentAudioDuration,
      parentMessageSenderId: event.parentMessageSenderId,
      parentMessageSenderName: event.parentSenderName,
      parentMessageType: event.parentMessageType,
      parentText: event.parentText,
      parentVoiceDuration: event.parentVoiceDuration,
      repliedMessage: event.repliedMessage,
    );

    final Either<SuccessMessageModel?, ErrorMessageModel?> result =
        await _groupChatRepoImple.sendMessage(
          groupChat: groupChat,
          totalMembersCount: event.totalMembersCount,
          groupBio: event.groupBio,
          groupImageUrl: event.groupImageUrl,
          groupName: event.groupName,
          groupAdminUserId: event.groupAdminUserId,
          groupCreatedDate: event.groupCreatedAt,
        );

    //Checking whether the message is sent successfully or not
    result.fold(
      (success) async {
        add(
          _EmitOtherGroupChatState(
            state: GroupTextMessageSuccessState(
              groupId: event.groupId,
              text: event.textMessage,
              lastTime: time,
            ),
          ),
        );
        final String? token = await getToken();
        //Sending notification to all group members
        if (token != null) {
          await _groupChatRepoImple.sendGroupMessageNotification(
            groupId: event.groupId,
            title: event.groupName,
            body: event.textMessage,
            imageUrl: event.groupImageUrl,
            type: "text",
            token: token,
          );
        }
      },
      (error) {
        emit(GroupTextMessageSendingErrorState());
        printDebug("Message sending error");
      },
    );
  }

  //------------------ GET ALL MESSAGE FROM FIRESTORE BLOC ----------------
  Future<void> _connectWithFirestore(
    ConnectWithFireStore event,
    Emitter<GroupChatState> emit,
  ) async {
    emit(ConnectFirebaseLoadingState());
    final Either<Stream<QuerySnapshot<Object?>>?, ErrorMessageModel?> result =
        await _groupChatRepoImple.getStreamData(
          currentUserId: event.currentUserId,
        );
    //Checking whether it returns success state or error state
    result.fold(
      (streamSnapshot) async {
        if (streamSnapshot != null) {
          //Listening for knowing if any data is inserted in firestore
          emit(ConnectFirebaseSuccessState());
          emit(FetchGroupChatSuccessState(chats: groupChats));
          await _streamSubscription?.cancel();
          _streamSubscription = streamSnapshot.listen((snapshot) {
            if (snapshot.docChanges.isEmpty) {
              return;
            }
            final DocumentChange<Object?> data = snapshot.docChanges.last;
            final String docId = data.doc.id;
            //For knowing if any data has been changed
            if (data.type == DocumentChangeType.modified) {
              final String docId = data.doc.id;
              final int senderId = data.doc['senderId'];
              final bool isSeen = data.doc['isSeen'];
              final String groupId = data.doc['groupId'];

              if (_lastUpdatedDocId != docId) {
                if (isSeen) {
                  //Then sending a seen indication to sender of this chat
                  add(
                    SendIndicationEvent(
                      indication: "seen",
                      groupId: groupId,
                      userId: senderId,
                    ),
                  );
                }
                _lastUpdatedDocId = docId;
              }
            }
            if (_oldDocId == docId) {
              return;
            }
            _oldDocId = docId;
            //For knowing if any new data is added
            if (data.type == DocumentChangeType.added) {
              //Parsing the json to GroupChatModel
              final Map<String, dynamic>? jsonData =
                  data.doc.data() as Map<String, dynamic>?;

              if (jsonData != null) {
                final GroupChatEntity messageEntity = GroupChatEntity.fromJson(
                  jsonData,
                );

                if (messageEntity.senderId == event.currentUserId &&
                    (messageEntity.messageType == "image" ||
                        messageEntity.messageType == "audio" ||
                        messageEntity.messageType == "voice")) {
                  return;
                }

                final bool isInChatPage =
                    _chatPagesDetails[messageEntity.groupId] ?? false;

                if (!isInChatPage &&
                    messageEntity.messageType != "audioCall" &&
                    messageEntity.messageType != "videoCall") {
                  //Emitting unread message status
                  add(_EmitUnreadMessageCount(groupId: messageEntity.groupId));
                }
                final int unreadMessageCount =
                    _unreadMessagesCounts[messageEntity.groupId]
                        ?.unreadMessagesCount ??
                    0;

                if (messageEntity.messageType != "audioCall" &&
                    messageEntity.messageType != "videoCall") {
                  add(
                    _EmitOtherGroupChatState(
                      state: GroupDetailsWithMessageState(
                        groupName: messageEntity.groupName,
                        groupImageUrl: messageEntity.groupImageUrl ?? "",
                        groupBio: messageEntity.groupBio ?? "",
                        lastTextMessage: messageEntity.textMessage ?? "",
                        lastMessageType: messageEntity.messageType,
                        lastMessageTime: messageEntity.time,
                        unreadMessageCount: unreadMessageCount,
                        imageText: messageEntity.imageText ?? "",
                        groupAdminUserId: messageEntity.groupAdminUserId,
                        groupId: messageEntity.groupId,
                        groupCreatedDate: messageEntity.groupCreatedAt,
                        membersLength: messageEntity.members.length,
                      ),
                    ),
                  );
                }

                //Adding to groupChats
                add(
                  _NotifyMessageEvent(
                    newChat: GroupChatStorageModel(
                      senderId: messageEntity.senderId,
                      senderName: messageEntity.senderName,
                      groupId: messageEntity.groupId,
                      chatId: docId,
                      messageType: messageEntity.messageType,
                      textMessage: messageEntity.textMessage ?? "",
                      imagePath: messageEntity.imageUrl ?? "",
                      imageText: messageEntity.imageText ?? "",
                      voicePath: messageEntity.voiceUrl ?? "",
                      voiceDuration: messageEntity.voiceDuration ?? "",
                      audioPath: messageEntity.audioUrl ?? "",
                      audioDuration: messageEntity.audioDuration ?? "",
                      audioTitle: messageEntity.audioTitle ?? "",
                      time: messageEntity.time,
                      isSeen: false,
                      isRead: isInChatPage,
                      isMediaDownloaded: false,
                      parentAudioDuration:
                          messageEntity.parentAudioDuration ?? "",
                      parentMessageSenderId:
                          messageEntity.parentMessageSenderId ?? 0,
                      parentMessageType: messageEntity.parentMessageType ?? "",
                      parentText: messageEntity.parentText ?? "",
                      parentVoiceDuration:
                          messageEntity.parentVoiceDuration ?? "",
                      repliedMessage: messageEntity.repliedMessage,
                      parentMessageSenderName:
                          messageEntity.parentMessageSenderName ?? "",
                    ),
                  ),
                );
              }
            }
          });
        }
      },
      (error) {
        emit(ConnectFirebaseErrorState());
      },
    );
  }

  //--------------- FETCH GROUP CHATS BLOC ---------------------------
  Future<void> _fetchGroupChats(
    FetchGroupMessagesEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    emit(FetchGroupChatLoadingState());
    try {
      //Fetching all group chats in local storage
      final List<GroupChatStorageModel> storageChats = _storage.fetchGroupChats(
        groupId: event.groupId,
      );
      groupChats.clear();
      for (var chat in storageChats) {
        groupChats[chat.chatId] = chat;
      }
      return emit(FetchGroupChatSuccessState(chats: groupChats));
    } catch (e) {
      printDebug("Fetch group chats error : $e");
      return emit(FetchGroupChatErrorState(message: 'Something went wrong'));
    }
  }

  //--------------- GET FIRESTORE MESSAGE --------------------
  Future<void> _getFirestoreMessage(
    _NotifyMessageEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    emit(NewGroupMessageState(newChat: event.newChat));
    if (groupChats.values.lastOrNull == null ||
        groupChats.values.lastOrNull?.groupId == event.newChat.groupId) {
      //Adding to groupChats
      groupChats[event.newChat.chatId] = event.newChat;
      //Emitting group chats after inserted new chat
      emit(FetchGroupChatSuccessState(chats: groupChats));
    }
    //Emitting an indicator for knowing if any new message comes
    if (event.newChat.messageType != "audioCall" ||
        event.newChat.messageType != "videoCall") {
      log("Condition true");
      emit(
        MessageIndicator(
          senderId: event.newChat.senderId,
          chatId: event.newChat.chatId,
        ),
      );
    } else {
      log("False");
    }
    //Saving to database
    _storage.saveGroupChat(event.newChat);
  }

  //------------ CHANGE SEEN USERS COUNT BLOC --------------------------
  Future<void> _changeSeenUserCount(
    ChangeSeenUserCountEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    final Either<Map<String, dynamic>?, ErrorMessageModel?> result =
        await _groupChatRepoImple.fetchSingleDoc(chatId: event.chatId);

    //Checking whether it returns success state or error
    result.fold(
      (data) async {
        if (data != null) {
          //Getting total members count
          final int totalMembersCount = data['totalMembersCount'];
          //Getting seen users count
          final int seenUsersCount = data['seenUsersCount'];
          //Getting sender id
          final int senderId = data['senderId'];

          if (seenUsersCount + 1 < totalMembersCount) {
            await _groupChatRepoImple.increaseSeenUsersCount(
              docId: event.chatId,
            );
          } //Else if changing seen info and sending seen info to sender
          else if (seenUsersCount + 1 == totalMembersCount) {
            //Sending seen info to sender of this message
            add(
              SendIndicationEvent(
                indication: "seen",
                groupId: event.groupId,
                userId: senderId,
              ),
            );
            await _groupChatRepoImple.changeSeenInfo(docId: event.chatId);
          }
        }
      },
      (error) {
        if (error != null) {
          log("Change seen info error : ${error.message}");
        }
      },
    );
  }

  //-------------- FETCH SEEN INFO BLOC --------------------
  Future<void> _fetchSeenInfo(
    FetchGroupMessageSeenInfoEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    emit(FetchSeenInfoLoadingState());
    //Fetching last group message from local storage
    final List<GroupChatStorageModel> lastMessage = _storage
        .isThereAnyUnseenMessages(
          groupId: event.groupId,
          senderId: event.senderId,
        );

    if (lastMessage.isEmpty) {
      emit(FetchSeenInfoSuccessState());
      return emit(FetchGroupChatSuccessState(chats: groupChats));
    }
    final Either<Map<String, dynamic>?, ErrorMessageModel?> result =
        await _groupChatRepoImple.fetchSingleDoc(chatId: lastMessage[0].chatId);

    result.fold((querySnapshot) async {
      if (querySnapshot != null) {
        //Getting seen info
        final bool isSeen = querySnapshot['isSeen'];

        if (isSeen) {
          //Triggering to send seen info
          add(
            GetIndicationEvent(
              groupId: event.groupId,
              indication: "seen",
              userId: event.senderId,
            ),
          );
          //Deleting all group chats that current sent
          await _groupChatRepoImple.deleteMultipleDocs(
            senderId: event.senderId,
          );
        }
      }
    }, (error) {});

    emit(FetchSeenInfoSuccessState());
    return emit(FetchGroupChatSuccessState(chats: groupChats));
  }

  //---------------- CLEAR ALL GROUP CHAT BLOC ------------------
  Future<void> _clearGroupChat(
    ClearAllGroupChatsEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    try {
      emit(ClearAllGroupChatLoadingState());
      _storage.clearAllChat(groupId: event.groupId);
      //Emitting empty chats after deleted all chat
      groupChats.clear();
      emit(FetchGroupChatSuccessState(chats: {}));
      emit(ClearAllGroupChatSuccessState());
    } catch (_) {
      return emit(ClearAllGroupChatErrorState());
    }
  }

  //----------------- CONNECT GROUP CHAT SOCKET BLOC ------------------
  Future<void> _connectSocket(
    ConnectGroupChatSocketEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    _chatPagesDetails[event.groupId] = true;
    _lastSocketConnectedGroupId = event.groupId;
    _unreadMessagesCounts.remove(event.groupId);
    await _groupWebsocketRepoImple.connectGroupChatSocket(
      groupId: event.groupId,
      userId: event.userId,
    );
    //Getting stream data
    _groupWebsocketRepoImple.getGroupIndications().listen((data) {
      final Map<String, dynamic> jsonData =
          jsonDecode(data) as Map<String, dynamic>;
      final String indication = jsonData['indication'];
      final String groupId = jsonData['groupId'];
      final int senderId = jsonData['senderId'];
      final String? indicationType = jsonData['indicationType'] as String?;
      final bool? isInCall = jsonData['isInCall'];
      //Sending seen indication to sender
      add(
        GetIndicationEvent(
          groupId: groupId,
          indication: indication,
          userId: senderId,
          indicationType: indicationType,
          isInCall: isInCall,
        ),
      );
    });
  }

  //----------------- CLOSE GROUP CHAT SOCKET BLOC -------------------
  Future<void> _closeConnection(
    CloseGroupChatSocketEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    if (event.groupId != null) {
      _chatPagesDetails[event.groupId!] = false;
    } else {
      _chatPagesDetails[_lastSocketConnectedGroupId] = false;
    }
    await _groupWebsocketRepoImple.closeGroupChatSocketConnection();
  }

  //------------------- CHANGE EVERY DOCS IN FIREBASE BLOC ---------
  Future<void> _changeEveryDoc(
    ChangeSeenInfoInFirebaseEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    //Changing isSeen as true or incrementing seenUsersCount in firebase
    await _groupChatRepoImple.addSeenInfoToAllMessages(
      groupId: event.groupId,
      currentUserId: event.currentUserId,
    );
    //Changing isRead as true in local storage
    _storage.changeReadStatus(
      groupId: event.groupId,
      currentUserId: event.currentUserId,
    );
  }

  //------------------ UPLOAD IMAGE BLOC -------------------
  Future<void> _uploadFile(
    UploadGroupChatFileEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    //Getting token from database
    final String? token = await getToken();

    if (token == null) {
      return emit(UploadGroupFileErrorState());
    }
    final String chatId = Uuid().v8();
    final String time = DateTime.now().toString();

    //Uploading the file
    groupChats[chatId] = GroupChatStorageModel(
      senderId: event.senderId,
      senderName: event.senderName,
      groupId: event.groupId,
      chatId: chatId,
      messageType: "${event.fileType}Upload",
      textMessage: "",
      imagePath: event.fileType == "image" ? event.filePath : "",
      imageText: event.fileType == "image" ? event.imageText : "",
      voicePath: event.fileType == "voice" ? event.filePath : "",
      voiceDuration: event.fileType == "voice" ? event.voiceDuration : "",
      audioPath: event.fileType == "audio" ? event.filePath : "",
      audioDuration: event.fileType == "audio" ? event.audioVideoDuration : "",
      audioTitle: event.fileType == "audio" ? event.audioVideoTitle : "",
      time: time,
      isSeen: false,
      isRead: true,
      isMediaDownloaded: false,
      parentAudioDuration: event.parentAudioDuration,
      parentMessageSenderId: event.parentMessageSenderId,
      parentMessageType: event.parentMessageType,
      parentText: event.parentText,
      parentVoiceDuration: event.parentVoiceDuration,
      parentMessageSenderName: event.parentMessageSenderName,
      repliedMessage: event.repliedMessage,
    );
    emit(FetchGroupChatSuccessState(chats: groupChats));
    if (event.fileType == "image") {
      emit(UploadGroupChatImageLoadingState(chatId: chatId));
    } else if (event.fileType == "audio") {
      emit(UploadGroupAudioLoadingState(chatId: chatId));
    } else if (event.fileType == "voice") {
      emit(UploadGroupVoiceLoadingState(chatId: chatId));
    }
    final Either<
      ({String fileType, String fileUrl, String publicId})?,
      ErrorMessageModel?
    >
    result = await _fileManagerRepoImple.uploadFile(
      token: token,
      filePath: event.filePath,
      fileType: event.fileType,
    );
    //Checking whether the result returns success state or error state
    result.fold(
      (fileDetails) {
        if (fileDetails != null) {
          //Image upload success state
          if (event.fileType == "image") {
            return emit(
              UploadGroupChatImageSuccessState(
                imageUrl: fileDetails.fileUrl,
                imageText: event.imageText,
                chatId: chatId,
              ),
            );
            //Audio upload success state
          } else if (event.fileType == "audio") {
            return emit(
              UploadGroupAudioSuccessState(
                audioUrl: fileDetails.fileUrl,
                chatId: chatId,
              ),
            );
          } else if (event.fileType == "voice") {
            return emit(
              UploadGroupVoiceSuccessState(
                voiceUrl: fileDetails.fileUrl,
                chatId: chatId,
              ),
            );
          }
        }
      },
      (error) {
        if (error != null) {
          if (event.fileType == "image") {
            return emit(UploadGroupChatImageErrorState(chatId: chatId));
          } else if (event.fileType == "audio") {
            return emit(UploadGroupAudioErrorState(chatId: chatId));
          } else if (event.fileType == "voice") {
            return emit(UploadGroupVoiceErrorState(chatId: chatId));
          }
        }
      },
    );
  }

  //------------------ SAVE GROUP CHAT BLOC ------------------
  Future<void> _saveGroupChatFile(
    SaveGroupChatFileEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    final String? token = await getToken();
    final GroupChatStorageModel savedChat = GroupChatStorageModel(
      groupId: event.groupId,
      chatId: event.chatId,
      senderId: event.senderId,
      senderName: event.senderName,
      messageType: event.fileType,
      textMessage: "",
      imagePath: event.fileType == "image" ? event.filePath : "",
      imageText: event.imageText,
      audioPath: event.fileType == "audio" ? event.filePath : "",
      audioDuration: event.fileType == "audio" ? event.audioVideoDuration : "",
      audioTitle: event.fileType == "audio" ? event.audioVideoTitle : "",
      voicePath: event.fileType == "voice" ? event.filePath : "",
      voiceDuration: event.fileType == "voice" ? event.voiceDuration : "",
      time: event.time,
      isSeen: false,
      isRead: true,
      isMediaDownloaded: true,
      parentAudioDuration: "",
      parentMessageSenderId: 0,
      parentMessageType: "",
      parentText: "",
      parentVoiceDuration: "",
      repliedMessage: false,
      parentMessageSenderName: "",
    );
    //Removing the file from local storage
    if (!event.shouldSendToMembers) {
      _storage.deleteChat(chatId: event.chatId);
    }
    //Saving the image to local storage
    _storage.saveGroupChat(savedChat);
    //Adding new chat to _groupChats
    groupChats[event.chatId] = savedChat;
    emit(FetchGroupChatSuccessState(chats: groupChats));
    if (event.shouldSendToMembers) {
      //Sending to firebase to get every member of this group
      try {
        await _groupChatRepoImple.sendMessage(
          groupBio: event.groupBio,
          groupImageUrl: event.groupImageUrl,
          groupName: event.groupName,
          groupAdminUserId: event.groupAdminUserId,
          totalMembersCount: event.totalMembersCount,
          groupCreatedDate: event.groupCreatedAt,
          groupChat: GroupChatModel(
            senderId: event.senderId,
            senderName: event.senderName,
            groupId: event.groupId,
            chatId: event.chatId,
            messageType: event.fileType,
            textMessage: "",
            imageUrl: event.fileType == "image" ? event.fileUrl : "",
            imageText: event.imageText,
            voiceUrl: event.fileType == "voice" ? event.fileUrl : "",
            voiceDuration: event.fileType == "voice" ? event.voiceDuration : "",
            audioUrl: event.fileType == "audio" ? event.fileUrl : "",
            audioDuration:
                event.fileType == "audio" ? event.audioVideoDuration : "",
            audioTitle: event.fileType == "audio" ? event.audioVideoTitle : "",
            videoUrl: event.fileType == "video" ? event.fileUrl : "",
            videoDuration:
                event.fileType == "video" ? event.audioVideoDuration : "",
            videoTitle: event.fileType == "video" ? event.audioVideoTitle : "",
            time: event.time,
            isSeen: false,
            isRead: true,
            parentAudioDuration: "",
            parentMessageSenderId: 0,
            parentMessageType: "",
            parentText: "",
            parentVoiceDuration: "",
            repliedMessage: event.repliedMessage,
            parentMessageSenderName: "",
          ),
        );
      } catch (e) {
        add(
          _EmitOtherGroupChatState(
            state: SaveGroupChatFileErrorState(chatId: event.chatId),
          ),
        );
        printDebug("Group file save error : $e");
      }

      if (token != null) {
        //Sending group message notification
        await _groupChatRepoImple.sendGroupMessageNotification(
          groupId: event.groupId,
          title: event.groupName,
          body: "",
          imageUrl: event.groupName,
          type: event.fileType,
          token: token,
        );
      }
    }

    add(
      _EmitOtherGroupChatState(
        state: SaveGroupChatFileSuccessState(chatId: event.chatId),
      ),
    );
  }

  //------------------ DELETE GROUP CHAT BLOC ------------
  void _deleteGroupChat(
    DeleteGroupChatForEveryOneEvent event,
    Emitter<GroupChatState> emit,
  ) async {
    emit(DeleteGroupChatFromEveryOneLoadingState());
    final String chatId = selectedChats.keys.toList()[0];
    //Deleting the chat from firebase
    final Either<SuccessMessageModel?, ErrorMessageModel?> result =
        await _groupChatRepoImple.deleteSingleDoc(docId: chatId);

    result.fold(
      //Success
      (_) {
        emit(DeleteGroupChatFromEveryOneSuccessState());
        //Removing the chat from group chat
        groupChats.remove(chatId);
        //Removing the chat from selected chats
        selectedChats.remove(chatId);
        emit(FetchGroupChatSuccessState(chats: groupChats));
        emit(SelectedGroupChatsState(selectedChats: selectedChats));
        //Removing that chat from local storage
        _storage.deleteChat(chatId: chatId);
      },
      //Error
      (_) {
        return emit(DeleteGroupChatFromEveryOneErrorState());
      },
    );
  }
}
