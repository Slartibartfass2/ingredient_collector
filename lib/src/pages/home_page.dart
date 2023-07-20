import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/locale_dropdown_button.dart';
import '../widgets/recipe_input_form.dart';

/// Home page of this app.
class HomePage extends StatefulWidget {
  /// Creates a new [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _onLocaleChanged(Locale locale) async {
    await context.setLocale(locale);
    if (!mounted) return;
    setState(() {
      log("Locale changed to ${locale.languageCode}.");
    });
  }

  @override
  Widget build(BuildContext context) {
    var localeDropdownButton = LocaleDropdownButton(
      onChanged: (newValue) async => _onLocaleChanged(newValue.locale),
    );

    return Scaffold(
      key: ValueKey(context.locale.languageCode),
      appBar: AppBar(
        title: const Text(appTitle),
        actions: [localeDropdownButton],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          child: const AdaptiveContainer(
            child: RecipeInputForm(),
          ),
        ),
      ),
    );
  }
}
