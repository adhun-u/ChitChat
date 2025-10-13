import 'package:chitchat/common/data/models/current_user_model.dart';
import 'package:chitchat/common/presentations/components/custom_refresh_indicator.dart';
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/pages/error_page.dart';
import 'package:chitchat/common/presentations/pages/no_results_page.dart';
import 'package:chitchat/common/presentations/components/shimmer_loading.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/utils/device_size.dart';
import 'package:chitchat/core/utils/show_message.dart';
import 'package:chitchat/features/search/data/models/searched_user_model.dart';
import 'package:chitchat/features/search/presentations/blocs/search/search_bloc.dart';
import 'package:chitchat/common/presentations/components/search_field.dart';
import 'package:chitchat/features/search/presentations/components/search_result_loading.dart';
import 'package:chitchat/features/search/presentations/components/search_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late final TextEditingController _searchController;
  late final SearchBloc _searchBloc;
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        //Loading more search results
        context.read<SearchBloc>().add(LoadingMoreSearchResults());
      }
    });
  }

  @override
  void didChangeDependencies() {
    _searchBloc = context.read<SearchBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    //Clearing the search results
    _searchBloc.add(ClearSearchResultEvent());
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        toolbarHeight: context.height() * 0.1,
        centerTitle: true,
        title: SizedBox(
          height: context.height() * 0.06,
          width: context.width() * 0.9,
          child: SearchField(
            controller: _searchController,
            hintText: "Search friends",
            onClearButtonClicked: () {
              _searchController.clear();
            },
            onChanged: (text) {
              if (text.trim().isEmpty) return;
              //Searching users
              context.read<SearchBloc>().add(
                FetchSearchedUserEvent(username: text),
              );
            },
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 20),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocListener<SearchBloc, SearchState>(
            listenWhen: (_, current) {
              return (current is LoadMoreLoadingState) ||
                  (current is LoadMoreErrorState);
            },
            listener: (context, searchState) {
              if (searchState is LoadMoreErrorState) {
                showErrorMessage(context, "Something went wrong");
              }
            },
            child: const SizedBox(),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h),
              child: Consumer<CurrentUserProvider>(
                builder: (context, currentUserProvider, _) {
                  final CurrentUserModel currentUser =
                      currentUserProvider.currentUser;
                  if (currentUserProvider.currentUser.userId != 0) {
                    return BlocBuilder<SearchBloc, SearchState>(
                      buildWhen: (_, current) {
                        return (current is GetSearchedUsersErrorState) ||
                            (current is GetSearchedUsersLoadingState) ||
                            (current is GetSearchedUsersSuccessState);
                      },
                      builder: (context, searchState) {
                        if (searchState is GetSearchedUsersErrorState) {
                          return const Center(child: ErrorPage());
                        }
                        if (searchState is GetSearchedUsersLoadingState) {
                          return const ShimmerLoading(
                            child: SearchResultLoading(),
                          );
                        }
                        if (searchState is GetSearchedUsersSuccessState &&
                            searchState.searchedUsers.isEmpty &&
                            _searchController.text.trim().isNotEmpty) {
                          return Center(
                            child: NoResultsPage(
                              title: "User does not exist",
                              subtitle: "Please enter a valid username",
                            ),
                          );
                        }
                        if (searchState is GetSearchedUsersSuccessState) {
                          return CustomRefreshIndicator(
                            onRefresh: () async {
                              //Fetching current user
                              context
                                  .read<CurrentUserProvider>()
                                  .fetchCurrentUser();
                              //Fetching search result
                              if (_searchController.text.trim().isEmpty) {
                                return;
                              }
                              context.read<SearchBloc>().add(
                                FetchSearchedUserEvent(
                                  username: _searchController.text.trim(),
                                ),
                              );
                            },
                            child: BlocBuilder<SearchBloc, SearchState>(
                              buildWhen: (_, current) {
                                return (current is LoadMoreLoadingState) ||
                                    (current is LoadMoreErrorState) ||
                                    (current is LoadMoreSuccessState);
                              },
                              builder: (context, innerSearchState) {
                                return ListView.separated(
                                  controller: _scrollController,
                                  key: const PageStorageKey("search_result"),
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  itemCount:
                                      innerSearchState is LoadMoreLoadingState
                                          ? searchState.searchedUsers.length + 1
                                          : searchState.searchedUsers.length,
                                  itemBuilder: (context, index) {
                                    if (index ==
                                        searchState.searchedUsers.length) {
                                      return Center(
                                        child: LoadingIndicator(
                                          color: blueColor,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }
                                    final SearchedUserModel user =
                                        searchState.searchedUsers[index];
                                    return SearchTile(
                                      userId: user.userId,
                                      username: user.username,
                                      profilePic: user.profilePic,
                                      bio: user.bio,
                                      currentUserId: currentUser.userId,
                                      isAdded: user.isAdded,
                                      isRequested: user.isRequested,
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(height: 10);
                                  },
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
