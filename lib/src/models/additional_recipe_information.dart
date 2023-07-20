import 'package:freezed_annotation/freezed_annotation.dart';

import 'recipe_modification.dart';

part 'additional_recipe_information.freezed.dart';
part 'additional_recipe_information.g.dart';

/// Data class that represents additional information about a recipe.
///
/// The information consists of a [note] and a [recipeModification].
/// The [note] can contain additional information that is not related to the
/// ingredients of the recipe e.g. "4 servings is not enough for two people,
/// use 8 instead!".
///
/// The [recipeModification] can contain information
/// about a modification to the recipe.
/// A modification is applied to an ingredient with the same name.
/// For example this could be doubling the amount of an ingredient.
@freezed
class AdditionalRecipeInformation with _$AdditionalRecipeInformation {
  /// Creates [AdditionalRecipeInformation] object.
  const factory AdditionalRecipeInformation({
    /// URL of the recipe website this additional information belongs to.
    required String recipeUrlOrigin,

    /// Name of the recipe this additional information belongs to.
    required String recipeName,

    /// The note.
    ///
    /// For example "4 servings is not enough for two people, use 8 instead!".
    @Default("") String note,

    /// The recipe modification.
    RecipeModification? recipeModification,
  }) = _AdditionalRecipeInformation;

  /// Creates [AdditionalRecipeInformation] object from JSON.
  factory AdditionalRecipeInformation.fromJson(Map<String, dynamic> json) =>
      _$AdditionalRecipeInformationFromJson(json);
}
