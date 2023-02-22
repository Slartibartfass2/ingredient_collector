import 'package:freezed_annotation/freezed_annotation.dart';

import 'ingredient.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

/// Data class which holds information about a single recipe.
///
/// The informations consists of a list of [ingredients], the [name] of the
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

  /// Parses [Recipe] object from json map.
  factory Recipe.fromJson(Map<String, Object?> json) => _$RecipeFromJson(json);
}
