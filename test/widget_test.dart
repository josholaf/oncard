import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oncard/main.dart';

void main() {
  testWidgets('app builds and shows the home screen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(OncardApp(prefs: prefs));
    await tester.pump();
    expect(find.text('Oncard'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });
}
