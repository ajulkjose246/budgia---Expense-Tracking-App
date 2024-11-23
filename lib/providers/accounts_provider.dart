import 'package:flutter/foundation.dart';
import 'package:budgia/models/account_model.dart';
import 'package:budgia/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AccountsProvider with ChangeNotifier {
  List<Account> _accounts = [];
  final StorageService _storageService = StorageService();

  List<Account> get accounts => _accounts;

  Future<void> loadAccounts() async {
    _accounts = _storageService.getAccounts();
    notifyListeners();
  }

  Future<void> addAccount({
    required String name,
    required double balance,
    required IconData icon,
    required Color color,
  }) async {
    await _storageService.addAccount(
      name: name,
      balance: balance,
      icon: icon,
      color: color,
    );
    await loadAccounts();
  }

  Future<void> deleteAccount(String accountName) async {
    accounts.removeWhere((account) => account.name == accountName);
    notifyListeners();
    await _storageService.saveAccounts(accounts);
  }

  Future<void> updateAccountBalance(String accountName, double amount) async {
    final accountBox = await Hive.openBox<Account>('accounts');
    final accountIndex = accounts.indexWhere((acc) => acc.name == accountName);

    if (accountIndex != -1) {
      final account = accounts[accountIndex];
      final updatedAccount = Account(
        id: account.id,
        name: account.name,
        balance: account.balance + amount,
        iconIndex: account.iconIndex,
        colorValue: account.colorValue,
      );

      // Update in Hive
      final hiveIndex = accountBox.values
          .toList()
          .indexWhere((acc) => acc.name == accountName);
      await accountBox.putAt(hiveIndex, updatedAccount);

      // Update in provider
      accounts[accountIndex] = updatedAccount;
      notifyListeners();
    }
  }

  double getAccountBalance(String accountName) {
    final account = _accounts.firstWhere(
      (acc) => acc.name == accountName,
      orElse: () => Account(
        id: '',
        name: accountName,
        balance: 0,
        iconIndex: Icons.account_balance.codePoint,
        colorValue: Colors.grey.value,
      ),
    );
    return account.balance;
  }
}
