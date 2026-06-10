import 'package:cardverse/app/routes.dart';
import 'package:cardverse/app/theme.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/material.dart';

class CardVerseApp extends StatelessWidget {
  const CardVerseApp({
    super.key,
    this.progressController,
    this.multiplayerControllers,
  });

  final ProgressController? progressController;
  final MultiplayerControllers? multiplayerControllers;

  @override
  Widget build(BuildContext context) {
    final controller = progressController ?? ProgressController.maybeInstance;
    final multiplayer =
        multiplayerControllers ?? MultiplayerControllers.instance;
    final app = MaterialApp.router(
      title: 'CardVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRoutes.router,
      builder: controller == null
          ? null
          : (context, child) => _AchievementNoticeListener(
              controller: controller,
              child: child ?? const SizedBox.shrink(),
            ),
    );
    final multiplayerApp = MultiplayerScope(
      controllers: multiplayer,
      child: app,
    );
    return controller == null
        ? multiplayerApp
        : ProgressScope(controller: controller, child: multiplayerApp);
  }
}

class _AchievementNoticeListener extends StatefulWidget {
  const _AchievementNoticeListener({
    required this.controller,
    required this.child,
  });

  final ProgressController controller;
  final Widget child;

  @override
  State<_AchievementNoticeListener> createState() =>
      _AchievementNoticeListenerState();
}

class _AchievementNoticeListenerState
    extends State<_AchievementNoticeListener> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_showNotice);
  }

  @override
  void didUpdateWidget(covariant _AchievementNoticeListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_showNotice);
      widget.controller.addListener(_showNotice);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_showNotice);
    super.dispose();
  }

  void _showNotice() {
    final title = widget.controller.achievementNotice;
    if (title == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Achievement unlocked: $title!')),
        );
      widget.controller.consumeAchievementNotice();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
