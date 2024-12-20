import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budgia/services/storage_service.dart';
import 'package:budgia/utils/currency_utils.dart';
import 'package:budgia/l10n/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _storageService = StorageService();
  Map<String, double> _categoryTotals = {};
  List<FlSpot> _weeklyExpenseSpots = [];
  List<FlSpot> _weeklyIncomeSpots = [];
  String _selectedTimeRange = '7D'; // Default time range
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadCurrencySymbol();
    _loadTransactionData();
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await CurrencyUtils.getSelectedCurrencySymbol();
    setState(() {
      _currencySymbol = symbol;
    });
  }

  void _loadTransactionData() {
    final transactions = _storageService.getTransactions();
    final now = DateTime.now();
    final daysToShow = _selectedTimeRange == '30D' ? 30 : 7;
    final startDate = now.subtract(Duration(days: daysToShow));

    // Reset data
    _categoryTotals.clear();
    Map<int, double> dailyExpenses = {};
    Map<int, double> dailyIncome = {};

    // Initialize all days with 0
    for (int i = 0; i < daysToShow; i++) {
      dailyExpenses[i] = 0;
      dailyIncome[i] = 0;
    }

    // Process transactions
    for (var transaction in transactions) {
      if (transaction.date.isAfter(startDate)) {
        final daysAgo = now.difference(transaction.date).inDays;
        if (daysAgo < daysToShow) {
          if (transaction.isExpense) {
            dailyExpenses[daysAgo] =
                (dailyExpenses[daysAgo] ?? 0) + transaction.amount;
            _categoryTotals[transaction.category] =
                (_categoryTotals[transaction.category] ?? 0) +
                    transaction.amount;
          } else {
            dailyIncome[daysAgo] =
                (dailyIncome[daysAgo] ?? 0) + transaction.amount;
          }
        }
      }
    }

    // Convert to FlSpots
    _weeklyExpenseSpots = dailyExpenses.entries
        .map((e) => FlSpot((daysToShow - 1 - e.key).toDouble(), e.value))
        .toList();
    _weeklyIncomeSpots = dailyIncome.entries
        .map((e) => FlSpot((daysToShow - 1 - e.key).toDouble(), e.value))
        .toList();

    setState(() {});
  }

  List<PieChartSectionData> _generatePieChartSections() {
    final total =
        _categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final colors = [
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.red.shade300,
      Colors.purple.shade300,
      Colors.orange.shade300,
      Colors.teal.shade300,
    ];

    return _categoryTotals.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final colorIndex =
          _categoryTotals.keys.toList().indexOf(entry.key) % colors.length;

      return PieChartSectionData(
        value: entry.value,
        color: colors[colorIndex],
        radius: 50,
        title: '${percentage.toStringAsFixed(1)}%\n${entry.key}',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  Widget _buildTimeRangeSelector(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 2 : 4,
        vertical: isSmallScreen ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['7D', '30D'].map((range) {
          final isSelected = _selectedTimeRange == range;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeRange = range;
                _loadTransactionData();
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20,
                  vertical: isSmallScreen ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade700 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blue.shade700.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  range,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
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
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.05,
            vertical: screenSize.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.height * 0.02),

              // Header with time range selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      localizations.statistics,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildTimeRangeSelector(isSmallScreen),
                ],
              ),

              SizedBox(height: screenSize.height * 0.03),

              // Summary Cards with responsive spacing
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: localizations.income,
                      amount: _calculateTotalIncome(),
                      icon: Icons.arrow_upward,
                      color: Colors.green.shade400,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.04),
                  Expanded(
                    child: _buildSummaryCard(
                      title: localizations.expenses,
                      amount: _calculateTotalExpenses(),
                      icon: Icons.arrow_downward,
                      color: Colors.red.shade400,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenSize.height * 0.03),

              // Charts with responsive heights
              _buildChartContainer(
                title: localizations.incomeVsExpenses,
                subtitle: _selectedTimeRange == '30D'
                    ? localizations.last30Days
                    : localizations.last7Days,
                height: screenSize.height * 0.35,
                child: Stack(
                  children: [
                    LineChart(_getLineChartData()),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildChartLegend(),
                    ),
                  ],
                ),
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: screenSize.height * 0.03),

              _buildChartContainer(
                title: localizations.spendingByCategory,
                subtitle: localizations.distributionOfExpenses,
                height: screenSize.height * 0.45,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections: _generatePieChartSections(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      flex: 2,
                      child: _buildCategoryList(),
                    ),
                  ],
                ),
                isSmallScreen: isSmallScreen,
              ),

              SizedBox(height: screenSize.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            '$_currencySymbol${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(localizations.income, Colors.green.shade300),
          const SizedBox(width: 16),
          _buildLegendItem(localizations.expenses, Colors.red.shade300),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    final colors = [
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.red.shade300,
      Colors.purple.shade300,
      Colors.orange.shade300,
      Colors.teal.shade300,
    ];

    final totalExpenses =
        _categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _categoryTotals.length,
      itemBuilder: (context, index) {
        final entry = _categoryTotals.entries.elementAt(index);
        final percentage = (entry.value / totalExpenses * 100);
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$_currencySymbol${entry.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateTotalIncome() {
    return _weeklyIncomeSpots.fold(0.0, (sum, spot) => sum + spot.y);
  }

  double _calculateTotalExpenses() {
    return _weeklyExpenseSpots.fold(0.0, (sum, spot) => sum + spot.y);
  }

  LineChartData _getLineChartData() {
    final daysToShow = _selectedTimeRange == '30D' ? 30 : 7;

    // Calculate a reasonable interval based on the data range
    final maxY = [
      ..._weeklyExpenseSpots.map((spot) => spot.y),
      ..._weeklyIncomeSpots.map((spot) => spot.y),
    ].fold(0.0, (max, value) => value > max ? value : max);

    // Add a minimum interval of 1.0 to prevent zero interval
    final interval = max((maxY / 5).roundToDouble(), 1.0);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _selectedTimeRange == '30D' ? 5 : 1,
            getTitlesWidget: (value, meta) {
              if (value % (_selectedTimeRange == '30D' ? 5 : 1) == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${value.toInt()}d',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            interval: interval, // Use the calculated interval
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  '$_currencySymbol${value.toInt()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: daysToShow.toDouble() - 1,
      lineBarsData: [
        // Income line
        LineChartBarData(
          spots: _weeklyIncomeSpots,
          isCurved: true,
          color: Colors.green.shade300,
          barWidth: 3,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.green.shade700.withOpacity(0.2),
          ),
        ),
        // Expense line
        LineChartBarData(
          spots: _weeklyExpenseSpots,
          isCurved: true,
          color: Colors.red.shade300,
          barWidth: 3,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.red.shade700.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildChartContainer({
    required String title,
    required String subtitle,
    required double height,
    required Widget child,
    required bool isSmallScreen,
  }) {
    return Container(
      height: height,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade800.withOpacity(0.2),
            Colors.indigo.shade900.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
