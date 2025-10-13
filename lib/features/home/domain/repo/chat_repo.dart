import 'package:chitchat/common/data/models/message_model.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepo {
  //--------- FETCH TEMP MESSAGES REPO ------------------
  Future<Either<List<dynamic>?, ErrorMessageModel?>> fetchTempMessages({
    required String token,
  });

  //-------- DELETING TEMP MESSAGES REPO -------------------
  Future<void> deleteTempMessages({required String token});

  //--------- FETCH SEEN INDICATION REPO ----------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> fetchSeenIndication({
    required String token,
    required int receiverId,
  });

  //----------- DELETE SEEN INDICATION REPO -------------
  Future<void> deleteSeenIndication({
    required String token,
    required int receiverId,
  });

  //----------- SAVE SEEN INFO REPO ------------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> saveSeenInfo({
    required String token,
    required int senderId,
  });

  //-------------  DELETING SINGLE CHAT REPO --------------
  Future<Either<SuccessMessageModel, ErrorMessageModel>> deleteSingleChat({
    required String chatId,
    required String token,
  });
}
