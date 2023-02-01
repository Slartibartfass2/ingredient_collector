import 'package:html/dom.dart';
import 'package:optional/optional.dart';

import '../recipe_models.dart';

/// Parses a [Document] from the KptnCook website to a recipe.
Optional<Recipe> parseKptnCookRecipe(Document document, int servings) {
  var recipeNameElements = document.getElementsByClassName("kptn-recipetitle");
  var servingsElements = document.getElementsByClassName("kptn-person-count");
  var listContainers = document.getElementsByClassName("col-md-offset-3");

  // Check whether every information is provided
  if (recipeNameElements.isEmpty ||
      servingsElements.isEmpty ||
      listContainers.length < 3 ||
      listContainers[2].children.length < 3) {
    return const Optional.empty();
  }

  var recipeName = recipeNameElements.first.text.trim();

  // Retrieve amount of servings
  var servingsPattern = RegExp("[0-9]+");
  var servingsDescriptionText = servingsElements.first.text;
  var recipeServingsMatch = servingsPattern.firstMatch(servingsDescriptionText);
  if (recipeServingsMatch == null || recipeServingsMatch.group(0) == null) {
    return const Optional.empty();
  }
  var recipeServings = num.parse(recipeServingsMatch.group(0)!);
  var servingsMultiplier = servings / recipeServings;

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

  return Optional.of(
    Recipe(
      ingredients: ingredients,
      name: recipeName,
      servings: servings,
    ),
  );
}
