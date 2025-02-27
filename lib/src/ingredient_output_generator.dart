import 'package:intl/intl.dart' show NumberFormat;

import 'models/ingredient.dart';
import 'models/output_format.dart';
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

  var outputs = OutputFormat.values.map(
    (format) => MapEntry(format, _formatIngredients(ingredientsSortedByAmount, format)),
  );

  return RecipeCollectionResult(outputFormats: Map.fromEntries(outputs));
}

String _formatIngredients(List<Ingredient> ingredients, OutputFormat format) =>
    ingredients.map((ingredient) => _formatIngredient(ingredient, format)).join("\n");

String _formatIngredient(Ingredient ingredient, OutputFormat format) {
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

  var plainText = result + ingredient.name;
  return switch (format) {
    OutputFormat.plaintext => plainText,
    OutputFormat.markdown => "- [ ] $plainText",
  };
}
