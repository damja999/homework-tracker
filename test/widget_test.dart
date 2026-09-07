import 'package:flutter_test/flutter_test.dart';

import 'package:homework_tracker/main.dart';

void main() {
  testWidgets('shows splash screen before navigating home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HomeworkTrackerApp());

    expect(find.text('Homework Tracker'), findsOneWidget);
    expect(find.text('Welcome to Homework Tracker'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Homework Tracker'), findsNothing);
    expect(find.text('Welcome to Homework Tracker'), findsOneWidget);
  });
}
