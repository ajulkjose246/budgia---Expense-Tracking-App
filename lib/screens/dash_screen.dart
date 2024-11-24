import 'package:budgia/models/transaction_model.dart';
import 'package:budgia/screens/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:budgia/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:budgia/providers/accounts_provider.dart';
import 'package:hive/hive.dart';
import 'package:budgia/models/category_model.dart';
import 'package:budgia/utils/currency_utils.dart';
import 'package:budgia/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashScreen extends StatefulWidget {
  const DashScreen({super.key});

  @override
  State<DashScreen> createState() => _DashScreenState();
}

class _DashScreenState extends State<DashScreen> {
  final StorageService _storageService = StorageService();
  List<Transaction> _recentTransactions = [];
  List<Transaction> _allTransactions = [];
  Map<String, IconData> _categoryIcons = {};
  String _currencySymbol = '\$';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountsProvider>().loadAccounts();
      _loadTransactions();
      _loadCategoryIcons();
      _loadCurrencySymbol();
      _loadUserName();
    });
  }

  Future<void> _loadCategoryIcons() async {
    final categoryBox = await Hive.openBox<CategoryModel>('categories');
    setState(() {
      _categoryIcons = {
        for (var category in categoryBox.values)
          category.name:
              IconData(category.iconCode, fontFamily: 'MaterialIcons')
      };
    });
  }

  void _loadTransactions() {
    setState(() {
      _allTransactions = _storageService.getTransactions();
      _recentTransactions = _storageService.getLatestTransactions(3);
    });
  }

  double _calculateIncome() {
    return _allTransactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateExpenses() {
    return _allTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await CurrencyUtils.getSelectedCurrencySymbol();
    setState(() {
      _currencySymbol = symbol;
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final List<Map<String, dynamic>> accountIcons = [
      {'icon': Icons.account_balance, 'color': Colors.blue},
      {'icon': Icons.credit_card, 'color': Colors.green},
      {'icon': Icons.savings, 'color': Colors.purple},
      {'icon': Icons.wallet, 'color': Colors.orange},
      {'icon': Icons.attach_money, 'color': Colors.red},
      {'icon': Icons.currency_exchange, 'color': Colors.teal},
      {'icon': Icons.payment, 'color': Colors.pink},
      {'icon': Icons.account_balance_wallet, 'color': Colors.amber},
    ];
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
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.welcomeBack,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Updated Balance Card
                Consumer<AccountsProvider>(
                  builder: (context, accountsProvider, child) {
                    double totalBalance = accountsProvider.accounts
                        .fold(0, (sum, account) => sum + account.balance);

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade800,
                            Colors.indigo.shade900,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade900.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            '$_currencySymbol${totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBalanceItem(
                                icon: Icons.arrow_upward,
                                label: localizations.income,
                                amount:
                                    '+$_currencySymbol${_calculateIncome().toStringAsFixed(2)}',
                                iconColor: Colors.green,
                              ),
                              const SizedBox(width: 10),
                              _buildBalanceItem(
                                icon: Icons.arrow_downward,
                                label: localizations.expenses,
                                amount:
                                    '-$_currencySymbol${_calculateExpenses().toStringAsFixed(2)}',
                                iconColor: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Accounts section header with add button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.accounts,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            IconData selectedIcon = accountIcons[0]['icon'];
                            Color selectedColor = accountIcons[0]['color'];
                            final accountNameController =
                                TextEditingController();
                            final balanceController = TextEditingController();

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xFF0A0E21),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Colors.blue.withOpacity(0.2),
                                    ),
                                  ),
                                  title: Text(
                                    localizations.addNewAccount,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      constraints: BoxConstraints(
                                        maxWidth: 400,
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizations.chooseIcon,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: GridView.builder(
                                              padding: const EdgeInsets.all(8),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4,
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 8,
                                                childAspectRatio: 1,
                                              ),
                                              itemCount: accountIcons.length,
                                              itemBuilder: (context, index) {
                                                final icon =
                                                    accountIcons[index];
                                                final isSelected =
                                                    selectedIcon ==
                                                        icon['icon'];
                                                return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedIcon =
                                                          icon['icon'];
                                                      selectedColor =
                                                          icon['color'];
                                                    });
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? icon['color']
                                                              .withOpacity(0.2)
                                                          : Colors.white
                                                              .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? icon['color']
                                                            : Colors.white
                                                                .withOpacity(
                                                                    0.1),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      icon['icon'],
                                                      color: isSelected
                                                          ? icon['color']
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          TextField(
                                            controller: accountNameController,
                                            style:
                                                TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              hintText:
                                                  localizations.accountName,
                                              hintStyle: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.5)),
                                              filled: true,
                                              fillColor:
                                                  Colors.white.withOpacity(0.1),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller: balanceController,
                                            style:
                                                TextStyle(color: Colors.white),
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              hintText:
                                                  localizations.initialBalance,
                                              hintStyle: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.5)),
                                              filled: true,
                                              fillColor:
                                                  Colors.white.withOpacity(0.1),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                              prefixText: '$_currencySymbol ',
                                              prefixStyle: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        localizations.cancel,
                                        style: TextStyle(
                                            color: Colors.blue.shade300),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Get the text values from controllers
                                        final name =
                                            accountNameController.text.trim();
                                        final balanceText =
                                            balanceController.text.trim();

                                        if (name.isEmpty ||
                                            balanceText.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Please fill in all fields')),
                                          );
                                          return;
                                        }

                                        final balance =
                                            double.tryParse(balanceText);
                                        if (balance == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Please enter a valid balance')),
                                          );
                                          return;
                                        }

                                        // Use the provider to add the account
                                        await context
                                            .read<AccountsProvider>()
                                            .addAccount(
                                              name: name,
                                              balance: balance,
                                              icon: selectedIcon,
                                              color: selectedColor,
                                            );

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          // Optionally show success message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(localizations
                                                    .accountAddedSuccess)),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(localizations.addAccount),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Consumer<AccountsProvider>(
                        builder: (context, accountsProvider, child) {
                          final accounts = accountsProvider.accounts;

                          if (accounts.isEmpty) {
                            return Text(
                              localizations
                                  .noAccountsYet, // Changed from 'No accounts yet'
                              style: const TextStyle(color: Colors.white),
                            );
                          }

                          return Row(
                            children: accounts.map((account) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: _buildQuickAction(
                                  icon: IconData(account.iconIndex,
                                      fontFamily: 'MaterialIcons'),
                                  label: account.name,
                                  color: Color(account.colorValue),
                                  amount:
                                      '$_currencySymbol${account.balance.toStringAsFixed(2)}',
                                  context: context,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Recent Transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        localizations.recentTransactions,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/transaction-history');
                      },
                      child: Text(
                        localizations.seeAll,
                        style: TextStyle(
                          color: Colors.blue.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_recentTransactions.isEmpty)
                  Text(
                    localizations.noRecentTransactions,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  )
                else
                  Column(
                    children: _recentTransactions.map((transaction) {
                      return _buildTransactionItem(
                        icon: IconData(
                          transaction.categoryIconIndex,
                          fontFamily: 'MaterialIcons',
                        ),
                        title: transaction.category,
                        subtitle: transaction.note,
                        amount: '${transaction.isExpense ? '-' : '+'}'
                            '$_currencySymbol${transaction.amount.toStringAsFixed(2)}',
                        iconColor: Color(transaction.categoryColorValue),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required String amount,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required String amount,
    required BuildContext context,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Label Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              InkWell(
                onTap: () {
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
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to delete "$label" account?',
                          style: const TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.blue.shade300),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await context
                                  .read<AccountsProvider>()
                                  .deleteAccount(label);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Account deleted successfully')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Amount
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.remove,
                color: color,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionPage(
                        isExpense: true,
                        accountLabel: label,
                        accountColor: color,
                      ),
                    ),
                  ).then((_) => _loadTransactions());
                },
              ),
              _buildActionButton(
                icon: Icons.add,
                color: color,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionPage(
                        isExpense: false,
                        accountLabel: label,
                        accountColor: color,
                      ),
                    ),
                  ).then((_) => _loadTransactions());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
