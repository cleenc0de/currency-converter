import 'dart:io';

import 'package:currency_converter/providers/currency_provider.dart';
import 'package:currency_converter/providers/currency_rate_api_provider.dart';
import 'package:currency_converter/screens/currency_converter_screen.dart';
import 'package:currency_converter/services/currency_rate_api.dart';
import 'package:currency_converter/widgets/currency_drop_down_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks([MockSpec<CurrencyRateApi>()])
import 'currency_converter_test.mocks.dart';

void main() {
  late MockCurrencyRateApi mockCurrencyRateApi;
  late CurrencyProvider currencyProvider;

  setUp(() {
    mockCurrencyRateApi = MockCurrencyRateApi();
    currencyProvider = CurrencyProvider('USD', 'EUR', 'EUR');
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CurrencyProvider>.value(value: currencyProvider),
        Provider<CurrencyRateApiProvider>.value(value: CurrencyRateApiProvider(mockCurrencyRateApi),),
      ],
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'Roboto'),
        home: child,
      ),
    );
  }

  testWidgets('CurrencyConverter Screen displays and converts currency correctly', (WidgetTester tester) async {
    // load font
    final roboto = File('test/fonts/Roboto-Regular.ttf');
    final content = ByteData.view(
        Uint8List.fromList(roboto.readAsBytesSync()).buffer);
    final fontLoader = FontLoader('Roboto')..addFont(Future.value(content));
    await fontLoader.load();

    when(mockCurrencyRateApi.getExchangeRate(any, any)).thenAnswer((_) async => 2.0);
    when(mockCurrencyRateApi.getExchangeRate("USD", "EUR")).thenAnswer((_) async => 0.85);
    when(mockCurrencyRateApi.getExchangeRate("JPY", "KRW")).thenAnswer((_) async => 8.5778);

    await tester.pumpWidget(createTestWidget(const CurrencyConverter()));

    // Verify initial state
    expect(find.text('Currency Calculator'), findsOneWidget);
    expect(find.text('1.0 USD corresponds'), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsExactly(4));

    // Verify exchange rate is displayed after loading
    expect(find.text('0.85 EUR'), findsOneWidget);

    // Enter value in fromController and check conversion
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pumpAndSettle();

    expect(find.byType(TextField).at(2), findsOneWidget);
    TextField toTextField = tester.widget(find.byType(TextField).at(2));
    expect(toTextField.controller?.text, '85.0000');

    // Change currency and verify updated exchange rate

    await tester.tap(find.byType(CurrencyDropDownWidget).first);
    await tester.pumpAndSettle();
    final jpyEntry = find.text('JPY').last;
    await tester.ensureVisible(jpyEntry);
    await tester.dragUntilVisible(
      jpyEntry, // what you want to find
      find.byType(SingleChildScrollView), // widget you want to scroll
      const Offset(0, -50), // delta to move
    );
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('qwe.png'));
    await tester.tap(jpyEntry);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CurrencyDropDownWidget).last);
    await tester.pumpAndSettle();
    
    final krwEntry = find.text('KRW').last;
    await tester.tap(krwEntry);
    await tester.pumpAndSettle();

    //await expectLater(find.byType(CurrencyConverter), matchesGoldenFile('qwe.png'));

    expect(find.text('1.0 JPY corresponds'), findsOneWidget);
    expect(find.text('8.5778 KRW'), findsOneWidget);
  });
}
