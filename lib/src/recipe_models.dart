import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_models.freezed.dart';
part 'recipe_models.g.dart';

/// Data class which holds the recipe [url] and the amount of [servings]
@freezed
class RecipeInfo with _$RecipeInfo {
  /// Creates [RecipeInfo] object
  const factory RecipeInfo({
    /// URL of the recipe
    required Uri url,

    /// Amount of servings
    required int servings,
  }) = _RecipeInfo;

  /// Parses [Recipe] object from json string
  factory RecipeInfo.fromJson(Map<String, Object?> json) =>
      _$RecipeInfoFromJson(json);
}

/// Data class which holds information about a single recipe.
/// The informations consists of a list of [ingredients], the [name] of the
/// recipe and the amount of [servings]
@freezed
class Recipe with _$Recipe {
  /// Creates [Recipe] object
  const factory Recipe({
    /// List of ingredients
    required List<Ingredient> ingredients,

    /// Name of this recipe
    required String name,

    /// Amount of servings
    required int servings,
  }) = _Recipe;

  /// Parses [Recipe] object from json string
  factory Recipe.fromJson(Map<String, Object?> json) => _$RecipeFromJson(json);
}

/// Data class which holds information about a single ingredient.
/// The information consists of the [amount], the [unit] and the [name].
@freezed
class Ingredient with _$Ingredient {
  /// Creates [Ingredient] object
  const factory Ingredient({
    /// Amount of ingredient
    /// e.g. "2", "3.4"
    required double amount,

    /// Unit of ingredient
    /// e.g. "ml", "g", "oz"
    required String unit,

    /// Name of ingredient
    /// e.g. "Carrot", "Apple"
    required String name,
  }) = _Ingredient;

  /// Parses [Ingredient] object from json string
  factory Ingredient.fromJson(Map<String, Object?> json) =>
      _$IngredientFromJson(json);
}

/// Data class which holds different string representations of the recipe
/// collection result.
@freezed
class RecipeCollectionResult with _$RecipeCollectionResult {
  /// Creates [RecipeCollectionResult] object
  factory RecipeCollectionResult({
    required String resultSortedByAmount,
  }) = _RecipeCollectionResult;
}
