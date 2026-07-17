import 'package:cardverse/core/widgets/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('navbar stays mounted and preserves branch state', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute(
          builder: (context, state, navigationShell) =>
              CardVerseNavigationShell(navigationShell: navigationShell),
          navigatorContainerBuilder: (context, navigationShell, children) =>
              CardVerseBranchContainer(
                currentIndex: navigationShell.currentIndex,
                children: children,
              ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const _CounterPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/games/computer',
                  builder: (context, state) => const _LabelPage('Play page'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/friends',
                  builder: (context, state) => const _LabelPage('Friends page'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/leaderboard',
                  builder: (context, state) => const _LabelPage('Ranks page'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const _LabelPage('Profile page'),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('increment')));
    await tester.pump();
    expect(find.text('Count: 1'), findsOneWidget);

    final navigationBarElement = tester.element(find.byType(NavigationBar));
    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      identical(
        navigationBarElement,
        tester.element(find.byType(NavigationBar)),
      ),
      isTrue,
    );
    expect(find.text('Play page'), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();
    expect(find.text('Friends page'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Count: 1'), findsOneWidget);
  });
}

class _CounterPage extends StatefulWidget {
  const _CounterPage();

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        key: const ValueKey('increment'),
        onPressed: () => setState(() => _count++),
        child: Text('Count: $_count'),
      ),
    );
  }
}

class _LabelPage extends StatelessWidget {
  const _LabelPage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text(label));
}
