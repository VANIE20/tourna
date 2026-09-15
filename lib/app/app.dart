import 'package:flutter/material.dart';
import 'package:tourna/app/theme/app_theme.dart';
import 'package:tourna/features/navigation/presentation/main_shell.dart';

class TournaApp extends StatelessWidget {
  const TournaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOURNA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}
