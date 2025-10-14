import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gardenme/app.dart';

void main() {
  testWidgets('Verifica se o app carrega e mostra o título "Meu Jardim"', (
    WidgetTester tester,
  ) async {
    // Constrói o app
    await tester.pumpWidget(const MyApp());

    // Verifica se o texto principal da home aparece
    expect(find.text('Meu Jardim'), findsOneWidget);

    // Verifica se os cards de plantas estão sendo renderizados
    expect(find.text('Morango'), findsOneWidget);
    expect(find.text('Babosa'), findsOneWidget);

    // Garante que o gradient e a estrutura básica renderizam
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
