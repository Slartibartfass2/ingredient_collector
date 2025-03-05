import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../job_logs/job_log.dart';
import 'recipe.dart';
import 'recipe_parsing_job.dart';

part 'recipe_parsing_result.freezed.dart';

/// Data class that represents the result of a [RecipeParsingJob].
@freezed
sealed class RecipeParsingResult with _$RecipeParsingResult {
  /// Creates [RecipeParsingResult] object.
  const factory RecipeParsingResult({
    /// Optionally parsed recipe.
    Recipe? recipe,

    /// Additional information about the parsing.
    required List<JobLog> logs,

    /// Whether the recipe was modified.
    @Default(false) bool wasModified,
  }) = _RecipeParsingResult;
}
