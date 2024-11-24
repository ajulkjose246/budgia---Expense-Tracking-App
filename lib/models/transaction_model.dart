import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final bool isExpense;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String note;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String accountName;

  @HiveField(7)
  final int accountIconIndex;

  @HiveField(8)
  final int accountColorValue;

  @HiveField(9)
  final int categoryIconIndex;

  @HiveField(10)
  final int categoryColorValue;

  Transaction({
    required this.id,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.note,
    required this.date,
    required this.accountName,
    required this.accountIconIndex,
    required this.accountColorValue,
    required this.categoryIconIndex,
    required this.categoryColorValue,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'],
      isExpense: json['type'] == 'expense',
      category: json['category'],
      note: json['note'],
      date: DateTime.parse(json['date']),
      accountName: json['accountId'],
      accountIconIndex: json['accountIconIndex'],
      accountColorValue: json['accountColorValue'],
      categoryIconIndex: json['categoryIconIndex'],
      categoryColorValue: json['categoryColorValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': note,
      'date': date.toIso8601String(),
      'accountId': accountName,
      'type': isExpense ? 'expense' : 'income',
      // Add any other properties your Transaction class has
    };
  }
}
