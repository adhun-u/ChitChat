import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/domain/entities/message/message_entity.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:chitchat/features/home/data/datasource/chat_storage.dart';
import 'package:chitchat/features/home/domain/entities/unread_messages/seen_indication_entity.dart';
import 'package:chitchat/features/home/domain/repo/chat_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ChatRepoImple implements ChatRepo {
  //Baseurl
  final Dio _dio = Dio(BaseOptions(baseUrl: "$baseUrl/message"));
  //Creating an instance of ChatStorageDB for accessing chats
  final ChatStorageDB _chatStorage = ChatStorageDB();
  //----------- FETCH TEMPORARY MESSAGES REPO IMPLEMENTING -------------------
  //For fetching the messages from sender when receiver is not in online
  @override
  Future<Either<List<dynamic>?, ErrorMessageModel?>> fetchTempMessages({
    required String token,
  }) async {
    try {
      //Fetching token
      final String? token = await getToken();
      if (token == null) {
        return right(ErrorMessageModel(message: 'Something went wrong'));
      }
      //Sending a request to get all messages when current user is not in the connection
      final Response<dynamic> response = await _dio.get(
        "/tempMessages",
        options: Options(headers: getHeaders(token: token)),
      );
      //Checking if the response was success
      if (response.statusCode == 200) {
        //Parsing the data from response
        final List<dynamic> chats = response.data['messages'] as List<dynamic>;

        return left(chats);
      }
    } catch (e) {
      printDebug(e);
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //--------------- DELETE TEMP MESSAGES REPO IMPLEMENTING -------------
  //For deleting temporary messsages if receiver got all messages from sender
  @override
  Future<void> deleteTempMessages({required String token}) async {
    try {
      //Sending a request to delete every current user's temp messages
      await _dio.delete(
        "/tempMessages",
        options: Options(headers: getHeaders(token: token)),
      );
      return;
    } catch (e) {
      return;
    }
  }

  //-------------- FETCH SEEN INDICATION REPO IMPLEMENTING -----------------
  //For fetching seen info to know whether the receiver saw or did not
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> fetchSeenIndication({
    required String token,
    required int receiverId,
  }) async {
    try {
      //Sending a request to fetch seen indication when current user was not in app and receiver saw a message
      final Response<dynamic> response = await _dio.get(
        "/seenIndication?receiverId=$receiverId",
        options: Options(headers: getHeaders(token: token)),
      );
      //Checking whether the response was success or not
      if (response.statusCode == 200) {
        final SeenIndicationEntity seenIndicationEntity =
            SeenIndicationEntity.fromJson(response.data);
        await _chatStorage.changeSeenStatus(
          receiverId: receiverId,
          senderId: seenIndicationEntity.senderId,
        );
        return left(SuccessMessageModel(message: 'Success'));
      } else if (response.statusCode == 204) {
        return left(SuccessMessageModel(message: ''));
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is! String) {
        final MessageEntity messageEntity = MessageEntity.fromJson(
          e.response!.data,
        );

        return right(ErrorMessageModel(message: messageEntity.message));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //------------- DELETE SEEN INDICATION REPO IMPLEMENTING ---------------
  //For deleting seen info if sender got the seen indication from receiver
  @override
  Future<void> deleteSeenIndication({
    required String token,
    required int receiverId,
  }) async {
    try {
      //Sending a request to delete seen indication
      final Response<dynamic> response = await _dio.delete(
        "/seenIndication?receiverId=$receiverId",
        options: Options(headers: getHeaders(token: token)),
      );
      if (response.statusCode == 200) {}
    } catch (_) {
      return;
    }
  }

  //------------------- SAVE SEEN INFO REPO IMPLEMENTING ----------
  //For saving seen info if receiver saw the message
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> saveSeenInfo({
    required String token,
    required int senderId,
  }) async {
    try {
      //Sending a request to save seen info when current user seen receiver's message
      final Response<dynamic> response = await _dio.post(
        '/seenInfo?senderId=$senderId',
        options: Options(headers: getHeaders(token: token)),
      );

      //Checking if it return success response
      if (response.statusCode == 200) {
        return left(SuccessMessageModel(message: ''));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }

  //---------------- DELETE SINGLE CHAT REPO IMPLEMENTING ------------
  //For deleting single chat to not let receiver see
  @override
  Future<Either<SuccessMessageModel, ErrorMessageModel>> deleteSingleChat({
    required String chatId,
    required String token,
  }) async {
    try {
      final Response<dynamic> response = await _dio.delete(
        "/oneMessage?chatId=$chatId",
        options: Options(headers: getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return left(SuccessMessageModel(message: 'Deleted successfully'));
      }
    } catch (e) {
      printDebug(e);
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }
}
