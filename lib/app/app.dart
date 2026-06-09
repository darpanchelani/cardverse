import 'package:cardverse/app/routes.dart';
import 'package:cardverse/app/theme.dart';
import 'package:flutter/material.dart';

class CardVerseApp extends StatelessWidget {
  const CardVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CardVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRoutes.router,
    );
  }
}
