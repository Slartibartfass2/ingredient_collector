import 'package:flutter/cupertino.dart' show visibleForTesting;
import 'package:html/dom.dart';

import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/recipe.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';
import 'recipe_scripts_helper.dart';
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
  Element element,
  double servingsMultiplier,
  String recipeUrl, {
  String? language,
}) =>
    parseWordPressIngredient(
      element,
      servingsMultiplier,
      recipeUrl,
      language: language,
    );
