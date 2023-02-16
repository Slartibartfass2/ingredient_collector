import 'package:html/dom.dart';

import '../models/ingredient.dart';
import '../models/meta_data_log.dart';
import '../models/recipe.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';

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
    return createFailedRecipeParsingResult(recipeParsingJob.url);
  }

  var recipeName = recipeNameElements.first.text.trim();

  // Retrieve amount of servings
  var servingsPattern = RegExp("[0-9]+");
  var servingsDescriptionText = servingsElements.first.text;
  var recipeServingsMatch = servingsPattern.firstMatch(servingsDescriptionText);
  if (recipeServingsMatch == null || recipeServingsMatch.group(0) == null) {
    return createFailedRecipeParsingResult(recipeParsingJob.url);
  }
  var recipeServings = num.parse(recipeServingsMatch.group(0)!);
  var servingsMultiplier = recipeParsingJob.servings / recipeServings;

  var ingredients = <Ingredient>[];

  // Parse each ingredient and store it in the list
  // Skip first two html elements which aren't ingredients
  for (var ingredient in listContainers[2].children.sublist(2)) {
    var amount = 0.0;
    var unit = "";
    var name = "";

    var nameElements = ingredient.getElementsByClassName("kptn-ingredient");

    if (nameElements.isNotEmpty) {
      name = nameElements.first.text.trim();
    }

    var measureElements =
        ingredient.getElementsByClassName("kptn-ingredient-measure");

    if (measureElements.isNotEmpty) {
      var amountUnitStrings = measureElements.first.text.trim().split(" ");
      amount = double.parse(amountUnitStrings.first) * servingsMultiplier;

      if (amountUnitStrings.length == 2) {
        unit = amountUnitStrings[1];
      }
    }

    ingredients.add(Ingredient(amount: amount, unit: unit, name: name));
  }

  return RecipeParsingResult(
    recipe: Recipe(
      ingredients: ingredients,
      name: recipeName,
      servings: recipeParsingJob.servings,
    ),
    metaDataLog: [
      const MetaDataLog(
        type: MetaDataLogType.warning,
        title: "KptnCook recipe is incomplete",
        message: 'A KptnCook recipe has two sections: \'You need\' and '
            '\'You might have this at home\'. The ingredients in the second '
            'section do not contain quantities and must be completed to get the'
            ' whole recipe.',
      ),
    ],
  );
}
