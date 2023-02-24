import 'package:freezed_annotation/freezed_annotation.dart';

import 'ingredient.dart';
import 'meta_data_log.dart';

part 'ingredient_parsing_result.freezed.dart';

/// Data class which represents the result of parsing a ingredient html element.
@freezed
class IngredientParsingResult with _$IngredientParsingResult {
  /// Creates [IngredientParsingResult] object.
  const factory IngredientParsingResult({
    /// Optionally parsed ingredient.
    Ingredient? ingredient,

    /// Additional informations about the parsing.
    required List<MetaDataLog> metaDataLogs,
  }) = _IngredientParsingResult;
}
