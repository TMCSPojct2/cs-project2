import 'package:flutter/material.dart';
import 'theme.dart';
import 'services/supabase_service.dart';
import 'services/language_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const NabihApp());
}

class NabihApp extends StatefulWidget {
  const NabihApp({super.key});

  @override
  State<NabihApp> createState() => _NabihAppState();
}

class _NabihAppState extends State<NabihApp> {
  final _lang = LanguageService.instance;

  @override
  void initState() {
    super.initState();
    _lang.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _lang.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NABIH - Smart University Assistant',
      debugShowCheckedModeBanner: false,
      theme: NabihTheme.lightTheme,
      locale: Locale(_lang.langCode),
      builder: (context, child) {
        return Directionality(
          textDirection: _lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
