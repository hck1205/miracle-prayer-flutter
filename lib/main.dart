import "package:flutter/material.dart";

import "src/ui/auth_page.dart";

void main() {
  runApp(const MiraclePrayerApp());
}

class MiraclePrayerApp extends StatelessWidget {
  const MiraclePrayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Miracle Prayer",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8845A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F0E8),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFF2F241D),
          displayColor: const Color(0xFF2F241D),
        ),
      ),
      home: const AuthPage(),
    );
  }
}
