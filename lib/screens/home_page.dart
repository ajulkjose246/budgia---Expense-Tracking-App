import 'package:budgia/screens/dash_screen.dart';
import 'package:budgia/screens/settings_screen.dart';
import 'package:budgia/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:budgia/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const DashScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: SizedBox(
        height: kBottomNavigationBarHeight + bottomPadding,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E21),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blue.shade300,
              unselectedItemColor: Colors.white.withOpacity(0.5),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_rounded),
                  label: localizations.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.analytics_rounded),
                  label: localizations.statistics,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: localizations.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
