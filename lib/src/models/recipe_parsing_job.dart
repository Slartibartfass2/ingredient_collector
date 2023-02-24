import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_parsing_job.freezed.dart';

/// Data class which holds the recipe [url], the amount of [servings] and the
/// [language] for a recipe to be parsed.
@freezed
class RecipeParsingJob with _$RecipeParsingJob {
  /// Creates [RecipeParsingJob] object.
  const factory RecipeParsingJob({
    /// URL of the recipe.
    required Uri url,

    /// Amount of servings.
    required int servings,

    /// Language
    String? language,
  }) = _RecipeParsingJob;
}
