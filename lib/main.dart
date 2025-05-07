import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'src/pages/home_page.dart';
import 'src/supported_locale.dart';

/// The title of this app.
const appTitle = 'Ingredient Collector';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales:
          SupportedLocale.values.map((supportedLocale) => supportedLocale.locale).toList(),
      path: 'resources/langs',
      fallbackLocale: SupportedLocale.english.locale,
      useOnlyLangCode: true,
      child: const IngredientCollectorApp(),
    ),
  );
}

/// The [IngredientCollectorApp].
class IngredientCollectorApp extends StatelessWidget {
  /// Creates a new [IngredientCollectorApp].
  const IngredientCollectorApp({super.key});

  @override
  Widget build(BuildContext context) => ShadApp.material(
    home: const HomePage(),
    title: appTitle,
    materialThemeBuilder:
        (context, theme) => ThemeData(useMaterial3: false, primarySwatch: Colors.blue),
    locale: context.locale,
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    debugShowCheckedModeBanner: false,
  );
}
