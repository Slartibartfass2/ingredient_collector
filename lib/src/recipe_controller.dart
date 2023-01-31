import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:puppeteer/puppeteer.dart';

import 'recipe_models.dart';

const _scriptBasePath = 'lib/src/recipe-scripts/';

final Map<String, String> _scriptPathMap = {
  'mobile.kptncook.com': 'kptncook.js',
};

/// Collects ingredients from passed [recipes].
///
/// Optional [language] is set as browser language.
Future<RecipeCollectionResult> collectIngredients(
  List<RecipeData> recipes, [
  String? language,
]) async {
  var headers = <String, String>{};

  if (language != null) {
    headers['Accept-Language'] = 'language';
  }

  // Launch browser and open new tab
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.setExtraHTTPHeaders(headers);

  // Call scripts for each recipe
  var results = <Recipe>[];

  for (var recipe in recipes) {
    // Get recipe script
    // TODO: Give not-supported feedback when host is not in map
    var scriptPath = _scriptBasePath + (_scriptPathMap[recipe.url.host] ?? '');
    var scriptFilePath =
        Uri(path: scriptPath).toFilePath(windows: Platform.isWindows);
    var scriptFile = await File(scriptFilePath).readAsString();

    // Go to URL and execute script
    await page.goto(recipe.url.toString(), wait: Until.networkIdle);
    var result = await page.evaluate(scriptFile, args: [recipe.servings]);

    // Parse result from json and add to list
    results.add(Recipe.fromJson(result));
  }

  await browser.close();
  return _createCollectionResultFromRecipes(results);
}

RecipeCollectionResult _createCollectionResultFromRecipes(
  List<Recipe> recipes,
) {
  var mergedIngredients = mergeIngredients(
    recipes.expand<Ingredient>((recipe) => recipe.ingredients).toList(),
  );
  var ingredientsSortedByAmount = mergedIngredients
    ..sort((a, b) => b.amount.compareTo(a.amount));

  return RecipeCollectionResult(
    resultSortedByAmount:
        _convertIngredientsToString(ingredientsSortedByAmount),
  );
}

@visibleForTesting

/// Merges the [Ingredient]s in the passed list to a list of unique
/// [Ingredient]s.
///
/// [Ingredient]s with the same name and unit are merged so that the amount is
/// added together e.g. 4 g Sugar and 8 g Sugar results in 12 g Sugar.
List<Ingredient> mergeIngredients(List<Ingredient> ingredients) {
  var mergedIngredients = <Ingredient>[];

  for (var ingredient in ingredients) {
    var index = mergedIngredients.indexWhere(
      (element) =>
          ingredient.name == element.name && ingredient.unit == element.unit,
    );

    if (index == -1) {
      mergedIngredients.add(ingredient);
    } else {
      var amount = mergedIngredients[index].amount + ingredient.amount;
      mergedIngredients[index] = Ingredient(
        amount: amount,
        unit: ingredient.unit,
        name: ingredient.name,
      );
    }
  }

  return mergedIngredients;
}

String _convertIngredientsToString(List<Ingredient> ingredients) {
  var result = "";
  for (var ingredient in ingredients) {
    if (ingredient.amount > 0) {
      var formatter = NumberFormat()
        ..minimumFractionDigits = 0
        ..maximumFractionDigits = 2;

      result += "${formatter.format(ingredient.amount)} ";
    }
    if (ingredient.unit.isNotEmpty) {
      result += "${ingredient.unit} ";
    }
    result += "${ingredient.name}\n";
  }
  return result;
}
