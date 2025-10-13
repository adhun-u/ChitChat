import 'package:web_socket_channel/web_socket_channel.dart';

abstract class CallWebsocketRepo {
  //---------- CONNECT CALL WEBSOCKET REPO -------------------
  Future<void> connectCallWebSocket({
    required int currentUserId,
    required String currentUserProfilePic,
    required int oppositeUserId,
  });

  //---------- SEND SDP DETAILS REPO -----------------
  Future<void> sendData({
    required String data,
    required int callerId,
    required int calleeId,
    required String type,
    required String callType,
    required String currentUsername,
  });

  //------------- GET STREAM REPO ---------------
  Stream getStream();

  //------------- GET SINK REPO -------------
  WebSocketSink getSink();
}
