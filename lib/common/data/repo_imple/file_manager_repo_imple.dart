import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/domain/repo/file_manager_repo.dart';
import 'package:chitchat/core/constants/api.dart';
import 'package:chitchat/core/helpers/get_headers.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class FileManagerRepoImple extends FileManagerRepo {
  //Base url
  final Dio _dio = Dio(BaseOptions(baseUrl: "$baseUrl/message/"));
  //For cancelling uploading process
  CancelToken _cancelToken = CancelToken();

  //For cancelling
  void cancel() {
    _cancelToken.cancel();
    //After cancelled , assinging cancel token instance to get remove previous token
    _cancelToken = CancelToken();
  }

  //----------- FILE UPLOADING REPO IMPLEMENTING ------------
  //For uploading media to backend to get downloading url
  @override
  Future<
    Either<
      ({String fileUrl, String fileType, String publicId})?,
      ErrorMessageModel?
    >
  >
  uploadFile({
    required String token,
    required String filePath,
    required String fileType,
  }) async {
    try {
      //Sending as form data
      final FormData fileInfo = FormData.fromMap({
        "type": fileType,
        "file": await MultipartFile.fromFile(filePath),
      });
      //Sending a request to upload this file
      final Response<dynamic> response = await _dio.post(
        'file',
        options: Options(headers: getHeaders(token: token)),
        data: fileInfo,
      );
      //Checking whether the response was success or not
      if (response.statusCode == 200) {
        final Map<String, dynamic> fileData =
            response.data as Map<String, dynamic>;
        //Getting the file url
        final String fileUrl = fileData["fileUrl"];
        //Type of the file
        final String type = fileData["type"];
        //Public id to identify the file
        final String publicId = fileData["publicId"];

        return left((fileUrl: fileUrl, fileType: type, publicId: publicId));
      }
    } catch (e) {
      return right(
        ErrorMessageModel(message: 'An error occured while sending'),
      );
    }
    return right(ErrorMessageModel(message: 'An error occured while sending'));
  }

  //------------- DELETE FILE REPO IMPLEMENTING ---------------------
  //For deleting the file from cloudinary and backend
  @override
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> deleteFile({
    required String token,
    required String filePublicId,
  }) async {
    try {
      //Sending a request to delete a file from backend
      final Response<dynamic> response = await _dio.delete(
        "file?publicId=$filePublicId",
      );
      //Checking whether the response was success or failure
      if (response.statusCode == 200) {
        return left(SuccessMessageModel(message: ''));
      }
    } catch (e) {
      return right(ErrorMessageModel(message: 'Something went wrong'));
    }
    return right(ErrorMessageModel(message: 'Something went wrong'));
  }
}
