import 'package:chitchat/common/data/models/message_model.dart';
import 'package:dartz/dartz.dart';

abstract class GroupCallRepo {
  //-------- CREATE ROOM REPO ------------------
  Future<Either<String, ErrorMessageModel?>> createRoom({
    required String groupName,
    required String groupProfilePic,
    required String callType,
    required int userId,
    required String username,
    required String profilePic,
    required String groupId,
    required String token
  });
}
