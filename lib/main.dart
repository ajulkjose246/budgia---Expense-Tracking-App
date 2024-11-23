import 'package:budgia/auth/auth_page.dart';
import 'package:budgia/screens/home_page.dart';
import 'package:budgia/screens/introduction_screen.dart';
import 'package:budgia/screens/transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgia/models/transaction_model.dart';
import 'package:budgia/models/account_model.dart';
import 'package:provider/provider.dart';
import 'package:budgia/providers/accounts_provider.dart';
import 'package:budgia/models/category_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(CategoryModelAdapter());

  // Open Boxes
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Account>('accounts');

  runApp(
    ChangeNotifierProvider(
      create: (_) => AccountsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: ({
        '/': (context) => const IntroductionScreen(),
        '/home': (context) => const HomePage(),
        '/transaction-history': (context) => const TransactionHistory(),
        '/auth': (context) => const AuthPage(),
      }),
      initialRoute: '/auth',
    );
  }
}
