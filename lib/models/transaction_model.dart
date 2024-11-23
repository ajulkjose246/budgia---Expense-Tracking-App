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
}
