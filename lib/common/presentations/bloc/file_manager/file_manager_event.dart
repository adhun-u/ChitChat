part of 'file_manager_bloc.dart';

sealed class FileManagerEvent {}

//To delete a file
final class DeleteFileEvent extends FileManagerEvent {
  final String publicId;

  DeleteFileEvent({required this.publicId});
}
