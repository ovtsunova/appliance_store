import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appliance_store/app/app.dart';

void main() {
  testWidgets('Приложение открывается', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ApplianceStoreApp(),
      ),
    );

    expect(find.byType(ApplianceStoreApp), findsOneWidget);
  });
}