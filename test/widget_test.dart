import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitality/app.dart';

void main() {
  testWidgets('App renders', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ManyBoostApp()),
    );
    expect(find.text('ManyBoost'), findsOneWidget);
  });
}
