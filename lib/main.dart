import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/language_controller.dart';
import 'services/local_notification_service.dart';
import 'data/role_context.dart';
import 'services/profile_service.dart';
import 'theme/app_theme.dart';
import 'screens/admin_event_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/create_announcement_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/faculty_home_screen.dart';
import 'screens/faculty_notify_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/gpa_screen.dart';
import 'screens/login_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/student_home_screen.dart';
import 'screens/visitor_home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/welcome_screen.dart';

const _supabaseUrl = 'https://zejokfqrvqelwruwzrbc.supabase.co';
const _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inplam9rZnFydnFlbHdydXd6cmJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2NzA2NTcsImV4cCI6MjA5NjI0NjY1N30.HD7l0SofNVZ2XH9mxRQ4m4yj5IQCwi_5koST49bLiI4';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageController.load();
  try { await LocalNotificationService.instance.init(); } catch (_) {}
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    final profile = await ProfileService.instance.ensureProfileForCurrentUser();
    if (profile != null) {
      setActiveSessionProfile(
        SessionProfile(
          name: profile['full_name'] as String? ?? 'User',
          email: profile['email'] as String? ?? user.email ?? '',
          universityId: profile['university_id'] as String? ?? '',
          role: userRoleFromValue(profile['role']),
        ),
      );
    }
  }

  runApp(const NabihApp());
}

class NabihApp extends StatelessWidget {
  const NabihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LanguageController.isArabic,
      builder: (context, _, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NABIH',
          theme: AppTheme.light(),
          locale: LanguageController.isArabic.value ? const Locale('ar', 'SA') : const Locale('en', 'US'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'SA'),
          ],
          initialRoute: '/',
          builder: (context, child) => Directionality(
            textDirection: LanguageController.direction,
            child: child ?? const SizedBox.shrink(),
          ),
          routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/auth': (context) => const AuthScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/verify-email': (context) => const EmailVerificationScreen(),
        '/student-home': (context) => const StudentHomeScreen(),
        '/faculty-home': (context) => const FacultyHomeScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
        '/visitor-home': (context) => const VisitorHomeScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/gpa': (context) => const GpaScreen(),
        '/navigation': (context) => const NavigationScreen(),
        '/announcement': (context) => const CreateAnnouncementScreen(),
        '/faculty-notify': (context) => const FacultyNotifyScreen(),
        '/admin-event': (context) => const AdminEventScreen(),
        '/admin-users': (context) => const AdminUsersScreen(),
        '/assistant': (context) => const AssistantScreen(),
        '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
