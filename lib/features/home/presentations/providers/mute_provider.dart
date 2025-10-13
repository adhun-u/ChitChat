import 'package:chitchat/common/application/notifications/subscriptions.dart';
import 'package:chitchat/features/home/data/datasource/user_fun_db.dart';
import 'package:flutter/material.dart';

class MuteProvider extends ChangeNotifier {
  bool isMuted = false;
  final UserFunctionDB _userFunctionDB = UserFunctionDB();
  //Getting mute info to check if the specified user is muted
  Future<void> checkIfMuted({required int userId}) async {
    isMuted = await _userFunctionDB.getUserMuteInfo(userId: userId);
    notifyListeners();
  }

  //Muting specific user
  Future<void> muteOrUnmuteUser({
    required int userId,
    required int currentUserId,
  }) async {
    if (isMuted) {
      isMuted = false;
      notifyListeners();
      await subscribeToUserCallTopic(
        currentUserId: currentUserId,
        anotherUserId: userId,
      );
      await subscribeToUserMessageTopic(
        currentUserId: currentUserId,
        anotherUserId: userId,
      );
    } else {
      isMuted = true;
      notifyListeners();
      await unSubscribeFromUserMessageTopic(
        currentUserId: currentUserId,
        anotherUserId: userId,
      );
      await unSubscribeFromUserCallTopic(
        currentUserId: currentUserId,
        anotherUserId: userId,
      );
    }
  }
}
