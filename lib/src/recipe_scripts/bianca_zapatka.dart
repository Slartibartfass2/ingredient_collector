import 'package:flutter/cupertino.dart' show visibleForTesting;
import 'package:html/dom.dart';

import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/meta_data_log.dart';
import '../models/recipe.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';
import 'parsing_helper.dart';
import 'recipe_scripts_helper.dart';

/// Parses a [Document] from the Bianca Zapatka website to a recipe.
RecipeParsingResult parseBiancaZapatkaRecipe(
  Document document,
  RecipeParsingJob recipeParsingJob,
) {
  var recipeNameElements = document.getElementsByClassName("entry-title");
  var servingsElements =
      document.getElementsByClassName("wprm-recipe-servings");
  var ingredientContainers =
      document.getElementsByClassName("wprm-recipe-ingredient");

  if (recipeNameElements.isEmpty ||
      servingsElements.isEmpty ||
      ingredientContainers.isEmpty) {
    return createFailedRecipeParsingResult(recipeParsingJob.url.toString());
  }

  var recipeName = recipeNameElements.first.text.trim();
  var recipeServings = int.parse(servingsElements.first.text);
  var servingsMultiplier = recipeParsingJob.servings / recipeServings;

  var ingredientParsingResults = ingredientContainers
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
      .map((result) => result.ingredients)
      .expand((ingredient) => ingredient)
      .toList();

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
  var name = "";
  var nameElements =
      ingredientElement.getElementsByClassName("wprm-recipe-ingredient-name");
  if (nameElements.isNotEmpty) {
    var nameElement = nameElements.first;
    // Sometimes the name has a url reference in a <a> tag
    if (nameElement.children.isNotEmpty) {
      name = nameElement.children.map((e) => e.text).join();
    } else {
      name = nameElement.text.trim();
    }
  } else {
    return createFailedIngredientParsingResult(recipeUrl);
  }

  var logs = <MetaDataLog>[];

  var amount = 0.0;
  var amountElements =
      ingredientElement.getElementsByClassName("wprm-recipe-ingredient-amount");
  if (amountElements.isNotEmpty) {
    var amountElement = amountElements.first;
    var amountString = amountElement.text.trim();
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
  }

  var unit = "";
  var unitElements =
      ingredientElement.getElementsByClassName("wprm-recipe-ingredient-unit");
  if (unitElements.isNotEmpty) {
    var unitElement = unitElements.first;
    unit = unitElement.text.trim();
  }

  return IngredientParsingResult(
    ingredients: [
      Ingredient(amount: amount, unit: unit, name: name),
    ],
    metaDataLogs: logs,
  );
}
