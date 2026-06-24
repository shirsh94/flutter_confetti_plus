import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders tabbed confetti examples', (tester) async {
    await tester.pumpWidget(const ConfettiSample());

    expect(find.text('Confetti Plus Examples'), findsOneWidget);
    expect(find.text('Controllers'), findsOneWidget);
    expect(find.text('Parties'), findsOneWidget);
    expect(find.text('Sprites'), findsOneWidget);
    expect(find.text('Emojis'), findsOneWidget);
    expect(find.text('Controller patterns'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Emojis'));
    await tester.pumpAndSettle();

    expect(find.text('Emoji overlay'), findsOneWidget);
    expect(find.text('Launch emoji confetti'), findsOneWidget);

    await tester.tap(find.text('Launch emoji confetti'));
    await tester.pump(const Duration(seconds: 3));
  });
}
