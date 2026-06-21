import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class NotificationBadgeWidget extends StatelessWidget {
  const NotificationBadgeWidget({
    required this.count,
    required this.child,
    super.key,
  });

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: count > 0,
    label: Text(count > 99 ? '99+' : '$count'),
    backgroundColor: AppColors.danger,
    child: child,
  );
}
