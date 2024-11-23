import 'package:budgia/l10n/translations/ml.dart';
import 'package:flutter/material.dart';
import 'translations/en.dart';
import 'translations/es.dart';
import 'translations/fr.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Add your translations here
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en,
    'es': es,
    'fr': fr,
    'ml': ml,
  };

  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get security => _localizedValues[locale.languageCode]!['security']!;
  String get systemLock =>
      _localizedValues[locale.languageCode]!['systemLock']!;
  String get requirePassword =>
      _localizedValues[locale.languageCode]!['requirePassword']!;
  String get preferences =>
      _localizedValues[locale.languageCode]!['preferences']!;
  String get currency => _localizedValues[locale.languageCode]!['currency']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get selected => _localizedValues[locale.languageCode]!['selected']!;
  String get dataManagement =>
      _localizedValues[locale.languageCode]!['dataManagement']!;
  String get eraseAllData =>
      _localizedValues[locale.languageCode]!['eraseAllData']!;
  String get cannotBeUndone =>
      _localizedValues[locale.languageCode]!['cannotBeUndone']!;
  String get welcomeBack =>
      _localizedValues[locale.languageCode]!['welcomeBack']!;
  String get statistics =>
      _localizedValues[locale.languageCode]!['statistics']!;
  String get accounts => _localizedValues[locale.languageCode]!['accounts']!;
  String get income => _localizedValues[locale.languageCode]!['income']!;
  String get expenses => _localizedValues[locale.languageCode]!['expenses']!;
  String get recentTransactions =>
      _localizedValues[locale.languageCode]!['recentTransactions']!;
  String get seeAll => _localizedValues[locale.languageCode]!['seeAll']!;
  String get transactionHistory =>
      _localizedValues[locale.languageCode]!['transactionHistory']!;
  String get addNewAccount =>
      _localizedValues[locale.languageCode]!['addNewAccount']!;
  String get chooseIcon =>
      _localizedValues[locale.languageCode]!['chooseIcon']!;
  String get accountName =>
      _localizedValues[locale.languageCode]!['accountName']!;
  String get initialBalance =>
      _localizedValues[locale.languageCode]!['initialBalance']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get addAccount =>
      _localizedValues[locale.languageCode]!['addAccount']!;
  String get pleaseAuthenticate =>
      _localizedValues[locale.languageCode]!['pleaseAuthenticate']!;
  String get accountAddedSuccess =>
      _localizedValues[locale.languageCode]!['accountAddedSuccess']!;
  String get noAccountsYet =>
      _localizedValues[locale.languageCode]!['noAccountsYet']!;
  String get noRecentTransactions =>
      _localizedValues[locale.languageCode]!['noRecentTransactions']!;
  String get newExpense =>
      _localizedValues[locale.languageCode]!['newExpense']!;
  String get newIncome => _localizedValues[locale.languageCode]!['newIncome']!;
  String get category => _localizedValues[locale.languageCode]!['category']!;
  String get selectCategory =>
      _localizedValues[locale.languageCode]!['selectCategory']!;
  String get addCategory =>
      _localizedValues[locale.languageCode]!['addCategory']!;
  String get categoryName =>
      _localizedValues[locale.languageCode]!['categoryName']!;
  String get note => _localizedValues[locale.languageCode]!['note']!;
  String get addNote => _localizedValues[locale.languageCode]!['addNote']!;
  String get date => _localizedValues[locale.languageCode]!['date']!;
  String get insufficientFunds =>
      _localizedValues[locale.languageCode]!['insufficientFunds']!;
  String get transactionAdded =>
      _localizedValues[locale.languageCode]!['transactionAdded']!;
  String get fillAllFields =>
      _localizedValues[locale.languageCode]!['fillAllFields']!;
  String get enterValidAmount =>
      _localizedValues[locale.languageCode]!['enterValidAmount']!;
  String get last7Days => _localizedValues[locale.languageCode]!['last7Days']!;
  String get last30Days =>
      _localizedValues[locale.languageCode]!['last30Days']!;
  String get spendingByCategory =>
      _localizedValues[locale.languageCode]!['spendingByCategory']!;
  String get distributionOfExpenses =>
      _localizedValues[locale.languageCode]!['distributionOfExpenses']!;
  String get incomeVsExpenses =>
      _localizedValues[locale.languageCode]!['incomeVsExpenses']!;
  String get deleteAccount =>
      _localizedValues[locale.languageCode]!['deleteAccount']!;
  String get areYouSureDelete =>
      _localizedValues[locale.languageCode]!['areYouSureDelete']!;
  String get accountDeletedSuccess =>
      _localizedValues[locale.languageCode]!['accountDeletedSuccess']!;
  String get addNewCategory =>
      _localizedValues[locale.languageCode]!['addNewCategory']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;
  String get selectLanguage =>
      _localizedValues[locale.languageCode]!['selectLanguage']!;
  String get selectCurrency =>
      _localizedValues[locale.languageCode]!['selectCurrency']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations._localizedValues.containsKey(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
