import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_parsing_job.freezed.dart';
part 'recipe_parsing_job.g.dart';

/// Data class which holds the recipe [url] and the amount of [servings] for a
/// recipe to be parsed.
@freezed
class RecipeParsingJob with _$RecipeParsingJob {
  /// Creates [RecipeParsingJob] object.
  const factory RecipeParsingJob({
    /// URL of the recipe.
    required Uri url,

    /// Amount of servings.
    required int servings,
  }) = _RecipeParsingJob;

  /// Parses [RecipeParsingJob] object from json map.
  factory RecipeParsingJob.fromJson(Map<String, Object?> json) =>
      _$RecipeParsingJobFromJson(json);
}
