import 'package:html/dom.dart';

import '../models/ingredient.dart';
import '../models/meta_data_log.dart';
import '../models/recipe.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';
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

  var ingredients = <Ingredient>[];
  var logs = <MetaDataLog>[];

  // Parse each ingredient and store it in the list
  for (var ingredient in ingredientContainers) {
    var amount = 0.0;
    var unit = "";
    var name = "";

    var nameElements =
        ingredient.getElementsByClassName("wprm-recipe-ingredient-name");

    if (nameElements.isNotEmpty) {
      var nameElement = nameElements.first;
      // Sometimes the name has a url reference in a <a> tag
      if (nameElement.children.isNotEmpty) {
        nameElement = nameElement.children.first;
      }
      name = nameElement.text.trim();
    }

    var amountElements =
        ingredient.getElementsByClassName("wprm-recipe-ingredient-amount");

    if (amountElements.isNotEmpty) {
      var amountElement = amountElements.first;
      var parsedAmount = tryParseAmountString(amountElement.text.trim());
      if (parsedAmount != null) {
        amount = parsedAmount * servingsMultiplier;
      } else {
        logs.add(
          createFailedAmountParsingMetaDataLog(
            recipeParsingJob.url.toString(),
            amountElement.text.trim(),
            name,
          ),
        );
      }
    }

    var unitElements =
        ingredient.getElementsByClassName("wprm-recipe-ingredient-unit");

    if (unitElements.isNotEmpty) {
      var unitElement = unitElements.first;
      unit = unitElement.text.trim();
    }

    ingredients.add(Ingredient(amount: amount, unit: unit, name: name));
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
