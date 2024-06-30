import 'package:currency_converter/screens/currency_converter_screen.dart';
import 'package:currency_converter/providers/currency_provider.dart';
import 'package:currency_converter/services/currency_rate_api.dart';
import 'package:flutter/material.dart';
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
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('CurrencyConverter Screen displays and converts currency correctly', (WidgetTester tester) async {
    when(mockCurrencyRateApi.getExchangeRate(any, any)).thenAnswer((_) async => 0.85);

    await tester.pumpWidget(createTestWidget(const CurrencyConverter()));

    // Verify initial state
    expect(find.text('Currency Calculator'), findsOneWidget);
    expect(find.text('1.0 USD corresponds'), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);

    await tester.pumpAndSettle();

    // Verify exchange rate is displayed after loading
    expect(find.text('0.8500 EUR'), findsOneWidget);

    // Enter value in fromController and check conversion
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pumpAndSettle();

    expect(find.byType(TextField).last, findsOneWidget);
    TextField toTextField = tester.widget(find.byType(TextField).last);
    expect(toTextField.controller?.text, '85.0000');

    // Change currency and verify updated exchange rate
    currencyProvider.setSelectedCurrencyFrom('EUR');
    currencyProvider.setSelectedCurrencyTo('USD');
    when(mockCurrencyRateApi.getExchangeRate(any, any)).thenAnswer((_) async => 1.18);
    await tester.pumpAndSettle();

    expect(find.text('1.0 EUR corresponds'), findsOneWidget);
    expect(find.text('1.18 USD'), findsOneWidget);
  });
}
