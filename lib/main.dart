import "package:flutter/material.dart";

import "src/design/editorial_theme.dart";
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
      theme: EditorialTheme.buildTheme(),
      home: const AuthPage(),
    );
  }
}
