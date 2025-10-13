part of 'search_bloc.dart';

sealed class SearchEvent {}

//for fetching searched users
final class FetchSearchedUserEvent extends SearchEvent {
  final String username;
  FetchSearchedUserEvent({required this.username});
}

//For clearing search result
final class ClearSearchResultEvent extends SearchEvent {}

//For loading more search results
final class LoadingMoreSearchResults extends SearchEvent {}
