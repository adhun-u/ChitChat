part of 'search_bloc.dart';

sealed class SearchState {}

final class SearchInitial extends SearchState {}

//Get searched users success state
final class GetSearchedUsersSuccessState extends SearchState {
  final List<SearchedUserModel> searchedUsers;
  GetSearchedUsersSuccessState({required this.searchedUsers});
}

//Get searched users error state
final class GetSearchedUsersErrorState extends SearchState {
  final String errorMessage;
  GetSearchedUsersErrorState({required this.errorMessage});
}

//Get searched users loading state
final class GetSearchedUsersLoadingState extends SearchState {}

//Null state
final class NullState extends SearchState {}

//Load more loading state
final class LoadMoreLoadingState extends SearchState {}

//Load more success state
final class LoadMoreSuccessState extends SearchState {}

//Load more error state
final class LoadMoreErrorState extends SearchState {}
