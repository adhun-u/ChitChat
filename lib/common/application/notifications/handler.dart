import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/repo_imple/call_websocket_repo_imple.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:chitchat/features/group/presentations/pages/call_page.dart';
import 'package:chitchat/features/home/presentations/pages/call_page.dart';
import 'package:chitchat/main.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/*
 For handling background notification , in app notification and handling notification
 when app is terminated
 */

//Creating an instance of FirebaseMessaging
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
late final WebSocketChannel _channel;
final CallWebsocketRepoImple _websocketRepoImple = CallWebsocketRepoImple();

class FCMPushNotification {
  static String? fcmToken = "";
  //Initializing the notifications
  Future<void> initNotifications() async {
    //Asking the permission to send notification
    await _firebaseMessaging.requestPermission();
    //Calling api to change token
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      await _changeToken(token: token);
    });
    try {
      //Getting the fcm token
      final String? token = await _firebaseMessaging.getToken();
      fcmToken = token;
      return;
    } catch (e) {
      log("FCM token error : $e");
      fcmToken = "";
      return;
    }
  }
}

//Handling the background notification
@pragma('vm:entry-point')
Future<void> firebaseBackgroundNotification(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await handleMessage(message, false);
  log("Background notification triggered");
}

//Handling messages when app is terminated
@pragma('vm:entry-point')
Future<void> terminatedAppNotification(RemoteMessage? message) async {
  await Firebase.initializeApp();
  //Sending notification
  if (message != null) {
    await handleMessage(message, true);
  }
}

Future<void> initPushNotifications() async {
  //Handling foreground messages
  FirebaseMessaging.onMessage.listen((message) async {
    log("Triggered notification in app");
    try {
      await handleMessage(message, false);
    } catch (e) {
      printDebug(e);
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    log("Triggered onMessageOpenedApp function");
    await Firebase.initializeApp();
    await handleMessage(message, false);
  });
}

//To handle chat message
Future<void> handleMessage(
  RemoteMessage message,
  bool isFromTerminatedState,
) async {
  final String? isFromMessageNotification =
      message.data['isMessageNotification'];
  final String? title = message.data['title'];
  final String? body = message.data['body'];
  final String? imageUrl = message.data['imageUrl'];
  final String? messageType = message.data['type'];
  final String? callType = message.data['callType'];
  final String? callerName = message.data['callerName'];
  final int? callerId = int.tryParse(message.data['callerId'] ?? "");
  final int? currentUserId = int.tryParse(message.data['currentUserId'] ?? "");
  final String? notificationId = message.data['id'];
  final String? groupId = message.data['groupId'];
  final String? notificationTime = message.data['notificationTime'];

  log("Data : ${message.data}");
  if (isFromMessageNotification == "true") {
    if (messageType == "text") {
      await _showNotification(
        title: title ?? "",
        body: body ?? "",
        imageUrl: imageUrl ?? "",
      );
    } else if (messageType == "image") {
      await _showNotification(
        title: title ?? "",
        body: "📷 Photo",
        imageUrl: imageUrl ?? "",
      );
    } else if (messageType == "audio") {
      await _showNotification(
        title: title ?? "",
        body: "🎧 Audio",
        imageUrl: imageUrl ?? "",
      );
    } else if (messageType == "voice") {
      await _showNotification(
        title: title ?? "",
        body: "🎤 Voice message",
        imageUrl: imageUrl ?? "",
      );
    }
  } else if (messageType == "call") {
    await _showCallNotification(
      imageUrl: imageUrl,
      callerId: callerId ?? 0,
      callerName: callerName ?? "",
      currentUserId: currentUserId ?? 0,
      callType: callType ?? "",
      isFromTerminatedState: isFromTerminatedState,
      notificationId: notificationId,
      notificationTime: notificationTime ?? "",
    );
  } else if (messageType == "groupCall") {
    await _showGroupCallNotification(
      callType: callType ?? "",
      groupImageUrl: imageUrl ?? "",
      groupName: title ?? "",
      notificationId: notificationId ?? "",
      groupId: groupId ?? "",
      isTerminated: isFromTerminatedState,
      notificationTime: notificationTime ?? "",
    );
  } else {
    await _showNotification(
      title: title ?? "",
      body: body ?? "",
      imageUrl: imageUrl ?? "",
    );
  }
}

//To show notification
Future<void> _showNotification({
  required String title,
  required String body,
  required String imageUrl,
}) async {
  try {
    //Showing notification
    if (await AwesomeNotifications().isNotificationAllowed()) {
      final Random random = Random();
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: random.nextInt(1000),
          channelKey: "chitchat_channel",
          body: body,
          title: title,
          hideLargeIconOnExpand: true,
          roundedLargeIcon: true,
          largeIcon: imageUrl,
          notificationLayout: NotificationLayout.Messaging,
          wakeUpScreen: true,
          displayOnBackground: true,
          displayOnForeground: true,
          criticalAlert: true,
          autoDismissible: true,
          fullScreenIntent: false,
        ),
      );
    }
  } catch (e, _) {
    return;
  }
}

//For showing group call notification
Future<void> _showGroupCallNotification({
  required String callType,
  required String groupImageUrl,
  required String groupName,
  required String groupId,
  required String notificationId,
  required bool isTerminated,
  required String notificationTime,
}) async {
  final CallKitParams params = CallKitParams(
    appName: "ChitChat",
    handle: callType == "groupAudio" ? "Audio calling" : "Video calling",
    avatar: groupImageUrl,
    duration: 30000,
    id: notificationId,
    nameCaller: groupName,
    textAccept: "Accept",
    textDecline: "Decline",
    type: callType == "groupAudio" ? 0 : 1,
    extra: {
      "callType": callType,
      "groupId": groupId,
      "isFromTerminatedState": isTerminated,
    },
    callingNotification: const NotificationParams(
      showNotification: true,
      subtitle: "Calling",
      isShowCallback: true,
    ),
    missedCallNotification: const NotificationParams(
      subtitle: "Missed call",
      showNotification: true,
      isShowCallback: false,
    ),
    android: const AndroidParams(
      ringtonePath: 'system_ringtone_default',
      isShowLogo: true,
      isImportant: true,
    ),
  );
  if (_isBeforeCurrentTime(notificationTime: notificationTime)) {
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  } else {
    await FlutterCallkitIncoming.showMissCallNotification(params);
  }
}

//For showing call notification
Future<void> _showCallNotification({
  required String? imageUrl,
  required int callerId,
  required String callerName,
  required int currentUserId,
  required String callType,
  required String? notificationId,
  required bool isFromTerminatedState,
  required String notificationTime,
}) async {
  final CallKitParams params = CallKitParams(
    appName: "ChitChat",
    handle: callType == "audio" ? "Audio calling" : "Video calling",
    avatar: imageUrl,
    duration: 30000,
    id: notificationId,
    nameCaller: callerName,
    textAccept: "Accept",
    textDecline: "Decline",
    extra: {
      "currentUserId": currentUserId,
      "callerId": callerId,
      "callType": callType,
      "isFromTerminatedState": isFromTerminatedState.toString(),
    },
    type: callType == "audio" ? 0 : 1,
    callingNotification: const NotificationParams(
      showNotification: true,
      subtitle: "Calling",
      isShowCallback: true,
    ),
    missedCallNotification: const NotificationParams(
      subtitle: "Missed call",
      showNotification: true,
      isShowCallback: true,
    ),
    android: const AndroidParams(
      ringtonePath: 'system_ringtone_default',
      isShowLogo: true,
      isImportant: true,
      isShowFullLockedScreen: false,
    ),
  );

  if (_isBeforeCurrentTime(notificationTime: notificationTime)) {
    await FlutterCallkitIncoming.showCallkitIncoming(params);

    //Connecting websocket connection
    await _connectedSocket(
      isTerminated: isFromTerminatedState,
      currentUserId: currentUserId,
      callerId: callerId,
      callType: callType,
      notificationId: notificationId ?? "",
      params: params,
    );
  } else {
    await FlutterCallkitIncoming.showMissCallNotification(params);
  }
}

/*For listening call event to know whether callee pressed accept button ,
 declined button or the notification is timed out*/
void startListenCallEvent() {
  FlutterCallkitIncoming.onEvent.listen((callEvent) async {
    final String notificationId = callEvent?.body['id'];
    final String? imageUrl = callEvent?.body['avatar'];
    final String callerName = callEvent?.body['nameCaller'];
    final Map<Object?, Object?> extra = callEvent?.body['extra'];
    final int? callerId = int.tryParse(extra['callerId'].toString());
    final int? currentUserId = int.tryParse(extra['currentUserId'].toString());
    final String callType = extra['callType'].toString();
    final bool? isFromTerminatedState = bool.tryParse(
      extra['isFromTerminatedState'].toString(),
    );
    final String? groupId = extra['groupId'] as String?;

    //----------- GROUP CALL ----------------
    if (callEvent?.event == Event.actionCallAccept &&
        (callType == "groupAudio" || callType == "groupVideo")) {
      //If user clicked accept button , then navigating to group call page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.push(
          CupertinoPageRoute(
            builder: (context) {
              //If the app is in terminated state , then fetching current user's details
              if (isFromTerminatedState ?? false) {
                context.read<CurrentUserProvider>().fetchCurrentUser();
              }
              return GroupCallPage(
                groupName: callerName,
                groupId: groupId ?? "",
                isAudioCall: callType == "groupAudio",
                groupProfilePic: "",
                callType: callType,
                isFromNotification: true,
              );
            },
          ),
        );
      });
      await FlutterCallkitIncoming.endCall(notificationId);
    }

    //------------ PEER TO PEER CALL --------------------
    if (callEvent?.event == Event.actionCallAccept &&
        (callType == "audio" || callType == "video")) {
      //If user clicked "Accept" button , then navigating to call page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.push(
          CupertinoPageRoute(
            builder: (context) {
              return CallPage(
                displayName: callerName,
                imageUrl: imageUrl ?? "",
                userId: callerId!,
                currentUserId: currentUserId!,
                currentUsername: "",
                currentUserProfilePic: "",
                isSomeCalling: true,
                isAudioCall: callType == "audio",
              );
            },
          ),
        );
      });
      await FlutterCallkitIncoming.endCall(notificationId);
    } else if (callEvent?.event == Event.actionCallCallback &&
        (callType == "audio" || callType == "video")) {
      //If user clicked the call back button then navigating to calling page to call back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.push(
          CupertinoPageRoute(
            builder: (context) {
              return CallPage(
                displayName: callerName,
                imageUrl: imageUrl ?? "",
                userId: callerId!,
                currentUserId: currentUserId!,
                currentUsername: "",
                currentUserProfilePic: "",
                isSomeCalling: false,
                isAudioCall: callType == "audio",
              );
            },
          ),
        );
      });
      await FlutterCallkitIncoming.endCall(notificationId);
    } else if (callEvent?.event == Event.actionCallTimeout ||
        callEvent?.event == Event.actionCallDecline &&
            (callType == "audio" || callType == "video")) {
      //Sending indication
      _sendIndication(
        isTerminated: isFromTerminatedState!,
        indication:
            callEvent?.event == Event.actionCallTimeout
                ? "CALL-END"
                : "DECLINE",
        currentUserId: currentUserId!,
        callerId: callerId!,
        callType: callType,
      );
    }
  });
}

//For connecting websocket server to send "Ringing" or "Declined" indication to caller
Future<void> _connectedSocket({
  required bool isTerminated,
  required int currentUserId,
  required int callerId,
  required String callType,
  required String notificationId,
  required CallKitParams params,
}) async {
  try {
    if (isTerminated) {
      _channel = WebSocketChannel.connect(
        Uri.parse("$websocketUrl/call/ws?currentUserId=$currentUserId"),
      );
      //For showing "Ringing" indication to callee
      final Map<String, dynamic> data = {
        "callerId": callerId,
        "calleeId": currentUserId,
        "type": "RINGING",
        "data": "",
        "callerName": "",
        "callType": callType,
      };
      _channel.sink.add(jsonEncode(data));

      _channel.stream.listen((socketMsg) async {
        final Map<String, dynamic> callData =
            jsonDecode(socketMsg) as Map<String, dynamic>;

        if (callData['type'] == "CALL-END") {
          //Removing the calling notification from the device if caller ended the call
          await FlutterCallkitIncoming.endCall(notificationId);
          //Showing missed call notification
          await FlutterCallkitIncoming.showMissCallNotification(params);
        }
      });
      //Then reusing existing websocket repo to connect and send data
    } else {
      await _websocketRepoImple.connectCallWebSocket(
        currentUserId: currentUserId,
        currentUserProfilePic: "",
        oppositeUserId: callerId,
      );
      await _websocketRepoImple.sendData(
        data: "",
        callerId: callerId,
        calleeId: currentUserId,
        type: "RINGING",
        callType: callType,
        currentUsername: "",
      );

      //Listening if the caller ended the call
      _websocketRepoImple.getStream().listen((socketMsg) async {
        final Map<String, dynamic> callData =
            jsonDecode(socketMsg) as Map<String, dynamic>;

        if (callData['type'] == "CALL-END") {
          try {
            //Then removing the calling notification from the device
            await FlutterCallkitIncoming.endCall(notificationId);
            //Showing missed call notification
            await FlutterCallkitIncoming.showMissCallNotification(params);
          } catch (e) {
            log(e.toString());
          }
        }
      });
    }
  } catch (e) {
    log('Socket connection error while in notification : $e');
  }
}

//For sending indications "Declined" or "Call-ended" to caller
Future<void> _sendIndication({
  required bool isTerminated,
  required String indication,
  required int currentUserId,
  required int callerId,
  required String callType,
}) async {
  if (isTerminated) {
    final Map<String, dynamic> data = {
      "callerId": callerId,
      "calleeId": currentUserId,
      "type": indication,
      "data": "",
      "callerName": "",
      "callType": callType,
    };
    _channel.sink.add(jsonEncode(data));
  } else {
    await _websocketRepoImple.sendData(
      data: "",
      callerId: callerId,
      calleeId: currentUserId,
      type: indication,
      callType: callType,
      currentUsername: "",
    );
  }
}

//For checking if the notification is before current time
bool _isBeforeCurrentTime({required String notificationTime}) {
  final DateTime? parsedNotificationTime = DateTime.tryParse(notificationTime);
  final DateTime currentTime = DateTime.now();

  //Checking if the call is before 30 seconds
  return !currentTime.isAfter(
    parsedNotificationTime?.add(Duration(seconds: 30)) ?? DateTime.now(),
  );
}

//For changing token
Future<void> _changeToken({required String token}) async {
  try {
    //Getting jwt token
    final String? jwtToken = await getToken();

    if (jwtToken != null) {
      final Response<dynamic> response = await Dio(
        BaseOptions(baseUrl: "$baseUrl/user"),
      ).put(
        "/changeFCMToken?fcmToken=$token",
        options: Options(headers: getHeaders(token: jwtToken)),
      );

      if (response.statusCode == 200) {
        log('FCM token changed');
      }
    }
  } catch (e) {
    log('FCM token updation error : $e');
  }
}
