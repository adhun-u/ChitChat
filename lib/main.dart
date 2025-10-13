import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chitchat/common/application/notifications/handler.dart';
import 'package:chitchat/common/application/database_service.dart';
import 'package:chitchat/common/data/datasource/token_db.dart';
import 'package:chitchat/common/presentations/bloc/file_manager/file_manager_bloc.dart';
import 'package:chitchat/common/presentations/bloc/request/request_bloc.dart';
import 'package:chitchat/common/presentations/providers/audio_provider.dart';
import 'package:chitchat/common/presentations/providers/current_user_provider.dart';
import 'package:chitchat/common/presentations/providers/download_provider.dart';
import 'package:chitchat/common/presentations/providers/theme_provider.dart';
import 'package:chitchat/core/helpers/debug_printer.dart';
import 'package:chitchat/core/themes/colors.dart';
import 'package:chitchat/core/themes/dark_theme.dart';
import 'package:chitchat/core/themes/light_theme.dart';
import 'package:chitchat/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chitchat/common/presentations/providers/time_provider.dart';
import 'package:chitchat/features/auth/presentation/pages/login_page.dart';
import 'package:chitchat/common/presentations/providers/chat_function_provider.dart';
import 'package:chitchat/common/presentations/providers/chat_style_provider.dart';
import 'package:chitchat/features/group/data/datasource/group_function_db.dart';
import 'package:chitchat/features/group/presentations/blocs/group/group_bloc.dart';
import 'package:chitchat/features/group/presentations/blocs/group_call/group_call_bloc.dart';
import 'package:chitchat/features/group/presentations/blocs/group_chat/group_chat_bloc.dart';
import 'package:chitchat/features/group/presentations/providers/call_provider.dart';
import 'package:chitchat/features/group/presentations/providers/group_mute_provider.dart';
import 'package:chitchat/features/home/data/datasource/user_fun_db.dart';
import 'package:chitchat/features/home/presentations/blocs/call/call_bloc.dart';
import 'package:chitchat/features/home/presentations/blocs/chat/chat_bloc.dart';
import 'package:chitchat/features/home/presentations/blocs/friends/friends_bloc.dart';
import 'package:chitchat/features/home/presentations/blocs/user/user_bloc.dart';
import 'package:chitchat/features/home/presentations/providers/call_provider.dart';
import 'package:chitchat/features/home/presentations/providers/mute_provider.dart';
import 'package:chitchat/features/navigations/presentations/pages/main_screen.dart';
import 'package:chitchat/features/search/presentations/blocs/search/search_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

//For navigating to new screen when notification is being triggered
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  try {
    final WidgetsBinding widgetsBinding =
        WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    //Getting jwt token from database
    final String? token = await getToken();
    //Loading .env variables
    await dotenv.load(fileName: 'lib/core/.env');
    //Initializing databases
    await DatabaseService.initDatabase();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    GroupFunctionDb.pref = pref;
    UserFunctionDB.pref = pref;
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    //Removing splash screen
    FlutterNativeSplash.remove();
    runApp(RootApp(token: token));
    await _notificationInitialization();
  } catch (e, stackTrace) {
    printDebug('Stack trace : $stackTrace');
    printDebug("Catch error : $e");
  }
}

class RootApp extends StatelessWidget {
  final String? token;
  const RootApp({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      //Registering blocs
      providers: _registerBlocs(context),
      child: MultiProvider(
        //Registering providers
        providers: _registerProvider(context, token),
        child: ScreenUtilInit(
          designSize: const Size(439.3, 933.1),
          ensureScreenSize: true,
          splitScreenMode: true,
          builder: (context, _) {
            return Consumer<ThemeProvider>(
              builder: (context, theme, _) {
                return MaterialApp(
                  navigatorKey: navigatorKey,
                  theme:
                      theme.isDark ? darkTheme(context) : lightTheme(context),
                  themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
                  darkTheme: darkTheme(context),
                  home: token != null ? const MainScreen() : const LoginPage(),
                  debugShowCheckedModeBanner: false,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

//Initializing firebase and other notification
Future<void> _notificationInitialization() async {
  try {
    //Initializing firebase for pushing notification
    await Firebase.initializeApp();
    //Initializing push notification
    await FCMPushNotification().initNotifications();
    await initPushNotifications();
    await AwesomeNotifications()
        .initialize('resource://drawable/ic_notification_logo', [
          NotificationChannel(
            channelKey: "chitchat_channel",
            channelName: "ChitChat Notifications",
            channelDescription: "Chat notifications",
            importance: NotificationImportance.Max,
            ledColor: whiteColor,
            defaultColor: whiteColor,
            criticalAlerts: true,
            playSound: true,
          ),
        ], debug: true);
    //Requesting permission to send notification
    await AwesomeNotifications().requestPermissionToSendNotifications();
    //Background notification
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundNotification);
    //Notification when app is terminated
    final RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      await terminatedAppNotification(message);
    }
    //For listening the events that user clickes when call notification is triggered
    startListenCallEvent();
  } catch (e, stackTrace) {
    printDebug('Notification stack trace $stackTrace');
    printDebug("Notification error : $e");
  }
}

//Registering all providers
List<SingleChildWidget> _registerProvider(BuildContext context, String? token) {
  return [
    ChangeNotifierProvider(create: (context) => ThemeProvider(), lazy: false),
    ChangeNotifierProvider(create: (context) => TimeProvider()),
    ChangeNotifierProvider(
      create: (context) => CurrentUserProvider(token: token),
    ),
    ChangeNotifierProvider(create: (context) => DownloadProvider()),
    ChangeNotifierProvider(create: (context) => AudioProvider()),
    ChangeNotifierProvider(
      create: (context) => ChatStyleProvider(),
      lazy: false,
    ),
    ChangeNotifierProvider(
      create: (context) => ChatFunctionProvider(),
      lazy: false,
    ),
    ChangeNotifierProvider(create: (context) => CallProvider()),
    ChangeNotifierProvider(create: (context) => GroupCallProvider()),
    ChangeNotifierProvider(create: (context) => GroupMuteProvider()),
    ChangeNotifierProvider(create: (context) => MuteProvider()),
  ];
}

//Registering all blocs
List<SingleChildWidget> _registerBlocs(BuildContext context) {
  return [
    BlocProvider(create: (context) => AuthBloc()),
    BlocProvider(create: (context) => SearchBloc()),
    BlocProvider(create: (context) => RequestBloc()),
    BlocProvider(create: (context) => FriendsBloc()),
    BlocProvider(create: (context) => UserBloc()),
    BlocProvider(create: (context) => ChatBloc()),
    BlocProvider(create: (context) => FileManagerBloc()),
    BlocProvider(create: (context) => GroupBloc()),
    BlocProvider(create: (context) => GroupChatBloc()),
    BlocProvider(create: (context) => CallBloc()),
    BlocProvider(create: (context) => GroupCallBloc()),
  ];
}
