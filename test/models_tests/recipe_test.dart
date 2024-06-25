import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/models/domain/ingredient.dart';
import 'package:ingredient_collector/src/models/domain/recipe.dart';

void main() {
  test(
    'When Recipe.withServings is called, then servings and amount of '
    'ingredients are adjusted',
    () {
      var recipe = const Recipe(
        ingredients: [
          Ingredient(amount: 1, unit: 'unit a', name: 'a'),
          Ingredient(amount: 2, unit: 'unit b', name: 'b'),
          Ingredient(amount: 3, unit: 'unit c', name: 'c'),
        ],
        name: "test recipe",
        servings: 2,
      );

      var newRecipe = Recipe.withServings(recipe, 4);

      expect(newRecipe.servings, 4);
      expect(newRecipe.ingredients.first.amount, 2);
      expect(newRecipe.ingredients[1].amount, 4);
      expect(newRecipe.ingredients[2].amount, 6);
    },
  );
}
