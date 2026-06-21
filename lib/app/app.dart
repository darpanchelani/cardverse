import 'package:cardverse/app/routes.dart';
import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/app/theme.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/invites/widgets/incoming_invite_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class CardVerseApp extends StatelessWidget {
  const CardVerseApp({
    super.key,
    this.progressController,
    this.multiplayerControllers,
    this.authController,
    this.appServices,
  });

  final ProgressController? progressController;
  final MultiplayerControllers? multiplayerControllers;
  final AuthController? authController;
  final AppServices? appServices;

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
          ? appServices == null
                ? null
                : (context, child) => _GlobalNoticeListener(
                    services: appServices!,
                    child: child ?? const SizedBox.shrink(),
                  )
          : (context, child) => _AchievementNoticeListener(
              controller: controller,
              child: appServices == null
                  ? child ?? const SizedBox.shrink()
                  : _GlobalNoticeListener(
                      services: appServices!,
                      child: child ?? const SizedBox.shrink(),
                    ),
            ),
    );
    final multiplayerApp = MultiplayerScope(
      controllers: multiplayer,
      child: app,
    );
    final progressApp = controller == null
        ? multiplayerApp
        : ProgressScope(controller: controller, child: multiplayerApp);
    final authenticatedApp = authController == null
        ? progressApp
        : AuthScope(controller: authController!, child: progressApp);
    return appServices == null
        ? authenticatedApp
        : AppServicesScope(services: appServices!, child: authenticatedApp);
  }
}

class _GlobalNoticeListener extends StatefulWidget {
  const _GlobalNoticeListener({required this.services, required this.child});

  final AppServices services;
  final Widget child;

  @override
  State<_GlobalNoticeListener> createState() => _GlobalNoticeListenerState();
}

class _GlobalNoticeListenerState extends State<_GlobalNoticeListener> {
  bool _showingInvite = false;

  @override
  void initState() {
    super.initState();
    widget.services.notifications.addListener(_onNotification);
    widget.services.invites.addListener(_onInvite);
  }

  @override
  void dispose() {
    widget.services.notifications.removeListener(_onNotification);
    widget.services.invites.removeListener(_onInvite);
    super.dispose();
  }

  void _onNotification() {
    final notification = widget.services.notifications.latestNotification;
    if (notification == null ||
        !widget.services.settings.notificationsEnabled ||
        !mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${notification.title}: ${notification.message}'),
        ),
      );
      widget.services.notifications.consumeLatest();
    });
  }

  void _onInvite() {
    final invite = widget.services.invites.latestIncomingInvite;
    if (invite == null || _showingInvite || !mounted) return;
    _showingInvite = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final multiplayer = MultiplayerScope.of(context);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => IncomingInviteDialog(
          invite: invite,
          onLater: () {
            widget.services.invites.keepForLater();
            Navigator.pop(dialogContext);
          },
          onDecline: () async {
            await widget.services.invites.declineInvite(invite);
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          onAccept: () async {
            final accepted = await widget.services.invites.acceptInvite(invite);
            final room = await multiplayer.room.joinRoom(accepted.roomCode);
            if (!dialogContext.mounted) return;
            Navigator.pop(dialogContext);
            if (room != null && mounted) {
              GoRouter.of(
                context,
              ).push('${AppRoutes.roomLobby}/${accepted.roomCode}');
            }
          },
        ),
      );
      _showingInvite = false;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
