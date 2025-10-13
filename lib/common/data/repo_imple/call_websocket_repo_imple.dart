import 'package:chitchat/common/application/websockets/call_websocket_service.dart';
import 'package:chitchat/common/data/models/call_communication_model.dart';
import 'package:chitchat/common/domain/repo/call_websocket_repo.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CallWebsocketRepoImple extends CallWebsocketRepo {
  final CallWebsocketService _service = CallWebsocketService();

  //--------------- CONNECT CALL WEBSOCKET REPO IMPLEMENTING -------------
  //For connecting websocket to send necessary details for webrtc for audio or video calling
  @override
  Future<void> connectCallWebSocket({
    required int currentUserId,
    required String currentUserProfilePic,
    required int oppositeUserId,
  }) async {
    await _service.connectCallSocket(
      "$callWebsocketUrl?currentUserId=$currentUserId&currentUserProfilePic=$currentUserProfilePic&oppositeUserId=$oppositeUserId",
    );
  }

  //------------- SEND DATA REPO IMPLEMENTING ----------------
  //For sending and receiving necessary data to establish webrtc connection
  @override
  Future<void> sendData({
    required String data,
    required int callerId,
    required int calleeId,
    required String type,
    required String callType,
    required String currentUsername,
  }) async {
    _service.sendData(
      CallCommunicationModel(
        callerId: callerId,
        calleeId: calleeId,
        type: type,
        data: data,
        callType: callType,
        callerName: currentUsername,
      ),
    );
  }

  //-------------- GET STREAM REPO IMPLEMENTING ---------------
  //For getting stream of data that is sending and receiving
  @override
  Stream getStream() {
    return _service.stream;
  }

  //--------------- GET SINK REPO IMPLEMENTING -------------------
  //For getting the sink to close the connection
  @override
  WebSocketSink getSink() {
    return _service.sink;
  }
}
