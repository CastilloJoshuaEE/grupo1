// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fifa/main.dart';

void main() {
  testWidgets('EduTask app starts with SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const EduTaskApp());
    
    // Verifica que la pantalla de splash está presente
    expect(find.text('EduTask'), findsOneWidget);
    expect(find.text('Gestión académica estudiantil'), findsOneWidget);
  });
}