import 'package:html/dom.dart';

import '../recipe_models.dart';

/// Parses a [Document] from the KptnCook website to a recipe.
Recipe parseKptnCookRecipe(Document document, int servings) {
  var title =
      document.getElementsByClassName("kptn-recipetitle")[0].text.trim();
  var ingredients = <Ingredient>[];

  var list = document.getElementsByClassName("col-md-offset-3")[2].children;
  // Skip first two html elements which aren't ingredients
  var ingredientList = list.sublist(2);
  var recipeServings = num.parse(list[0].children[0].text.trim().split(" ")[1]);
  var servingsMultiplier = servings / recipeServings;

  // Parse each ingredient and store it in the list
  for (var ingredient in ingredientList) {
    var amount = 0.0;
    var unit = "";
    var name = "";

    var nameElements = ingredient.getElementsByClassName("kptn-ingredient");

    if (nameElements.isNotEmpty) {
      name = nameElements[0].text.trim();
    }

    var measureElements =
        ingredient.getElementsByClassName("kptn-ingredient-measure");

    if (measureElements.isNotEmpty) {
      var amountUnitStrings = measureElements[0].text.trim().split(" ");
      amount = double.parse(amountUnitStrings[0]) * servingsMultiplier;

      if (amountUnitStrings.length == 2) {
        unit = amountUnitStrings[1];
      }
    }

    ingredients.add(Ingredient(amount: amount, unit: unit, name: name));
  }

  return Recipe(ingredients: ingredients, name: title, servings: servings);
}
