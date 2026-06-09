import 'package:cardverse/app/theme.dart';
import 'package:cardverse/features/games/high_card/high_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('draw button plays a High Card round', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: const HighCardScreen()),
    );

    expect(find.text('Tap Draw Cards to start'), findsOneWidget);
    expect(find.text('CV'), findsNWidgets(2));

    await tester.ensureVisible(find.text('Draw Cards'));
    await tester.tap(find.text('Draw Cards'));
    await tester.pumpAndSettle();

    expect(find.text('Tap Draw Cards to start'), findsNothing);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('CV'), findsNothing);
  });
}
