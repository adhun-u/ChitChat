import 'package:chitchat/common/data/models/message_model.dart';
import 'package:dartz/dartz.dart';

abstract class FileManagerRepo {
  //----------- UPLOAD FILE REPO ------------
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
  });

  //------------ DELETE FILE REPO ------------------
  Future<Either<SuccessMessageModel?, ErrorMessageModel?>> deleteFile({
    required String token,
    required String filePublicId,
  });
}
