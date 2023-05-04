import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'src/supported_locale.dart';
import 'src/widgets/locale_dropdown_button.dart';
import 'src/widgets/recipe_input_form.dart';

/// The title of this app.
const appTitle = 'Ingredient Collector';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: SupportedLocale.values
          .map((supportedLocale) => supportedLocale.locale)
          .toList(),
      path: 'resources/langs',
      fallbackLocale: SupportedLocale.en.locale,
      useOnlyLangCode: true,
      child: const IngredientCollectorApp(),
    ),
  );
}

/// The [IngredientCollectorApp].
class IngredientCollectorApp extends StatefulWidget {
  /// Creates a new [IngredientCollectorApp].
  const IngredientCollectorApp({super.key});

  @override
  State<IngredientCollectorApp> createState() => _IngredientCollectorAppState();
}

class _IngredientCollectorAppState extends State<IngredientCollectorApp> {
  @override
  Widget build(BuildContext context) {
    var localeDropdownButton = LocaleDropdownButton(
      onChanged: (newValue) async {
        await context.setLocale(newValue.locale);
        setState(() {});
      },
    );

    return MaterialApp(
      home: Scaffold(
        key: ValueKey(context.locale.languageCode),
        appBar: AppBar(
          title: const Text(appTitle),
          actions: [localeDropdownButton],
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            child: const AppBody(),
          ),
        ),
      ),
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// The body of this app.
class AppBody extends StatelessWidget {
  /// Creates a new [AppBody].
  const AppBody({super.key});

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
    var queryData = MediaQuery.of(context);
    var deviceWidth = queryData.size.width;
    var containerWidth = _getContainerWidth(deviceWidth);

    return Container(
      width: containerWidth,
      margin: const EdgeInsets.symmetric(vertical: 30),
      child: const RecipeInputForm(),
    );
  }
}
