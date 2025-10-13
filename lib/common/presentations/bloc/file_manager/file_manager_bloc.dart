import 'package:bloc/bloc.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/common/data/repo_imple/file_manager_repo_imple.dart';
import 'package:dartz/dartz.dart';
part 'file_manager_event.dart';
part 'file_manager_state.dart';

class FileManagerBloc extends Bloc<FileManagerEvent, FileManagerState> {
  //Creating an instance of FileManagerRepoImple
  final FileManagerRepoImple _fileManagerRepoImple = FileManagerRepoImple();
  FileManagerBloc() : super(FileManagerInitial()) {
    //To delete a file from backend
    on<DeleteFileEvent>(deleteFile);
  }

  //-------------- DELETE FILE BLOC -----------------
  Future<void> deleteFile(
    DeleteFileEvent event,
    Emitter<FileManagerState> emit,
  ) async {
 final String? token = await getToken();
    if (token == null) {
      return emit(FileDeleteErrorState(errorMessage: 'Something went wrong'));
    }

    final Either<SuccessMessageModel?, ErrorMessageModel?> result =
        await _fileManagerRepoImple.deleteFile(
          token: token,
          filePublicId: event.publicId,
        );

    //Checking whether it returns success state or error state
    result.fold(
      //Success state
      (_) {
        return emit(FileDeleteSuccessState());
      },
      //Error state
      (errorModel) {
        if (errorModel != null) {
          return emit(FileDeleteErrorState(errorMessage: errorModel.message));
        }
      },
    );
  }
}
