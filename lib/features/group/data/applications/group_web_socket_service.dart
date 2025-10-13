import 'dart:convert';
import 'dart:developer';

import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GroupWebSocketService {
  //Creating an instance of websocket channel for group chat
  late WebSocketChannel _groupChatChannel;
  //Getting the stream data of group chat
  Stream get groupChatStream => _groupChatChannel.stream;

  //Getting sink to close and add for group chat
  WebSocketSink get groupChatSink => _groupChatChannel.sink;

  //For connecting websocket for group chat to show typing and recording audio
  Future<void> connectGroupChatSocket(
    String websocketUrl,
    String groupId,
  ) async {
    try {
      _groupChatChannel = WebSocketChannel.connect(Uri.parse(websocketUrl));
    } catch (e) {
      printDebug('Group socket connection error : $e');
    }
  }

  //For sending group indication (typing , seen , recording audio)
  void sendGroupIndication({
    required String indication,
    required String groupId,
    required int userId,
    String? indicationType,
  }) {
    try {
      final Map<String, dynamic> indicationMap = {
        "indication": indication,
        "groupId": groupId,
        "senderId": userId,
        "indicationType": indicationType ?? "",
      };
      _groupChatChannel.sink.add(jsonEncode(indicationMap));
    } catch (e) {
      log('Tried to sent indication : $e');
    }
  }
}
