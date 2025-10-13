import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//For getting another user's message notifications
Future<void> subscribeToUserMessageTopic({
  required int currentUserId,
  required int anotherUserId,
}) async {
  await _firebaseMessaging.subscribeToTopic(
    "userMessage$anotherUserId$currentUserId",
  );
}

//For muting or not getting another user's message notifications
Future<void> unSubscribeFromUserMessageTopic({
  required int currentUserId,
  required int anotherUserId,
}) async {
  await _firebaseMessaging.unsubscribeFromTopic(
    "userMessage$anotherUserId$currentUserId",
  );
}

//For muting calls notifications
Future<void> unSubscribeFromUserCallTopic({
  required int currentUserId,
  required int anotherUserId,
}) async {
  await _firebaseMessaging.unsubscribeFromTopic(
    "userCall$anotherUserId$currentUserId",
  );
}

//For unmuting calls notifications
Future<void> subscribeToUserCallTopic({
  required int currentUserId,
  required int anotherUserId,
}) async {
  await _firebaseMessaging.subscribeToTopic(
    "userCall$anotherUserId$currentUserId",
  );
}

//For getting group message notification
Future<void> subscribeToGroupMessageTopic({required String groupId}) async {
  await _firebaseMessaging.subscribeToTopic("groupMessage$groupId");
}

//For muting or not getting group message notifications
Future<void> unSubscribeFromGroupMessageTopic({required String groupId}) async {
  await _firebaseMessaging.unsubscribeFromTopic("groupMessage$groupId");
}

//For getting group call notifications
Future<void> subscribeToGroupCallTopic({required String groupId}) async {
  await _firebaseMessaging.subscribeToTopic("groupCall$groupId");
}

//For muting or not getting group call notifications
Future<void> unSubscribeFromGroupCallTopic({required String groupId}) async {
  await _firebaseMessaging.unsubscribeFromTopic("groupCall$groupId");
}
