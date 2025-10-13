// ignore_for_file: use_build_context_synchronously
import 'package:chitchat/common/presentations/components/loading_indicator.dart';
import 'package:chitchat/common/presentations/pages/error_page.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/features/group/presentations/pages/group_list_page.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:chitchat/features/home/presentations/pages/tab_page.dart';
import 'package:chitchat/features/navigations/presentations/components/bottom_nav.dart';
import 'package:chitchat/features/search/presentations/pages/search_page.dart';
import 'package:chitchat/features/settings/presentations/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = [
    TabPage(),
    SearchPage(),
    GroupListPage(),
    SettingsPage(),
  ];
  @override
  void initState() {
    super.initState();

    //Fetching current user's details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCurrentUser();
    });
  }

  void _fetchCurrentUser() async {
    //Fetching current user
    await context.read<CurrentUserProvider>().fetchCurrentUser(
      onCurrentUserFetched: (currentUser) {
        //After fetching current user's details , connecting websocket server
        context.read<ChatBloc>().add(
          ConnectSocketEvent(
            currentUserId: currentUser.userId,
            profilepic: currentUser.profilePic,
            username: currentUser.username,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<CurrentUserProvider>(
          builder: (context, currentUserProvider, _) {
            return currentUserProvider.fetchingCurrentDetailsLoading
                ? Center(
                  child: LoadingIndicator(color: blueColor, strokeWidth: 2),
                )
                : currentUserProvider.errorMessage == null
                ? ValueListenableBuilder(
                  valueListenable: bottomNavIndexNotifier,
                  builder: (context, bottomNavIndex, child) {
                    return _pages[bottomNavIndex];
                  },
                )
                : ErrorPage(
                  onTryAgain: () async {
                    //Re-fetching current user
                    await context
                        .read<CurrentUserProvider>()
                        .fetchCurrentUser();
                  },
                  showTryAgain: true,
                );
          },
        ),
        bottomNavigationBar: const BottomNav(),
      ),
    );
  }
}
