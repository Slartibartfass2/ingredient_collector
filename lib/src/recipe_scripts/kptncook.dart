import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' show visibleForTesting;
import 'package:html/dom.dart';

import '../../l10n/locale_keys.g.dart';
import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/meta_data_log.dart';
import '../models/recipe.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';
import 'parsing_helper.dart';
import 'recipe_scripts_helper.dart';

/// Parses a [Document] from the KptnCook website to a recipe.
RecipeParsingResult parseKptnCookRecipe(
  Document document,
  RecipeParsingJob recipeParsingJob,
) {
  var recipeNameElements = document.getElementsByClassName("kptn-recipetitle");
  var servingsElements = document.getElementsByClassName("kptn-person-count");
  var listContainers = document.getElementsByClassName("col-md-offset-3");

  // Check whether every information is provided
  if (recipeNameElements.isEmpty ||
      servingsElements.isEmpty ||
      listContainers.length < 3 ||
      listContainers[2].children.length < 3) {
    return createFailedRecipeParsingResult(recipeParsingJob.url.toString());
  }

  var recipeName = recipeNameElements.first.text.trim();

  // Retrieve amount of servings
  var servingsPattern = RegExp("[0-9]+");
  var servingsDescriptionText = servingsElements.first.text;
  var recipeServingsMatch = servingsPattern.firstMatch(servingsDescriptionText);
  if (recipeServingsMatch == null || recipeServingsMatch.group(0) == null) {
    return createFailedRecipeParsingResult(recipeParsingJob.url.toString());
  }
  var recipeServings = num.parse(recipeServingsMatch.group(0)!);
  var servingsMultiplier = recipeParsingJob.servings / recipeServings;

  // Skip first two html elements which aren't ingredients
  var ingredientElements = listContainers[2].children.sublist(2);
  var ingredientParsingResults = ingredientElements
      .map(
        (element) => parseIngredient(
          element,
          servingsMultiplier,
          recipeParsingJob.url.toString(),
          language: recipeParsingJob.language,
        ),
      )
      .toList();

  var logs = ingredientParsingResults
      .map((result) => result.metaDataLogs)
      .expand((metaDataLogs) => metaDataLogs)
      .toList();

  var ingredients = ingredientParsingResults
      .map((result) => result.ingredient)
      .whereType<Ingredient>()
      .toList();

  var ingredientsWithoutAmount = ingredients
      .where((ingredient) => ingredient.amount == 0)
      .map((ingredient) => ingredient.name)
      .toList();
  var ingredientsWithoutAmountText = "";
  if (ingredientsWithoutAmount.isNotEmpty) {
    ingredientsWithoutAmountText = "'${ingredientsWithoutAmount.join("', '")}'";
    logs.add(
      MetaDataLog(
        type: MetaDataLogType.warning,
        title: LocaleKeys.parsing_messages_kptn_cook_warning_title.tr(
          namedArgs: {'recipeName': recipeName},
        ),
        message: LocaleKeys.parsing_messages_kptn_cook_warning_message.tr(
          namedArgs: {'ingredientsWithoutAmount': ingredientsWithoutAmountText},
        ),
      ),
    );
  }

  return RecipeParsingResult(
    recipe: Recipe(
      ingredients: ingredients,
      name: recipeName,
      servings: recipeParsingJob.servings,
    ),
    metaDataLogs: logs,
  );
}

@visibleForTesting

/// Parses an html [Element] representing an [Ingredient].
///
/// If the parsing fails the ingredient in [IngredientParsingResult] will be
/// null and a suitable log will be returned.
IngredientParsingResult parseIngredient(
  Element ingredientElement,
  double servingsMultiplier,
  String recipeUrl, {
  String? language,
}) {
  var amount = 0.0;
  var unit = "";
  var name = "";

  var nameElements =
      ingredientElement.getElementsByClassName("kptn-ingredient");
  if (nameElements.isNotEmpty) {
    name = nameElements.first.text.trim();
  } else {
    return createFailedIngredientParsingResult(recipeUrl);
  }

  var logs = <MetaDataLog>[];

  var measureElements =
      ingredientElement.getElementsByClassName("kptn-ingredient-measure");
  if (measureElements.isNotEmpty) {
    var amountUnitStrings = measureElements.first.text.trim().split(" ");
    var amountString = amountUnitStrings.first;
    var parsedAmount = tryParseAmountString(amountString, language: language);
    if (parsedAmount != null) {
      amount = parsedAmount * servingsMultiplier;
    } else {
      logs.add(
        createFailedAmountParsingMetaDataLog(
          recipeUrl,
          amountString,
          name,
        ),
      );
    }

    if (amountUnitStrings.length == 2) {
      unit = amountUnitStrings[1];
    }
  }

  return IngredientParsingResult(
    ingredient: Ingredient(amount: amount, unit: unit, name: name),
    metaDataLogs: logs,
  );
}
