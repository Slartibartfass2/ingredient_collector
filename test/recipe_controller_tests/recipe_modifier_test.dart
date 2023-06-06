import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/recipe.dart';
import 'package:ingredient_collector/src/models/recipe_modification.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_modifier.dart';

void main() {
  test('When recipe is modified, then modification is applied', () {
    var recipe = const Recipe(
      ingredients: [
        Ingredient(amount: 1, unit: "g", name: "Test Ingredient"),
      ],
      name: "Test Recipe",
      servings: 2,
    );

    var modification = const RecipeModification(
      servings: 4,
      modifiedIngredients: [
        Ingredient(amount: 10, unit: "kg", name: "Test Ingredient"),
      ],
    );

    var modifiedRecipe = modifyRecipe(
      recipe: recipe,
      modification: modification,
    );

    expect(modifiedRecipe.name, "Test Recipe");
    expect(modifiedRecipe.servings, 2);
    expect(modifiedRecipe.ingredients.length, 1);
    var ingredient = modifiedRecipe.ingredients.first;
    expect(ingredient.name, "Test Ingredient");
    expect(ingredient.amount, 5);
    expect(ingredient.unit, "kg");
  });
}
