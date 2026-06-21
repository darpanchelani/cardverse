import 'package:cardverse/features/customization/controllers/customization_controller.dart';
import 'package:cardverse/features/invites/controllers/invites_controller.dart';
import 'package:cardverse/features/notifications/controllers/notifications_controller.dart';
import 'package:cardverse/features/settings/controllers/settings_controller.dart';
import 'package:flutter/widgets.dart';

class AppServices {
  const AppServices({
    required this.notifications,
    required this.invites,
    required this.customization,
    required this.settings,
  });

  final NotificationsController notifications;
  final InvitesController invites;
  final CustomizationController customization;
  final SettingsController settings;
}

class AppServicesScope extends InheritedWidget {
  const AppServicesScope({
    required this.services,
    required super.child,
    super.key,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'AppServicesScope is missing above this context.');
    return scope!;
  }

  static AppServices? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppServicesScope>()?.services;

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) =>
      services != oldWidget.services;
}
