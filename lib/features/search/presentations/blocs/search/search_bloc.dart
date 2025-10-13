import 'package:bloc/bloc.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/data/models/message_model.dart';
import 'package:chitchat/features/search/data/models/searched_user_model.dart';
import 'package:chitchat/features/search/data/repo_imple/search_repo_imple.dart';
import 'package:dartz/dartz.dart';
part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  //Creating an instance for SearchRepoImple
  final SearchRepoImple _searchRepoImple = SearchRepoImple();
  final List<SearchedUserModel> _searchResults = [];

  bool _fullyFetched = false;
  String _prevSearchedUsername = "";
  final int _limit = 40;
  int _currentPage = 1;
  SearchBloc() : super(SearchInitial()) {
    //To fetch searched users
    on<FetchSearchedUserEvent>(searchUser);
    //To clear search results
    on<ClearSearchResultEvent>((_, _) {
      _searchResults.clear();
    });

    //To add more search results
    on<LoadingMoreSearchResults>(_loadMore);
  }
  //----------- SEARCH USER BLOC -------------------
  Future<void> searchUser(
    FetchSearchedUserEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(GetSearchedUsersLoadingState());

    final String? token = await getToken();
    if (token != null) {
      _fullyFetched = false;
      _currentPage = 1;
      _prevSearchedUsername = event.username;
      final Either<List<SearchedUserModel>, ErrorMessageModel> result =
          await _searchRepoImple.searchUser(
            username: event.username,
            token: token,
            limit: _limit,
            page: 1,
          );
      //Checking whether it returns success state or error state
      result.fold(
        //Success state
        (users) {
          _searchResults.clear();
          _searchResults.addAll(users);
          if (users.length < _limit) {
            _fullyFetched = true;
          } else {
            _currentPage = _currentPage + 1;
          }
          return emit(
            GetSearchedUsersSuccessState(searchedUsers: _searchResults),
          );
        },
        //Error state
        (errorModel) {
          return emit(
            GetSearchedUsersErrorState(errorMessage: errorModel.message),
          );
        },
      );
    } else {
      return emit(
        GetSearchedUsersErrorState(errorMessage: 'Something went wrong'),
      );
    }
  }

  //---------- LOAD MORE BLOC -----------------
  void _loadMore(
    LoadingMoreSearchResults event,
    Emitter<SearchState> emit,
  ) async {
    if (!_fullyFetched) {
      emit(LoadMoreLoadingState());
      final String? token = await getToken();
      if (token == null) {
        return emit(LoadMoreErrorState());
      }

      final Either<List<SearchedUserModel>, ErrorMessageModel> result =
          await _searchRepoImple.searchUser(
            username: _prevSearchedUsername,
            token: token,
            page: _currentPage,
            limit: _limit,
          );

      //Checking whether it returns success state or error state
      result.fold(
        (users) {
          _searchResults.addAll(users);
          if (users.length < _limit) {
            _fullyFetched = true;
            emit(LoadMoreSuccessState());
          } else {
            _currentPage = _currentPage + 1;
          }

          return emit(
            GetSearchedUsersSuccessState(
              searchedUsers: List.from(_searchResults),
            ),
          );
        },
        (error) {
          emit(LoadMoreErrorState());
        },
      );
    }
  }
}
