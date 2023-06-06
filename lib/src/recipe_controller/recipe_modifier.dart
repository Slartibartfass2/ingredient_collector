import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_modification.dart';

/// Modifies the passed [recipe] with the passed [modification].
///
/// The [modification] is applied to the [recipe] and the modified recipe is
/// returned.
/// The [modification] is applied to an ingredient with the same name.
/// If the [modification] contains an ingredient that is not in the [recipe],
/// the ingredient is added to the [recipe].
/// The [modification] is applied to the [recipe] by adjusting the amount of
/// each ingredient to the new amount of servings.
/// The modified recipe has the same name and amount of servings as the
/// [recipe].
///
/// Example:
/// ```dart
/// var recipe = const Recipe(
///   ingredients: [
///     Ingredient(amount: 1, unit: "g", name: "Test Ingredient"),
///   ],
///   name: "Test Recipe",
///   servings: 2,
/// );
///
/// var modification = const RecipeModification(
///   servings: 4,
///   modifiedIngredients: [
///     Ingredient(amount: 10, unit: "kg", name: "Test Ingredient"),
///   ],
/// );
///
/// var modifiedRecipe = modifyRecipe(
///   recipe: recipe,
///   modification: modification,
/// );
/// ```
/// The modified recipe will be:
/// ```dart
/// Recipe(
///   ingredients: [
///     Ingredient(amount: 5, unit: "kg", name: "Test Ingredient"),
///   ],
///   name: "Test Recipe",
///   servings: 2,
/// );
/// ```
Recipe modifyRecipe({
  required Recipe recipe,
  required RecipeModification modification,
}) {
  var ratio = recipe.servings / modification.servings;

  var modifiedIngredients = modification.modifiedIngredients;
  var newIngredients = recipe.ingredients
      .map(
        (ingredient) => modifiedIngredients.firstWhere(
          (modifiedIngredient) => modifiedIngredient.name == ingredient.name,
          orElse: () => ingredient.copyWith(amount: ingredient.amount / ratio),
        ),
      )
      .map((ingredient) => _multiplyIngredient(ingredient, ratio))
      .toList()
    ..addAll(
      modifiedIngredients
          .where(
            (modifiedIngredient) => !recipe.ingredients.any(
              (ingredient) => ingredient.name == modifiedIngredient.name,
            ),
          )
          .map((ingredient) => _multiplyIngredient(ingredient, ratio)),
    );

  return recipe.copyWith(
    ingredients: newIngredients,
  );
}

Ingredient _multiplyIngredient(Ingredient ingredient, double factor) =>
    ingredient.copyWith(amount: ingredient.amount * factor);
