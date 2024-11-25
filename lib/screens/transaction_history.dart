import 'package:budgia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:budgia/services/storage_service.dart';
import 'package:budgia/models/transaction_model.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:budgia/models/category_model.dart';
import 'package:budgia/utils/currency_utils.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final _storageService = StorageService();
  late List<Transaction> transactions;
  Map<String, IconData> categoryIcons = {};
  String currencySymbol = '\$';
  String _sortBy = 'date'; // Options: 'date', 'amount', 'category'
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    transactions = _storageService.getTransactions()
      ..sort((a, b) => b.date.compareTo(a.date));
    _loadCategoryIcons();
    _loadCurrencySymbol();
  }

  Future<void> _loadCategoryIcons() async {
    final categoryBox = await Hive.openBox<CategoryModel>('categories');
    setState(() {
      categoryIcons = {
        for (var category in categoryBox.values)
          category.name:
              IconData(category.iconCode, fontFamily: 'MaterialIcons')
      };
    });
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await CurrencyUtils.getSelectedCurrencySymbol();
    setState(() {
      currencySymbol = symbol;
    });
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required Color iconColor,
    required String account,
    required IconData accountIcon,
    required Color accountColor,
    required bool isSmallScreen,
  }) {
    return Dismissible(
      key: ValueKey('transaction.id'),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: isSmallScreen ? 16 : 20),
        child: Icon(Icons.delete,
            color: Colors.redAccent, size: isSmallScreen ? 20 : 24),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Add delete functionality
      },
      child: Card(
        elevation: 0,
        color: Colors.white.withOpacity(0.03),
        margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 6 : 8,
          ),
          leading: Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: isSmallScreen ? 20 : 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '$account ${subtitle.isNotEmpty ? ' • $subtitle' : ''}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: isSmallScreen ? 11 : 13,
            ),
          ),
          trailing: Text(
            amount,
            style: TextStyle(
              color: amount.startsWith('-')
                  ? Colors.redAccent
                  : Colors.greenAccent,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: screenSize.height * 0.2, // Responsive height
            pinned: true,
            backgroundColor: const Color(0xFF0A0E21),
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              localizations.transactionHistory,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: EdgeInsets.fromLTRB(
                  screenSize.width * 0.04,
                  screenSize.height * 0.08,
                  screenSize.width * 0.04,
                  screenSize.height * 0.02,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenSize.height * 0.02),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSummaryChip(
                            label: localizations.today,
                            amount:
                                '$currencySymbol${_calculateTodaySpending().toStringAsFixed(2)}',
                            isSmallScreen: isSmallScreen,
                          ),
                          SizedBox(width: screenSize.width * 0.02),
                          _buildSummaryChip(
                            label: localizations.thisWeek,
                            amount:
                                '$currencySymbol${_calculateWeekSpending().toStringAsFixed(2)}',
                            isSmallScreen: isSmallScreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sorting Options
          SliverPersistentHeader(
            pinned: true,
            delegate: _SortingHeaderDelegate(
              child: Container(
                color: const Color(0xFF0A0E21),
                child: _buildSortingOptions(),
              ),
            ),
          ),

          // Transaction List with responsive padding
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.04,
              vertical: screenSize.height * 0.01,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionItem(
                    icon: IconData(transaction.categoryIconIndex,
                        fontFamily: 'MaterialIcons'),
                    title: transaction.category,
                    subtitle: transaction.note,
                    amount:
                        '${transaction.isExpense ? '-' : '+'}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                    iconColor: Color(transaction.categoryColorValue),
                    account: transaction.accountName,
                    accountIcon: IconData(transaction.accountIconIndex,
                        fontFamily: 'MaterialIcons'),
                    accountColor: Color(transaction.accountColorValue),
                    isSmallScreen: isSmallScreen,
                  );
                },
                childCount: transactions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required String amount,
    required bool isSmallScreen,
  }) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width * (isSmallScreen ? 0.4 : 0.35),
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isSmallScreen ? 12 : 13,
            ),
          ),
          SizedBox(height: screenSize.height * 0.005),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalSpending() {
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTodaySpending() {
    final today = DateTime.now();
    return transactions
        .where((t) => t.isExpense)
        .where((t) =>
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateWeekSpending() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return transactions
        .where((t) => t.isExpense)
        .where((t) => t.date.isAfter(weekAgo))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void _sortTransactions() {
    setState(() {
      switch (_sortBy) {
        case 'date':
          transactions.sort((a, b) => _sortAscending
              ? a.date.compareTo(b.date)
              : b.date.compareTo(a.date));
        case 'amount':
          transactions.sort((a, b) => _sortAscending
              ? a.amount.compareTo(b.amount)
              : b.amount.compareTo(a.amount));
        case 'category':
          transactions.sort((a, b) => _sortAscending
              ? a.category.compareTo(b.category)
              : b.category.compareTo(a.category));
      }
    });
  }

  Widget _buildSortingOptions() {
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Sort By Label
          Text(
            localizations.sortBy,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),

          // Sort Options Container
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButton<String>(
              value: _sortBy,
              dropdownColor:
                  const Color(0xFF1D1E33), // Slightly lighter than background
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withOpacity(0.7),
              ),
              underline: const SizedBox(), // Remove underline
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _sortBy = newValue;
                    _sortTransactions();
                  });
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'date',
                  child: Text(localizations.date),
                ),
                DropdownMenuItem(
                  value: 'amount',
                  child: Text(localizations.amount),
                ),
                DropdownMenuItem(
                  value: 'category',
                  child: Text(localizations.category),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Sort Direction Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                  _sortTransactions();
                });
              },
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minHeight: 36,
                minWidth: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this new class at the bottom of the file
class _SortingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SortingHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
