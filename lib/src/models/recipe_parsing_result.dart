import 'package:freezed_annotation/freezed_annotation.dart';

import '../meta_data_logs/meta_data_log.dart';
import 'recipe.dart';
import 'recipe_parsing_job.dart';

part 'recipe_parsing_result.freezed.dart';

/// Data class that represents the result of a [RecipeParsingJob].
@freezed
class RecipeParsingResult with _$RecipeParsingResult {
  /// Creates [RecipeParsingResult] object.
  const factory RecipeParsingResult({
    /// Optionally parsed recipe.
    Recipe? recipe,

    /// Additional informations about the parsing.
    required List<MetaDataLog> metaDataLogs,

    /// Whether the recipe was modified.
    @Default(false) bool wasModified,
  }) = _RecipeParsingResult;
}
