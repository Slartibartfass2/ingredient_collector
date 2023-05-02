import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'src/widgets/recipe_input_form.dart';

const appTitle = 'Ingredient Collector';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', ''),
        Locale('de', ''),
      ],
      useOnlyLangCode: true,
      fallbackLocale: const Locale('en', ''),
      path: 'resources/langs',
      child: const IngredientCollectorApp(),
    ),
  );
}

/// The [IngredientCollectorApp].
class IngredientCollectorApp extends StatelessWidget {
  /// Creates a new [IngredientCollectorApp].
  const IngredientCollectorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(appTitle),
          ),
          body: SingleChildScrollView(
            child: Container(
              alignment: Alignment.topCenter,
              child: const AppBody(),
            ),
          ),
        ),
      );
}

class AppBody extends StatelessWidget {
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
      margin: const EdgeInsets.only(top: 30, bottom: 30),
      child: const RecipeInputForm(),
    );
  }
}
