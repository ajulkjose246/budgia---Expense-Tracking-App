import 'package:budgia/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:budgia/services/storage_service.dart';
import 'package:budgia/providers/accounts_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgia/models/category_model.dart';
import 'package:budgia/utils/currency_utils.dart';
import 'package:budgia/l10n/app_localizations.dart';

class TransactionPage extends StatefulWidget {
  final bool isExpense;
  final String accountLabel;
  final Color accountColor;

  const TransactionPage({
    super.key,
    required this.isExpense,
    required this.accountLabel,
    required this.accountColor,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedCategory;
  List<String> expenseCategories = [];
  List<String> incomeCategories = [];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Add a map to store category icons
  final Map<String, IconData> categoryIcons = {
    'Shopping': Icons.shopping_cart,
    'Food & Drinks': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Entertainment': Icons.movie,
    'Bills & Utilities': Icons.receipt,
    'Others': Icons.more_horiz,
  };

  String currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCurrencySymbol();
  }

  Future<void> _loadCategories() async {
    final categoryBox = await Hive.openBox<CategoryModel>('categories');

    if (categoryBox.isEmpty) {
      // Add default expense categories
      await Future.wait([
        categoryBox.put(
            'expense_Shopping',
            CategoryModel(
              name: 'Shopping',
              iconCode: Icons.shopping_cart.codePoint,
              isExpense: true,
            )),
        categoryBox.put(
            'expense_Food & Drinks',
            CategoryModel(
              name: 'Food & Drinks',
              iconCode: Icons.restaurant.codePoint,
              isExpense: true,
            )),
        categoryBox.put(
            'expense_Transportation',
            CategoryModel(
              name: 'Transportation',
              iconCode: Icons.directions_car.codePoint,
              isExpense: true,
            )),
        categoryBox.put(
            'expense_Entertainment',
            CategoryModel(
              name: 'Entertainment',
              iconCode: Icons.movie.codePoint,
              isExpense: true,
            )),
        categoryBox.put(
            'expense_Bills & Utilities',
            CategoryModel(
              name: 'Bills & Utilities',
              iconCode: Icons.receipt.codePoint,
              isExpense: true,
            )),
        categoryBox.put(
            'expense_Others',
            CategoryModel(
              name: 'Others',
              iconCode: Icons.more_horiz.codePoint,
              isExpense: true,
            )),
      ]);

      // Add default income categories
      await Future.wait([
        categoryBox.put(
            'income_Salary',
            CategoryModel(
              name: 'Salary',
              iconCode: Icons.payments.codePoint,
              isExpense: false,
            )),
        categoryBox.put(
            'income_Investment',
            CategoryModel(
              name: 'Investment',
              iconCode: Icons.trending_up.codePoint,
              isExpense: false,
            )),
        categoryBox.put(
            'income_Gift',
            CategoryModel(
              name: 'Gift',
              iconCode: Icons.card_giftcard.codePoint,
              isExpense: false,
            )),
      ]);
    }

    setState(() {
      // Separate categories based on transaction type, handling null values
      expenseCategories = categoryBox.values
          .where((cat) => cat.isExpense ?? true) // Default to expense if null
          .map((cat) => cat.name)
          .toList();
      incomeCategories = categoryBox.values
          .where(
              (cat) => cat.isExpense == false) // Only explicitly false values
          .map((cat) => cat.name)
          .toList();

      categoryIcons.clear();
      for (var category in categoryBox.values) {
        categoryIcons[category.name] = IconData(
          category.iconCode,
          fontFamily: 'MaterialIcons',
        );
      }
    });
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await CurrencyUtils.getSelectedCurrencySymbol();
    setState(() {
      currencySymbol = symbol;
    });
  }

  Future<void> _addNewCategory() async {
    String? newCategoryName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String categoryInput = '';
        IconData selectedIcon = Icons.category;
        final localizations = AppLocalizations.of(context);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0A0E21),
              title: Text(localizations.addNewCategory,
                  style: const TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) => categoryInput = value,
                    decoration: InputDecoration(
                      hintText: localizations.categoryName,
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.5)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      Icons.shopping_cart,
                      Icons.restaurant,
                      Icons.directions_car,
                      Icons.movie,
                      Icons.receipt,
                      Icons.sports,
                      Icons.medical_services,
                      Icons.home,
                      Icons.category,
                    ].map((IconData icon) {
                      return IconButton(
                        icon: Icon(
                          icon,
                          color: selectedIcon == icon
                              ? widget.accountColor
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() => selectedIcon = icon);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(localizations.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (categoryInput.isNotEmpty) {
                      Navigator.of(context).pop(categoryInput);
                      categoryIcons[categoryInput] = selectedIcon;
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (newCategoryName != null && newCategoryName.isNotEmpty) {
      final categoryBox = await Hive.openBox<CategoryModel>('categories');
      final categoryKey = widget.isExpense
          ? 'expense_$newCategoryName'
          : 'income_$newCategoryName';

      // Create the new category
      final newCategory = CategoryModel(
        name: newCategoryName,
        iconCode: (categoryIcons[newCategoryName] ?? Icons.category).codePoint,
        isExpense: widget.isExpense,
      );

      // Store the new category
      await categoryBox.put(categoryKey, newCategory);

      // Update the UI
      setState(() {
        if (widget.isExpense) {
          expenseCategories.add(newCategoryName);
        } else {
          incomeCategories.add(newCategoryName);
        }
        selectedCategory = newCategoryName;
      });
    }
  }

  final _storageService = StorageService();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isExpense ? localizations.newExpense : localizations.newIncome,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Field
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accountColor.withOpacity(0.2),
                    widget.accountColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.accountColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _amountController,
                style: const TextStyle(color: Colors.white, fontSize: 32),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  prefixText: '$currencySymbol ',
                  prefixStyle: TextStyle(
                    color: widget.accountColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Category Selection
            Text(
              localizations.category,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        dropdownColor: const Color(0xFF0A0E21),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        hint: Text(
                          localizations.selectCategory,
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                        items: (widget.isExpense
                                ? expenseCategories
                                : incomeCategories)
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  categoryIcons[value] ?? Icons.category,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() => selectedCategory = newValue);
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white.withOpacity(0.7)),
                    onPressed: _addNewCategory,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Note Field
            Text(
              localizations.note,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: localizations.addNote,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            Text(
              localizations.date,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: widget.accountColor,
                          surface: const Color(0xFF0A0E21),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () async {
              if (_amountController.text.isEmpty || selectedCategory == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill in all required fields')),
                );
                return;
              }

              final amount = double.tryParse(_amountController.text);
              if (amount == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              // Check account balance before allowing expense
              if (widget.isExpense) {
                final accountsProvider = context.read<AccountsProvider>();
                final currentBalance =
                    accountsProvider.getAccountBalance(widget.accountLabel);
                if (amount > currentBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Insufficient funds. Available balance: $currencySymbol${currentBalance.toStringAsFixed(2)}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
              }

              // Get the category icon and color
              final categoryBox =
                  await Hive.openBox<CategoryModel>('categories');
              final categoryKey = widget.isExpense
                  ? 'expense_$selectedCategory'
                  : 'income_$selectedCategory';
              final category = categoryBox.get(categoryKey);

              if (category == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category not found')),
                );
                return;
              }

              // Store transaction with the correct category icon and color
              await _storageService.addTransaction(
                amount: amount,
                isExpense: widget.isExpense,
                category: selectedCategory!,
                note: _noteController.text,
                accountName: widget.accountLabel,
                accountIcon: Icons.account_balance,
                accountColor: widget.accountColor,
                categoryIcon:
                    IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                categoryColor: widget.accountColor,
                date: selectedDate,
              );
              await context.read<AccountsProvider>().updateAccountBalance(
                    widget.accountLabel,
                    widget.isExpense ? -amount : amount,
                  );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Transaction added successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accountColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              widget.isExpense
                  ? localizations.newExpense
                  : localizations.newIncome,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
