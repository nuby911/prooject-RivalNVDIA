import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
<<<<<<< HEAD
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
=======
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
>>>>>>> 76fb896d9e8ee4e99b2d6c302ebc9ebf2d3e47a9
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'Rencana Harian',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
=======
      title: 'Rencana Hari Ini',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
>>>>>>> 76fb896d9e8ee4e99b2d6c302ebc9ebf2d3e47a9
      home: const HomeScreen(),
    );
  }
}
