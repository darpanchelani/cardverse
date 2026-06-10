import 'package:cardverse/app/theme.dart';
import 'package:cardverse/features/games/game_selection_screen.dart';
import 'package:cardverse/features/games/war/war_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('War opens from the game selection screen', (tester) async {
    final router = GoRouter(
      initialLocation: '/games/computer',
      routes: [
        GoRoute(
          path: '/games/:mode',
          builder: (context, state) => GameSelectionScreen(
            mode: state.pathParameters['mode'] ?? 'computer',
          ),
        ),
        GoRoute(path: '/war', builder: (context, state) => const WarScreen()),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
    );

    await tester.tap(find.text('War'));
    await tester.pumpAndSettle();

    expect(find.text('Win battles and collect all cards'), findsOneWidget);
  });

  testWidgets('Blackjack and locked games retain coming-soon feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const GameSelectionScreen(mode: 'computer'),
      ),
    );

    await tester.tap(find.text('Blackjack'));
    await tester.pump();
    expect(find.text('Blackjack game coming soon.'), findsOneWidget);

    await tester.tap(find.text('Rummy'));
    await tester.pump();
    expect(find.text('This game is coming soon.'), findsOneWidget);
  });
}
