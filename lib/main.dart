import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

void main() {
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
