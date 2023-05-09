import 'package:flutter/cupertino.dart' show visibleForTesting;
import 'package:intl/intl.dart' show NumberFormat;

import 'models/ingredient.dart';
import 'models/recipe.dart';
import 'models/recipe_collection_result.dart';

/// Creates different representations of the passed [Recipe]s.
///
/// The [RecipeCollectionResult] contains strings with different
/// representations.
RecipeCollectionResult createCollectionResultFromRecipes(
  List<Recipe> recipes,
) {
  var mergedIngredients = mergeIngredients(
    recipes.expand<Ingredient>((recipe) => recipe.ingredients).toList(),
  );
  var ingredientsSortedByAmount = mergedIngredients
    ..sort((a, b) => b.amount.compareTo(a.amount));

  var resultSortedByAmountText =
      ingredientsSortedByAmount.map(_formatIngredient).join("\n");

  return RecipeCollectionResult(
    resultSortedByAmount: resultSortedByAmountText,
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
      mergedIngredients[index] = ingredient.copyWith(amount: amount);
    }
  }

  return mergedIngredients;
}

String _formatIngredient(Ingredient ingredient) {
  var result = "";
  if (ingredient.amount > 0) {
    var formatter = NumberFormat()
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 2;

    result += "${formatter.format(ingredient.amount)} ";
  }
  if (ingredient.unit.isNotEmpty) {
    result += "${ingredient.unit} ";
  }
  return result + ingredient.name;
}
