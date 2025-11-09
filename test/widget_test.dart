import 'package:bookswap_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BookSwap app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BookSwapApp());

    // Verify that the app starts with authentication screen
    expect(find.text('BookSwap'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
