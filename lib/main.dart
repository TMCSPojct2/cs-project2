import 'package:flutter/material.dart';
import 'theme.dart';
import 'services/supabase_service.dart';
import 'services/local_notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await LocalNotificationService.init();
  runApp(const NabihApp());
}

class NabihApp extends StatelessWidget {
  const NabihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NABIH - Smart University Assistant',
      debugShowCheckedModeBanner: false,
      theme: NabihTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
