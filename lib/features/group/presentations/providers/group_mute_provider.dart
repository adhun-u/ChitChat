import 'package:chitchat/common/application/notifications/subscriptions.dart';
import 'package:chitchat/features/group/data/datasource/group_function_db.dart';
import 'package:flutter/material.dart';

class GroupMuteProvider extends ChangeNotifier {
  final GroupFunctionDb _groupFunctionDb = GroupFunctionDb();
  bool isGroupMuted = false;

  //For checking if the group is muted
  Future<void> checkIfMuted({required String groupId}) async {
    isGroupMuted = await _groupFunctionDb.getMuteInfo(groupId: groupId);
    notifyListeners();
  }

  //For muting or unmuting group notifications
  Future<void> muteOrUnmute({required String groupId}) async {
    if (isGroupMuted) {
      isGroupMuted = false;
      notifyListeners();
      await _groupFunctionDb.unMuteGroup(groupId: groupId);
      await subscribeToGroupCallTopic(groupId: groupId);
      await subscribeToGroupMessageTopic(groupId: groupId);
    } else {
      isGroupMuted = true;
      notifyListeners();
      await _groupFunctionDb.muteGroup(groupId: groupId);
      await unSubscribeFromGroupCallTopic(groupId: groupId);
      await unSubscribeFromGroupMessageTopic(groupId: groupId);
    }
  }
}
