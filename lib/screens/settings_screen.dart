import 'package:budgia/auth/auth_page.dart';
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
import 'package:budgia/utils/currency_utils.dart';
import 'package:budgia/utils/language_utils.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';

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
  String _userName = '';
  String _appVersion = '';

  static const String currencyPrefsKey = 'selected_currency';
  static const String languagePrefsKey = 'selected_language';
  static const String userNamePrefsKey = 'user_name';

  @override
  void initState() {
    super.initState();
    _loadSavedCurrency();
    _loadSystemLockState();
    _checkBiometricSupport();
    _loadSavedLanguage();
    _loadUserName();
    _loadAppVersion();
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

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString(userNamePrefsKey) ?? 'User';
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

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
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.05,
            vertical: screenSize.height * 0.02,
          ),
          children: [
            _buildSectionHeader(localizations.profile),
            _buildSettingsContainer(
              children: [
                _buildSettingsTile(
                  icon: Icons.person,
                  iconColor: Colors.purple.shade300,
                  title: localizations.name,
                  subtitle: _userName,
                  trailing: Icon(
                    Icons.edit,
                    color: Colors.white.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width < 360 ? 14 : 16,
                  ),
                  onTap: () => _showNameEditDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(localizations.security),
            _buildSettingsContainer(
              children: [
                _buildSettingsTile(
                  icon: Icons.fingerprint,
                  iconColor: Colors.blue.shade300,
                  title: localizations.systemLock,
                  subtitle: localizations.requirePassword,
                  trailing: Switch(
                    value: _systemLockEnabled,
                    onChanged: (value) async {
                      if (!_canCheckBiometrics) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(localizations.biometricNotAvailable),
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
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(localizations.preferences),
            _buildSettingsContainer(
              children: [
                _buildSettingsTile(
                  icon: Icons.currency_exchange,
                  iconColor: Colors.orange.shade300,
                  title: localizations.currency,
                  subtitle: '${localizations.selected}: $_selectedCurrency',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                  onTap: () => _showCurrencyPicker(),
                ),
                Divider(color: Colors.white.withOpacity(0.1)),
                _buildSettingsTile(
                  icon: Icons.language,
                  iconColor: Colors.purple.shade300,
                  title: localizations.language,
                  subtitle:
                      '${localizations.selected}: ${LanguageUtils.languages.firstWhere(
                    (lang) => lang['code'] == _selectedLanguage,
                    orElse: () => {'code': 'en', 'name': 'English'},
                  )['name']}',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                  onTap: () => _showLanguagePicker(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(localizations.dataManagement),
            _buildSettingsContainer(
              children: [
                _buildSettingsTile(
                  icon: Icons.backup,
                  iconColor: Colors.blue.shade300,
                  title: localizations.backupData,
                  subtitle: localizations.backupData,
                  onTap: () => _backupData(),
                ),
                Divider(color: Colors.white.withOpacity(0.1)),
                _buildSettingsTile(
                  icon: Icons.restore,
                  iconColor: Colors.green.shade300,
                  title: localizations.restoreData,
                  subtitle: localizations.importData,
                  onTap: () => _restoreData(),
                ),
                Divider(color: Colors.white.withOpacity(0.1)),
                _buildSettingsTile(
                  icon: Icons.delete_forever,
                  iconColor: Colors.red.shade300,
                  title: localizations.eraseAllData,
                  subtitle: localizations.cannotBeUndone,
                  onTap: () => _showEraseConfirmationDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(localizations.appInfo),
            _buildSettingsContainer(
              children: [
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  iconColor: Colors.teal.shade300,
                  title: localizations.version,
                  subtitle: _appVersion,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    return Padding(
      padding: EdgeInsets.only(
        bottom: isSmallScreen ? 8 : 12,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 18 : 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer({required List<Widget> children}) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: screenSize.height * 0.03),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 4 : 8,
      ),
      leading: Container(
        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: isSmallScreen ? 20 : 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isSmallScreen ? 14 : 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: isSmallScreen ? 12 : 14,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
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
              itemCount: CurrencyUtils.currencies.length,
              itemBuilder: (context, index) {
                final currency = CurrencyUtils.currencies[index];
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
              itemCount: LanguageUtils.languages.length,
              itemBuilder: (context, index) {
                final language = LanguageUtils.languages[index];
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
              child: Text(
                localizations.cancel,
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
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthPage()),
                    (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                localizations.eraseAllData,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  encrypt.Key _getEncryptionKey() {
    // Generate a consistent key based on device ID or any other unique identifier
    // For this example, we'll use a fixed key (you should use a more secure method in production)
    return encrypt.Key.fromUtf8('your32characterkey12345678901234');
  }

  Future<void> _backupData() async {
    try {
      // Get all data from Hive boxes
      final transactions =
          Hive.box<Transaction>(StorageService.transactionsBox);
      final accounts = Hive.box<Account>(StorageService.accountsBox);
      final backupData = {
        'transactions': transactions.values
            .map((t) => {
                  'id': t.id,
                  'amount': t.amount,
                  'description': t.note,
                  'date': t.date.toIso8601String(),
                  'accountId': t.accountName,
                  'type': t.isExpense ? 'expense' : 'income',
                  'category': t.category,
                  'accountIconIndex': t.accountIconIndex,
                  'accountColorValue': t.accountColorValue,
                  'categoryIconIndex': t.categoryIconIndex,
                  'categoryColorValue': t.categoryColorValue,
                })
            .toList(),
        'accounts': accounts.values.map((a) => a.toJson()).toList(),
      };
      print(backupData);

      // Convert to JSON string
      final jsonString = jsonEncode(backupData);

      // Encrypt the data
      final key = _getEncryptionKey();
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(jsonString, iv: iv);

      // Create final backup data with IV
      final finalBackupData = {
        'iv': iv.base64,
        'data': encrypted.base64,
      };

      // Let user pick directory for backup
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) return;

      // Create backup file in selected directory
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('$selectedDirectory/budgia_backup_$timestamp.bak');
      await file.writeAsString(jsonEncode(finalBackupData));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Encrypted backup saved to: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating backup: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _restoreData() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bak'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final encryptedData = jsonDecode(await file.readAsString());

      // Decrypt the data
      final key = _getEncryptionKey();
      final iv = encrypt.IV.fromBase64(encryptedData['iv']);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      try {
        final decrypted = encrypter.decrypt64(encryptedData['data'], iv: iv);
        final backupData = jsonDecode(decrypted);

        // Clear existing data
        final transactionsBox =
            await Hive.openBox<Transaction>(StorageService.transactionsBox);
        final accountsBox =
            await Hive.openBox<Account>(StorageService.accountsBox);

        await transactionsBox.clear();
        await accountsBox.clear();

        // Restore transactions
        if (backupData['transactions'] != null) {
          for (final transactionJson in backupData['transactions']) {
            try {
              final transaction = Transaction(
                id: transactionJson['id'] ?? DateTime.now().toString(),
                amount: (transactionJson['amount'] ?? 0).toDouble(),
                isExpense: transactionJson['type'] == 'expense',
                category: transactionJson['category'] ?? 'Other',
                note: transactionJson['description'] ?? '',
                date: DateTime.parse(transactionJson['date']),
                accountName: transactionJson['accountId'] ?? 'Default',
                accountIconIndex: transactionJson['accountIconIndex'] ??
                    Icons.account_balance.codePoint,
                accountColorValue:
                    transactionJson['accountColorValue'] ?? Colors.blue.value,
                categoryIconIndex: transactionJson['categoryIconIndex'] ??
                    Icons.category.codePoint,
                categoryColorValue:
                    transactionJson['categoryColorValue'] ?? Colors.blue.value,
              );
              await transactionsBox.add(transaction);
            } catch (e) {
              print('Error restoring transaction: $e');
              continue;
            }
          }
        }

        // Restore accounts
        if (backupData['accounts'] != null) {
          for (final accountJson in backupData['accounts']) {
            try {
              final account = Account(
                id: accountJson['id'] ?? DateTime.now().toString(),
                name: accountJson['name'] ?? 'Default Account',
                balance: (accountJson['balance'] ?? 0).toDouble(),
                iconIndex:
                    accountJson['iconIndex'] ?? Icons.account_balance.codePoint,
                colorValue: accountJson['colorValue'] ?? Colors.blue.value,
              );
              await accountsBox.add(account);
            } catch (e) {
              print('Error restoring account: $e');
              continue;
            }
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data restored successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh the app state
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthPage()),
            (route) => false,
          );
        }
      } catch (e) {
        throw Exception('Invalid backup file or corrupted data');
      }
    } catch (e) {
      print('Restore error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNameEditDialog() {
    final localizations = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final TextEditingController controller =
        TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E21),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.purple.withOpacity(0.2),
            ),
          ),
          title: Text(
            localizations.editName,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          contentPadding: EdgeInsets.all(screenSize.width * 0.05),
          content: SizedBox(
            width: screenSize.width * 0.8,
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
              ),
              decoration: InputDecoration(
                hintText: localizations.enterName,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple.withOpacity(0.2)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                localizations.cancel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                      userNamePrefsKey, controller.text.trim());
                  setState(() => _userName = controller.text.trim());
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                localizations.save,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
