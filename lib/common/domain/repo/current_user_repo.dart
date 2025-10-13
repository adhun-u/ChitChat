import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:dartz/dartz.dart';

abstract class CurrentUserRepo {
  //---------------- FETCH CURRENT USER REPO -------------------
  Future<Either<CurrentUserModel?, ErrorMessageModel?>> fetchCurrentUser({
    required String token,
  });

  //------ UPDATE CURRENT USER REPO ----------
  Future<Either<UpdatedUserDetailsModel, ErrorMessageModel>>
  updateCurrentUserDetails({
    required String token,
    required String imagePath,
    required String username,
    required String bio,
  });

  //------ UPDATE PASSWORD REPO ------------------
  Future<Either<SuccessMessageModel, ErrorMessageModel>> updatePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  });
}
