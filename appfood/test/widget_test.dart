import 'package:flutter_test/flutter_test.dart';
import 'package:appfood/main.dart';

void main() {
  testWidgets('MyApp khởi tạo và hiển thị splash FastBite', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('FastBite'), findsOneWidget);
    expect(find.text('FOOD DELIVERY'), findsOneWidget);
    // StartupView: Future.delayed 4s — cần pump thời gian để không còn timer treo.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
