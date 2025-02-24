import 'package:intl/intl.dart' show NumberFormat;

import 'models/ingredient.dart';
import 'models/recipe.dart';
import 'models/recipe_collection_result.dart';
import 'recipe_controller/recipe_tools.dart';

/// Creates different representations of the passed [Recipe]s.
///
/// The [RecipeCollectionResult] contains strings with different
/// representations.
RecipeCollectionResult createCollectionResultFromRecipes(List<Recipe> recipes) {
  var mergedIngredients =
      mergeIngredients(
        recipes.expand<Ingredient>((recipe) => recipe.ingredients).toList(),
      ).toList();
  var ingredientsSortedByAmount = mergedIngredients..sort((a, b) => b.amount.compareTo(a.amount));

  var resultSortedByAmountText = ingredientsSortedByAmount.map(_formatIngredient).join("\n");

  return RecipeCollectionResult(resultSortedByAmount: resultSortedByAmountText);
}

String _formatIngredient(Ingredient ingredient) {
  var result = "";
  if (ingredient.amount > 0) {
    var formatter =
        NumberFormat()
          ..minimumFractionDigits = 0
          ..maximumFractionDigits = 2;

    result += "${formatter.format(ingredient.amount)} ";
  }
  if (ingredient.unit.isNotEmpty) {
    result += "${ingredient.unit} ";
  }
  return result + ingredient.name;
}
