import 'package:cardverse/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CardVerse starts on the splash screen', (tester) async {
    await tester.pumpWidget(const CardVerseApp());

    expect(find.text('CardVerse'), findsOneWidget);
    expect(find.text('Play cards with friends and bots'), findsOneWidget);
  });
}
