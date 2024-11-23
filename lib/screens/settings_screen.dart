import 'package:budgia/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgia/models/transaction_model.dart';
import 'package:budgia/models/account_model.dart';
import 'package:budgia/services/storage_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:budgia/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _systemLockEnabled = false;
  String _selectedCurrency = 'USD';
  String _selectedLanguage = 'en';
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];

  final List<Map<String, dynamic>> _currencies = [
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
  ];

  static const String currencyPrefsKey = 'selected_currency';
  static const String languagePrefsKey = 'selected_language';

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'ml', 'name': 'മലയാളം'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedCurrency();
    _loadSystemLockState();
    _checkBiometricSupport();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString(currencyPrefsKey) ?? 'USD';
    });
  }

  Future<void> _loadSystemLockState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _systemLockEnabled = prefs.getBool('system_lock_enabled') ?? false;
    });
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      setState(() {
        _canCheckBiometrics = canCheckBiometrics && isDeviceSupported;
        _availableBiometrics = availableBiometrics;
      });

      print('Can check biometrics: $_canCheckBiometrics');
      print('Available biometrics: $_availableBiometrics');
      print('Device supported: $isDeviceSupported');
    } catch (e) {
      print('Error checking biometric support: $e');
      setState(() => _canCheckBiometrics = false);
    }
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString(languagePrefsKey) ?? 'en';
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0E21),
            const Color(0xFF0A0E21).withOpacity(0.8),
            Colors.indigo.withOpacity(0.3),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            localizations.settings,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader(localizations.security),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: SwitchListTile(
                title: Text(
                  localizations.systemLock,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  localizations.requirePassword,
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                value: _systemLockEnabled,
                onChanged: (value) async {
                  if (!_canCheckBiometrics) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Biometric authentication not available on this device'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final authenticated = await _localAuth.authenticate(
                      localizedReason: value
                          ? 'Please authenticate to enable system lock'
                          : 'Please authenticate to disable system lock',
                      options: const AuthenticationOptions(
                        stickyAuth: true,
                        biometricOnly: false,
                        useErrorDialogs: true,
                      ),
                    );

                    if (authenticated) {
                      setState(() => _systemLockEnabled = value);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('system_lock_enabled', value);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value
                              ? 'System lock enabled successfully'
                              : 'System lock disabled successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } on PlatformException catch (e) {
                    print('Authentication error: ${e.message}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Authentication error: ${e.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } catch (e) {
                    print('Generic error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('An error occurred: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                activeColor: Colors.blue.shade300,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(localizations.preferences),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: ListTile(
                title: Text(
                  localizations.currency,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${localizations.selected}: $_selectedCurrency',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                onTap: () => _showCurrencyPicker(),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: ListTile(
                title: Text(
                  localizations.language,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${localizations.selected}: ${_languages.firstWhere(
                    (lang) => lang['code'] == _selectedLanguage,
                    orElse: () => {'code': 'en', 'name': 'English'},
                  )['name']}',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                onTap: () => _showLanguagePicker(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(localizations.dataManagement),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.delete_forever, color: Colors.red.shade300),
                ),
                title: Text(
                  localizations.eraseAllData,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  localizations.cannotBeUndone,
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () => _showEraseConfirmationDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E21),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          title: Text(
            localizations.selectCurrency,
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _currencies.length,
              itemBuilder: (context, index) {
                final currency = _currencies[index];
                return ListTile(
                  title: Text(
                    '${currency['name']} (${currency['symbol']})',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: _selectedCurrency == currency['code']
                      ? Icon(Icons.check, color: Colors.blue.shade300)
                      : null,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(currencyPrefsKey, currency['code']);

                    setState(() => _selectedCurrency = currency['code']);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E21),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          title: Text(
            localizations.selectLanguage,
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                return ListTile(
                  title: Text(
                    language['name']!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: _selectedLanguage == language['code']
                      ? Icon(Icons.check, color: Colors.blue.shade300)
                      : null,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(languagePrefsKey, language['code']!);

                    setState(() => _selectedLanguage = language['code']!);

                    // Rebuild the entire app with new locale
                    if (context.mounted) {
                      final state =
                          context.findAncestorStateOfType<MyAppState>();
                      state?.setLocale(Locale(language['code']!));
                    }

                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showEraseConfirmationDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E21),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.red.withOpacity(0.2),
            ),
          ),
          title: Text(
            localizations.eraseAllData,
            style: const TextStyle(color: Colors.red),
          ),
          content: Text(
            localizations.cannotBeUndone,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Clear all Hive boxes
                await Hive.box<Transaction>(StorageService.transactionsBox)
                    .clear();
                await Hive.box<Account>(StorageService.accountsBox).clear();

                // Clear SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Reset the currency to default
                await prefs.setString(currencyPrefsKey, 'USD');
                setState(() => _selectedCurrency = 'USD');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been erased'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.of(context).pushReplacementNamed('/auth');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Erase All Data'),
            ),
          ],
        );
      },
    );
  }
}
