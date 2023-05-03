import 'package:flutter/material.dart';

/// A supported locale.
enum SupportedLocale {
  /// English.
  en._(Locale('en', ''), 'English'),

  /// German.
  de._(Locale('de', ''), 'Deutsch');

  /// The locale.
  final Locale locale;

  /// The name of the locale / text display.
  final String name;

  const SupportedLocale._(this.locale, this.name);
}
