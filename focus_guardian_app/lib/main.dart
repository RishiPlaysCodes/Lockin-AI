import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/teacher_provider.dart';
import 'services/focus_monitor_service.dart';
import 'screens/splash_screen.dart';
import 'screens/teacher_select_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/group_session_screen.dart';
import 'screens/account_blocking_screen.dart';
import 'screens/focus_monitor_screen.dart';
import 'screens/analytics_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FocusGuardianApp());
}

class FocusGuardianApp extends StatelessWidget {
  const FocusGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => FocusMonitorService()),
      ],
      child: MaterialApp(
        title: 'Focus Guardian AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
        routes: {
          '/teacher-select': (context) => const TeacherSelectScreen(),
          '/friends': (context) => const FriendsScreen(),
          '/group-session': (context) => const GroupSessionScreen(),
          '/account-blocking': (context) => const AccountBlockingScreen(),
          '/focus-monitor': (context) => const FocusMonitorScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
        },
      ),
    );
  }
}
