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
                  builder: (context, state) => const _FriendsTestPage(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const _NestedFriendsPage(),
                    ),
                  ],
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
    expect(find.text('Count: 1'), findsNothing);

    await tester.pumpAndSettle();
    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();
    expect(find.text('Friends page'), findsOneWidget);
    expect(find.text('Play page'), findsNothing);
    expect(find.byType(AnimatedSlide), findsNothing);
    expect(find.byType(AnimatedOpacity), findsNothing);

    await tester.tap(find.byKey(const ValueKey('open-add-friend')));
    await tester.pumpAndSettle();
    expect(find.text('Add friend page'), findsOneWidget);
    expect(
      identical(
        navigationBarElement,
        tester.element(find.byType(NavigationBar)),
      ),
      isTrue,
    );

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Friends page'), findsOneWidget);

    await tester.tap(find.text('Ranks'));
    await tester.pump();
    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.tap(find.text('Friends'));
    await tester.pump();
    expect(find.text('Friends page'), findsOneWidget);
    expect(find.text('Ranks page'), findsNothing);
    expect(find.text('Profile page'), findsNothing);

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

class _FriendsTestPage extends StatelessWidget {
  const _FriendsTestPage();

  @override
  Widget build(BuildContext context) => Center(
    child: FilledButton(
      key: const ValueKey('open-add-friend'),
      onPressed: () => context.push('/friends/add'),
      child: const Text('Friends page'),
    ),
  );
}

class _NestedFriendsPage extends StatelessWidget {
  const _NestedFriendsPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add friend page')),
    body: const SizedBox.expand(),
  );
}
