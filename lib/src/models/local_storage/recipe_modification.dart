import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/ingredient.dart';

part 'recipe_modification.freezed.dart';
part 'recipe_modification.g.dart';

/// Data class that represents a modification to a recipe.
@freezed
class RecipeModification with _$RecipeModification {
  /// Creates [RecipeModification] object.
  const factory RecipeModification({
    /// The number of servings as reference for this modification.
    required int servings,

    /// The modified ingredients.
    ///
    /// A modification is applied to an ingredient with the same name.
    required Iterable<Ingredient> modifiedIngredients,
  }) = _RecipeModification;

  /// Creates [RecipeModification] object from JSON.
  factory RecipeModification.fromJson(Map<String, dynamic> json) =>
      _$RecipeModificationFromJson(json);
}
