import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgia/models/transaction_model.dart';
import 'package:budgia/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String transactionsBox = 'transactions';
  static const String accountsBox = 'accounts';

  // Transactions
  Future<void> addTransaction({
    required double amount,
    required bool isExpense,
    required String category,
    required String note,
    required String accountName,
    required IconData accountIcon,
    required Color accountColor,
    required IconData categoryIcon,
    required Color categoryColor,
  }) async {
    final box = Hive.box<Transaction>(transactionsBox);

    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      isExpense: isExpense,
      category: category,
      note: note,
      date: DateTime.now(),
      accountName: accountName,
      accountIconIndex: accountIcon.codePoint,
      accountColorValue: accountColor.value,
      categoryIconIndex: categoryIcon.codePoint,
      categoryColorValue: categoryColor.value,
    );

    await box.add(transaction);
  }

  List<Transaction> getTransactions() {
    final box = Hive.box<Transaction>(transactionsBox);
    return box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Transaction> getLatestTransactions(int limit) {
    final box = Hive.box<Transaction>(transactionsBox);
    final transactions = box.values.toList();
    // Sort by date in descending order
    transactions.sort((a, b) => b.date.compareTo(a.date));
    // Return only the specified number of transactions
    return transactions.take(limit).toList();
  }

  // Accounts
  Future<void> addAccount({
    required String name,
    required double balance,
    required IconData icon,
    required Color color,
  }) async {
    final box = Hive.box<Account>(accountsBox);

    final account = Account(
      id: const Uuid().v4(),
      name: name,
      balance: balance,
      iconIndex: icon.codePoint,
      colorValue: color.value,
    );

    await box.add(account);
  }

  List<Account> getAccounts() {
    final box = Hive.box<Account>(accountsBox);
    return box.values.toList();
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    final box = Hive.box<Account>(accountsBox);
    final accountIndex =
        box.values.toList().indexWhere((acc) => acc.id == accountId);

    if (accountIndex != -1) {
      final account = box.getAt(accountIndex);
      if (account != null) {
        final updatedAccount = Account(
          id: account.id,
          name: account.name,
          balance: newBalance,
          iconIndex: account.iconIndex,
          colorValue: account.colorValue,
        );
        await box.putAt(accountIndex, updatedAccount);
      }
    }
  }

  Future<void> saveAccounts(List<Account> accounts) async {
    final box = Hive.box<Account>(accountsBox);
    await box.clear(); // Clear existing accounts
    await box.addAll(accounts); // Add all accounts at once
  }
}
