part of 'file_manager_bloc.dart';

sealed class FileManagerState {}

final class FileManagerInitial extends FileManagerState {}

//File deleted success state
final class FileDeleteSuccessState extends FileManagerState {}

//File delete error state
final class FileDeleteErrorState extends FileManagerState {
  final String errorMessage;

  FileDeleteErrorState({required this.errorMessage});
}
