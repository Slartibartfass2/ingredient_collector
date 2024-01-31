import 'package:freezed_annotation/freezed_annotation.dart';

import 'ingredient.dart';

part 'recipe.freezed.dart';

/// Data class that holds information about a single recipe.
///
/// The information consists of a list of [ingredients], the [name] of the
/// recipe and the amount of [servings].
@freezed
class Recipe with _$Recipe {
  /// Creates [Recipe] object.
  const factory Recipe({
    /// List of ingredients.
    required List<Ingredient> ingredients,

    /// Name of this recipe.
    required String name,

    /// Amount of servings.
    required int servings,
  }) = _Recipe;

  /// Creates a copy of this recipe with the passed [servings].
  ///
  /// The ingredients are adjusted to the new amount of servings.
  factory Recipe.withServings(Recipe recipe, int servings) {
    var ratio = servings / recipe.servings;
    return recipe.copyWith(
      ingredients: recipe.ingredients
          .map(
            (ingredient) =>
                ingredient.copyWith(amount: ingredient.amount * ratio),
          )
          .toList(),
      servings: servings,
    );
  }
}
