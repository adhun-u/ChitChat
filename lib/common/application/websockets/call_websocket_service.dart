import 'dart:convert';
import 'dart:developer';
import 'package:chitchat/common/data/models/call_communication_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CallWebsocketService {
  late WebSocketChannel _channel;

  //Getting stream data
  Stream get stream => _channel.stream;

  //Getting sink to add and disconnect the connection
  WebSocketSink get sink => _channel.sink;

  //For connecting websocket for sending session description
  Future<void> connectCallSocket(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
    } catch (e) {
      log('Conn error : $e');
    }
  }

  //For sending necessary data for webrtc to establish a connection to communication
  void sendData(CallCommunicationModel details) {
    final Map<String, dynamic> data = {
      "callerId": details.callerId,
      "calleeId": details.calleeId,
      "type": details.type,
      "data": details.data,
      "callerName": details.callerName,
      "callType": details.callType,
    };
    _channel.sink.add(jsonEncode(data));
  }
}
