import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/components/search_field.dart';
import 'package:chitchat/common/presentations/components/shimmer_loading.dart';
import 'package:chitchat/core/constants/backgrounds.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/group/data/models/group_model.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:chitchat/features/group/presentations/components/search_group_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchGroupPage extends StatefulWidget {
  const SearchGroupPage({super.key});

  @override
  State<SearchGroupPage> createState() => _SearchGroupPageState();
}

class _SearchGroupPageState extends State<SearchGroupPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late final TextEditingController searchController = TextEditingController();
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      //For loading more search results when user scrolls
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        context.read<GroupBloc>().add(LoadMoreGroupSearchResutlEvent());
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: double.infinity.h,
      width: double.infinity.w,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          titleSpacing: 0,
          title: SizedBox(
            width: 360.w,
            child: SearchField(
              controller: searchController,
              onChanged: (text) {
                context.read<GroupBloc>().add(
                  SearchGroupsEvent(groupName: searchController.text.trim()),
                );
              },
              onClearButtonClicked: () {
                searchController.clear();
              },
              hintText: "Enter group name",
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<GroupBloc, GroupState>(
                buildWhen: (_, current) {
                  return current is SearchGroupLoadingState ||
                      current is SearchGroupSuccessState ||
                      current is SearchGroupErrorState;
                },
                builder: (context, groupState) {
                  if (groupState is SearchGroupLoadingState) {
                    return ShimmerLoading(
                      child: const _SearchGroupLoadingPage(),
                    );
                  }
                  if (groupState is SearchGroupSuccessState) {
                    if (groupState.groups.isEmpty) {
                      return _NoSearchResultPage(
                        query: searchController.text.trim(),
                      );
                    }
                    return BlocBuilder<GroupBloc, GroupState>(
                      buildWhen: (_, current) {
                        return (current
                                is LoadMoreGroupSearchResultErrorState) ||
                            (current
                                is LoadMoreGroupSearchResultLoadingState) ||
                            (current is LoadMoreGroupSearchResultSuccessState);
                      },
                      builder: (context, innerGroupState) {
                        return ListView.builder(
                          key: const PageStorageKey("storeGroupKey"),
                          itemCount:
                              groupState.groups.length +
                              (innerGroupState
                                      is LoadMoreGroupSearchResultLoadingState
                                  ? 1
                                  : 0),
                          itemBuilder: (context, index) {
                            if (index == groupState.groups.length) {
                              return Center(
                                child: LoadingIndicator(
                                  color: blueColor,
                                  strokeWidth: 2,
                                ),
                              );
                            }
                            final SearchGroupModel group =
                                groupState.groups[index];
                            return SearchGroupTile(
                              groupName: group.groupName,
                              groupImageUrl: group.groupImageUrl,
                              groupBio: group.groupBio,
                              groupAdminId: group.groupAdminUserId,
                              isCurrentUserAdded: group.isCurrentUserAdded,
                              isRequestSent: group.isRequestSent,
                              groupId: group.groupId,
                            );
                          },
                          physics: const BouncingScrollPhysics(),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchGroupLoadingPage extends StatelessWidget {
  const _SearchGroupLoadingPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.w, right: 10.w),
      child: Row(
        children: [
          CircleAvatar(radius: 35.r, backgroundColor: Colors.amber),
          10.horizontalSpace,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20.h,
                width: 150.w,
                decoration: BoxDecoration(color: Colors.amber),
              ),
              5.verticalSpace,
              Container(
                height: 15.h,
                width: 200.w,
                decoration: BoxDecoration(color: Colors.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoSearchResultPage extends StatelessWidget {
  final String query;
  const _NoSearchResultPage({required this.query});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Image.asset(
            noGroupResultBackgroud,
            height: 200.h,
            width: 200.h,
          ),
        ),
        5.horizontalSpace,
        SizedBox(
          height: 30.h,
          width: 400.w,
          child: Text(
            "No group named '$query'",
            style: getTitleMedium(
              context: context,
              fontweight: FontWeight.bold,
              color: lightGrey,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
