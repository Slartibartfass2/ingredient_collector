import 'package:flutter/cupertino.dart' show visibleForTesting;
import 'package:html/dom.dart';

import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/meta_data_logs/meta_data_log.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';
import 'parsing_helper.dart';
import 'wordpress_ingredient_parsing.dart';

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
    return RecipeParsingResult(
      metaDataLogs: [
        CompleteFailureMetaDataLog(recipeUrl: recipeParsingJob.url),
      ],
    );
  }

  var recipeName = recipeNameElements.first.text.trim();
  var recipeServings = int.parse(servingsElements.first.text);
  var servingsMultiplier = recipeParsingJob.servings / recipeServings;

  return createResultFromIngredientParsing(
    ingredientContainers,
    recipeParsingJob,
    servingsMultiplier,
    recipeName,
    parseIngredient,
  );
}

/// Parses an html [Element] representing an [Ingredient].
///
/// If the parsing fails the ingredient in [IngredientParsingResult] will be
/// null and a suitable log will be returned.
@visibleForTesting
IngredientParsingResult parseIngredient(
  Element element,
  double servingsMultiplier,
  String recipeUrl,
  String? language,
) =>
    parseWordPressIngredient(
      element,
      servingsMultiplier,
      recipeUrl,
      language,
    );
