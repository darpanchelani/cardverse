import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/widgets/app_error_view.dart';
import 'package:cardverse/core/widgets/app_loading_indicator.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/customization/widgets/theme_card_widget.dart';
import 'package:flutter/material.dart';

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AppServicesScope.of(context).customization;
    if (controller.catalog.isEmpty && !controller.isLoading) {
      controller.loadThemes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServicesScope.of(context);
    final controller = services.customization;
    final auth = AuthScope.maybeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customization'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${auth?.user?.coins ?? 0} coins',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (controller.isLoading) return const AppLoadingIndicator();
          if (controller.errorMessage != null && controller.catalog.isEmpty) {
            return AppErrorView(
              message: controller.errorMessage!,
              onRetry: controller.loadThemes,
            );
          }
          return RefreshIndicator(
            onRefresh: controller.loadThemes,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              children: [
                if (auth?.isAuthenticated != true)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: const Text(
                      'Login to unlock and save themes. Guest mode includes previews only.',
                    ),
                  ),
                for (final section in const [
                  ('Card Themes', 'cardTheme'),
                  ('Table Themes', 'tableTheme'),
                  ('Avatar Frames', 'avatarFrame'),
                ]) ...[
                  const SizedBox(height: 24),
                  Text(
                    section.$1,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.catalog[section.$2]?.length ?? 0,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 250,
                        ),
                    itemBuilder: (context, index) {
                      final item = controller.catalog[section.$2]![index];
                      return ThemeCardWidget(
                        item: item,
                        onPurchase: auth?.isAuthenticated == true
                            ? () => controller.purchase(item)
                            : null,
                        onEquip: auth?.isAuthenticated == true
                            ? () => controller.equip(item)
                            : null,
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
