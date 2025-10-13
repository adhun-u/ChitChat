import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/constants/icons.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/text_theme.dart';
import 'package:chitchat/features/home/presentations/blocs/friends/friends_bloc.dart';
import 'package:chitchat/features/home/presentations/blocs/user/user_bloc.dart';
import 'package:chitchat/features/home/presentations/pages/message_page.dart';
import 'package:chitchat/features/home/presentations/pages/requested_users_list_page.dart';
import 'package:chitchat/features/home/presentations/pages/send_request_users_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController = TextEditingController();
  late final ValueNotifier<int> _tabBarIndexNotifier = ValueNotifier(0);
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    //Tab controller
    _tabController = TabController(length: 3, vsync: this);
    //Fetching added users of current users
    context.read<UserBloc>().add(
      FetchAddedUsersWithLastMessageEvent(
        currentUserId: context.read<CurrentUserProvider>().currentUser.userId,
      ),
    );
    //Fetching current user's requests
    context.read<FriendsBloc>().add(
      FetchRequestedUsersEvent(shouldCallApi: true),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _tabBarIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 20.w,
        scrolledUnderElevation: 0,
        title: Text(
          'ChitChat',
          style: getTitleLarge(
            context: context,
            fontweight: FontWeight.bold,
            fontSize: 30.sp,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 75.h,

            child: TabBar(
              dividerColor: Colors.transparent,
              controller: _tabController,

              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.transparent,
              labelStyle: getTitleMedium(
                context: context,
                fontweight: FontWeight.bold,
                color: Colors.transparent,
              ),
              onTap: (index) {
                if (index == 0 && _tabBarIndexNotifier.value != 0) {
                  //Re-fetching friends
                  context.read<UserBloc>().add(
                    FetchAddedUsersWithLastMessageEvent(
                      currentUserId:
                          context
                              .read<CurrentUserProvider>()
                              .currentUser
                              .userId,
                    ),
                  );
                } else if (index == 1 && _tabBarIndexNotifier.value != 1) {
                  //Re-fetching requested users
                  context.read<FriendsBloc>().add(
                    FetchRequestedUsersEvent(shouldCallApi: true),
                  );
                } else if (index == 2 && _tabBarIndexNotifier.value != 2) {
                  //Re-fetching sent request users
                  context.read<FriendsBloc>().add(
                    FetchSentRequestEvent(shouldCallApi: true),
                  );
                }

                _tabBarIndexNotifier.value = index;

              },

              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              tabs: [
                Tab(
                  child: ValueListenableBuilder(
                    valueListenable: _tabBarIndexNotifier,
                    builder: (context, index, child) {
                      return Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: index == 0 ? lightBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (index != 0) const Icon(Icons.chat),
                              if (index != 0) 5.horizontalSpace,
                              Text(
                                'Messages',
                                style: getTitleSmall(
                                  context: context,
                                  fontweight: FontWeight.bold,
                                  color: index == 0 ? blueColor : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Tab(
                  child: BlocBuilder<FriendsBloc, FriendsState>(
                    buildWhen: (_, current) {
                      return current is FetchRequestedUsersSuccessState;
                    },
                    builder: (context, friendsState) {
                      return ValueListenableBuilder(
                        valueListenable: _tabBarIndexNotifier,
                        builder: (context, index, child) {
                          return Container(
                            height: 50.h,
                            width: 150.w,
                            decoration: BoxDecoration(
                              color:
                                  index == 1 ? lightBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (index != 1)
                                  const Icon(CupertinoIcons.clock),
                                if (index != 1) 5.horizontalSpace,
                                Text(
                                  'Requests',
                                  style: getTitleSmall(
                                    context: context,
                                    fontweight: FontWeight.bold,
                                    color: index == 1 ? blueColor : null,
                                  ),
                                ),
                                if (friendsState
                                        is FetchRequestedUsersSuccessState &&
                                    friendsState.requestedUsers.isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      5.horizontalSpace,
                                      CircleAvatar(
                                        radius: 3.r,
                                        backgroundColor: redColor,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Tab(
                  child: ValueListenableBuilder(
                    valueListenable: _tabBarIndexNotifier,
                    builder: (context, index, child) {
                      return Container(
                        height: 50.h,
                        width: 150.w,
                        decoration: BoxDecoration(
                          color: index == 2 ? lightBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (index != 2)
                              Consumer<ThemeProvider>(
                                builder: (context, theme, _) {
                                  return Image.asset(
                                    sendRequestIcon,
                                    height: 28.h,
                                    color:
                                        theme.isDark ? darkWhite2 : lightGrey,
                                  );
                                },
                              ),
                            if (index != 2) 5.horizontalSpace,
                            Text(
                              'Sent',
                              style: getTitleSmall(
                                context: context,
                                fontweight: FontWeight.bold,
                                color: index == 2 ? blueColor : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MessagePage(),
                RequestedUsersListPage(),
                SendRequestUsersListPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
