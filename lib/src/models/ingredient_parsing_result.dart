import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../job_logs/job_log.dart';
import 'ingredient.dart';

part 'ingredient_parsing_result.freezed.dart';

/// Data class that represents the result of parsing a ingredient html element.
@freezed
sealed class IngredientParsingResult with _$IngredientParsingResult {
  /// Creates [IngredientParsingResult] object.
  const factory IngredientParsingResult({
    /// Optionally parsed ingredient.
    @Default([]) List<Ingredient> ingredients,

    /// Additional information about the parsing.
    @Default([]) List<JobLog> logs,
  }) = _IngredientParsingResult;
}
