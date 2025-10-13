import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/features/group/data/applications/group_web_socket_service.dart';
import 'package:chitchat/features/group/domain/repo/websocket_repo.dart';

class GroupWebSocketRepoImple extends GroupWebSocketRepo {
  final GroupWebSocketService _groupWebSocketService = GroupWebSocketService();

  bool _isSocketConnected = false;

  //--------------- CONNECT GROUP CHAT SOCKET REPO IMPLEMENTING ---------------
  //For connecting a websocket connection for sending indication such as typing , recording audio
  @override
  Future<void> connectGroupChatSocket({
    required String groupId,
    required int userId,
  }) async {
    await _groupWebSocketService.connectGroupChatSocket(
      "$groupChatSocketUrl?userId=$userId&groupId=$groupId",
      groupId,
    );

    _isSocketConnected = true;
  }

  //------------------  CLOSE GROUP CHAT SOCKET REPO IMPLEMENTING ------------------
  //For closing the group chat socket connect when user wants to leave
  @override
  Future<void> closeGroupChatSocketConnection() async {
    if (_isSocketConnected) {
      await _groupWebSocketService.groupChatSink.close();
      _isSocketConnected = false;
    }
  }

  //------------------- GET GROUP INDICATIONS REPO IMPLEMENTING ------------------
  //For getting group indication such as seen , typing , recording audio

  @override
  Stream<dynamic> getGroupIndications() {
    return _groupWebSocketService.groupChatStream;
  }

  //------------------ SEND GROUP INDICATION REPO IMPLEMENTING ----------------
  //For sending group indication to socket
  @override
  void sendGroupSeenIndication({
    required String indication,
    required String groupId,
    required int userId,
    String? indicationType,
  }) {
    //Sending indication
    _groupWebSocketService.sendGroupIndication(
      indication: indication,
      groupId: groupId,
      userId: userId,
      indicationType: indicationType,
    );
  }
}
