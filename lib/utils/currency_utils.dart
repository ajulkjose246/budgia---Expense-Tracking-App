import 'package:shared_preferences/shared_preferences.dart';

class CurrencyUtils {
  static const String currencyPrefsKey = 'selected_currency';

  static final List<Map<String, dynamic>> currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'CHF', 'symbol': 'Fr', 'name': 'Swiss Franc'},
    {'code': 'HKD', 'symbol': 'HK\$', 'name': 'Hong Kong Dollar'},
    {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'UAE Dirham'},
    {'code': 'NZD', 'symbol': 'NZ\$', 'name': 'New Zealand Dollar'},
    {'code': 'ZAR', 'symbol': 'R', 'name': 'South African Rand'},
    {'code': 'RUB', 'symbol': '₽', 'name': 'Russian Ruble'},
    {'code': 'BRL', 'symbol': 'R\$', 'name': 'Brazilian Real'},
    {'code': 'KRW', 'symbol': '₩', 'name': 'South Korean Won'},
    {'code': 'MXN', 'symbol': 'Mex\$', 'name': 'Mexican Peso'},
    {'code': 'SAR', 'symbol': '﷼', 'name': 'Saudi Riyal'},
    {'code': 'THB', 'symbol': '฿', 'name': 'Thai Baht'},
    // ... copy your currency list here ...
  ];

  static Future<String> getSelectedCurrencyCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(currencyPrefsKey) ?? 'USD';
  }

  static Future<String> getSelectedCurrencySymbol() async {
    final code = await getSelectedCurrencyCode();
    final currency = currencies.firstWhere(
      (c) => c['code'] == code,
      orElse: () => currencies.first,
    );
    return currency['symbol'] as String;
  }

  static Map<String, dynamic> getCurrencyByCode(String code) {
    return currencies.firstWhere(
      (c) => c['code'] == code,
      orElse: () => currencies.first,
    );
  }
}
