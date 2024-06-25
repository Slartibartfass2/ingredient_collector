import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_parsing_job.freezed.dart';

/// Data class that holds the recipe [url], the amount of [servings] and the
/// [language] for a recipe to be parsed.
@freezed
class RecipeParsingJob with _$RecipeParsingJob {
  /// Creates [RecipeParsingJob] object.
  const factory RecipeParsingJob({
    /// ID of the recipe parsing job.
    required int id,

    /// URL of the recipe.
    required Uri url,

    /// Amount of servings.
    required int servings,

    /// The language that should be used to parse the recipe.
    @Default("") String language,
  }) = _RecipeParsingJob;
}
