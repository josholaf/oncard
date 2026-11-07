import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oncard/main.dart';

void main() {
  testWidgets('returning users land on the home screen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarded': true,
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(OncardApp(prefs: prefs));
    await tester.pump();
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Start studying'), findsOneWidget);
  });

  testWidgets('first launch shows onboarding', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(OncardApp(prefs: prefs));
    await tester.pump();
    expect(find.text('Welcome to Oncard'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
