import 'package:hive/hive.dart';

part 'account_model.g.dart';

@HiveType(typeId: 1)
class Account extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double balance;

  @HiveField(3)
  final int iconIndex;

  @HiveField(4)
  final int colorValue;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconIndex,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
      'iconIndex': iconIndex,
      'colorValue': colorValue,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      balance: json['balance'],
      iconIndex: json['iconIndex'],
      colorValue: json['colorValue'],
    );
  }
}
