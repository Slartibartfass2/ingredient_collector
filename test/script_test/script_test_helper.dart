import 'package:flutter_test/flutter_test.dart' show fail;
import 'package:ingredient_collector/src/recipe_models.dart'
    show Recipe, Ingredient;

void expectIngredient(
  Recipe recipe,
  String name, {
  double amount = 0.0,
  String unit = "",
}) {
  var ingredient = Ingredient(amount: amount, unit: unit, name: name);
  var isInRecipe = recipe.ingredients.contains(ingredient);
  if (!isInRecipe) {
    fail("$ingredient was not found in the recipe");
  }
}
