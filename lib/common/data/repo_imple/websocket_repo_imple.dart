import 'dart:convert';
import 'dart:developer';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/common/application/websockets/websocket_service.dart';
import 'package:chitchat/common/domain/repo/websocket_repo.dart';
import 'package:chitchat/features/home/data/models/chat_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketRepoImple implements WebsocketRepo {
  //Creating an instance of WebsocketService
  final WebsocketService _websocketService = WebsocketService();

  //------- CONNECT SOCKET REPO IMPLEMENTING ----------------
  //For connecting websocket for one to one chat
  @override
  Future<void> connectSocket({
    required int currentUserId,
    required String username,
    required String profilePic,
  }) async {
    //Connecting the web socket
    try {
      await _websocketService.connectWebSocket(
        "$websocketUrl?currentUserId=$currentUserId&currentUsername=$username&currentUserProfilePic=$profilePic",
      );
    } catch (e) {
      log('Socket error : $e');
    }
  }

  //------------ EXIT CHAT CONNECTION REPO IMPLEMENTING ------------------
  //To enter in chat connection
  @override
  void enterChatConnection({
    required bool isInChatConnection,
    required int receiverId,
  }) {
    _websocketService.enterInConnection(
      isInChat: isInChatConnection,
      receiverId: receiverId,
    );
  }

  //------------ GET MESSAGE REPO IMPLEMENTING ------------------
  //For getting message stream
  @override
  Stream getMessage() {
    //Getting the real time messages
    return _websocketService.stream;
  }

  //-------------- SEND MESSAGE REPO IMPLEMENTING ---------------
  //For sending a message to websocket
  @override
  void sendMessage(ChatModel chat) {
    _websocketService.sendMessage(chat);
  }

  //------------- GET SINK REPO IMPLEMENTING --------------------
  //For getting the websocket sink to add and close
  @override
  WebSocketSink getSink() {
    return _websocketService.sink;
  }

  //-------------- SEND INDICATION REPO IMPLEMENTING ------------------
  //For sending indication such as seen , typing , recording
  @override
  void sendIndication({
    required int receiverId,
    required String indication,
    required int senderId,
  }) {
    _websocketService.sendIndication(
      receiverId: receiverId,
      indication: indication,
      senderId: senderId,
    );
  }

  //--------------- EXIT FROM CHAT CONNECTION REPO IMPLEMENTING ------------
  //To exit from chat connection
  @override
  void exitFromChatConnection() {
    final Map<String, dynamic> exitData = {"exit": true};
    _websocketService.sink.add(jsonEncode(exitData));
  }
}
