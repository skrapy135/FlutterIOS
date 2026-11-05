import 'package:flutter_test/flutter_test.dart';
import 'package:cineverse_xuper_tv/main.dart';

void main() {
  testWidgets('CineVerse Flutter iOS smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CineVerseFlutterApp());
    expect(find.text('CINEVERSE'), findsOneWidget);
  });
}

