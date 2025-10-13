import 'package:chitchat/features/home/data/models/chat_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebsocketRepo {
  //-------- CONNECT SOCKET REPO ---------
  Future<void> connectSocket({
    required int currentUserId,
    required String username,
    required String profilePic,
  });
  //-------- SEND MESSAGE REPO ----------
  void sendMessage(ChatModel chat);
  //-------- GET MESSAGE REPO ---------
  Stream getMessage();
  //--------- GET SINK REPO -----------
  WebSocketSink getSink();
  //--------- SEND INDICATION REPO -------
  void sendIndication({
    required int receiverId,
    required int senderId,
    required String indication,
  });
  //---------- ENTER IN CHAT CONNECTION REPO --------
  void enterChatConnection({
    required bool isInChatConnection,
    required int receiverId,
  });
  //---------- EXIT FROM CHAT CONNECTION REPO ----------
  void exitFromChatConnection();
}
