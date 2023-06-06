import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
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

  double _getContainerWidth(double width) {
    if (width >= 1400) return 1320;
    if (width >= 1200) return 1140;
    if (width >= 992) return 960;
    if (width >= 768) return 720;
    if (width >= 576) return 540;
    return width - 20;
  }

  @override
  Widget build(BuildContext context) {
    var localeDropdownButton = LocaleDropdownButton(
      onChanged: (newValue) async => _onLocaleChanged(newValue.locale),
    );

    var queryData = MediaQuery.of(context);
    var deviceWidth = queryData.size.width;
    var containerWidth = _getContainerWidth(deviceWidth);

    return Scaffold(
      key: ValueKey(context.locale.languageCode),
      appBar: AppBar(
        title: const Text(appTitle),
        actions: [localeDropdownButton],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          child: Container(
            width: containerWidth,
            margin: const EdgeInsets.symmetric(vertical: 30),
            child: const RecipeInputForm(),
          ),
        ),
      ),
    );
  }
}
