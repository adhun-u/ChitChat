import 'dart:convert';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/features/home/data/models/chat_model.dart';
import 'package:chitchat/features/home/domain/entities/chat/chat_entity.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketService {
  //Creating an instance of websocket channel for one to one chat
  late WebSocketChannel _channel;
  //Getting the stream of data
  Stream get stream => _channel.stream;

  //Getting the sink
  WebSocketSink get sink => _channel.sink;

  //Connecting the websocket channel
  Future<void> connectWebSocket(String websocketUrl) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(websocketUrl));
    } catch (e) {
      printDebug("Websocket connection error : $e");
    }
  }

  //For entering in chat connection
  void enterInConnection({required bool isInChat, required int receiverId}) {
    final Map<String, dynamic> connectionData = {
      "isInChat": isInChat,
      "receiverId": receiverId,
    };
    _channel.sink.add(jsonEncode(connectionData));
  }

  //For sending the message
  void sendMessage(ChatModel chat) {
    final Map<String, dynamic> message =
        ChatEntity(
          chatId: chat.chatId,
          senderId: chat.senderId,
          receiverId: chat.receiverId,
          senderName: chat.senderName,
          senderProfilePic: chat.senderProfilePic,
          senderBio: chat.senderBio,
          type: chat.type,
          textMessage: chat.textMessage,
          time: chat.time,
          imageUrl: chat.imageUrl,
          imageText: chat.imageText ?? "",
          voiceUrl: chat.voiceUrl,
          voiceDuration: chat.voiceDuration,
          audioUrl: chat.audioUrl,
          audioDuration: chat.audioDuration,
          audioTitle: chat.audioTitle,
          videoUrl: chat.videoUrl,
          videoDuration: chat.videoDuration,
          videoTitle: chat.videoTitle,
          isSeen: chat.isSeen,
          isRead: false,
          parentAudioDuration: chat.parentAudioDuration,
          parentMessageSenderId: chat.parentMessageSenderId,
          parentMessageType: chat.parentMessageType,
          parentText: chat.parentText,
          parentVoiceDuration: chat.parentVoiceDuration,
          repliedMessage: chat.repliedMessage,
        ).toJson();
    _channel.sink.add(jsonEncode(message));
  }

  //For sending indication (typing , seen , recording audio)
  void sendIndication({
    required int receiverId,
    required String indication,
    required int senderId,
  }) {
    final Map<String, dynamic> indicationMap = {
      "type": indication,
      "receiverId": receiverId,
      "senderId": senderId,
    };
    _channel.sink.add(jsonEncode(indicationMap));
  }
}
