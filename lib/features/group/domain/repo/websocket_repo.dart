abstract class GroupWebSocketRepo {
   //---------- CONNECT GROUP CHAT SOCKET CONNECTION REPO ---------
  Future<void> connectGroupChatSocket({
    required String groupId,
    required int userId,
  });

  //------------- CLOSE GROUP CHAT SOCKET CONNECTION REPO -------------
  Future<void> closeGroupChatSocketConnection();

  //------------ SEND GROUP INDICATION REPO ------------
  void sendGroupSeenIndication({
    required String indication,
    required String groupId,
    required int userId,
  });

  //-------------- GET GROUP SOCKET REPO --------------
  Stream getGroupIndications();
}