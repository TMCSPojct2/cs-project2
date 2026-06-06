import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/role_context.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/welcome');
        return;
      }
      final profile = await ProfileService.instance.ensureProfileForCurrentUser();
      if (!mounted) return;
      if (profile == null) {
        await Supabase.instance.client.auth.signOut();
        clearActiveSessionProfile();
        Navigator.pushReplacementNamed(context, '/auth');
        return;
      }
      final role = userRoleFromValue(profile['role']);
      setActiveSessionProfile(
        SessionProfile(
          name: profile['full_name'] as String? ?? 'User',
          email: profile['email'] as String? ?? user.email ?? '',
          universityId: profile['university_id'] as String? ?? '',
          role: role,
        ),
      );
      Navigator.pushReplacementNamed(context, role.homeRoute, arguments: role);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandMark(size: 126),
              const SizedBox(height: 26),
              Text('NABIH', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 44, color: AppColors.primaryDark)),
              const SizedBox(height: 10),
              SizedBox(
                width: 320,
                child: Text(
                  'Smart University Assistant',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 34),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
