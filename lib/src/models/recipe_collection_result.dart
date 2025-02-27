import 'package:freezed_annotation/freezed_annotation.dart';

import 'output_format.dart';

part 'recipe_collection_result.freezed.dart';

/// Data class that holds different string representations of the recipe
/// collection result.
@freezed
class RecipeCollectionResult with _$RecipeCollectionResult {
  /// Creates [RecipeCollectionResult] object.
  const factory RecipeCollectionResult({
    /// Recipe ingredients according to the output format.
    required Map<OutputFormat, String> outputFormats,
  }) = _RecipeCollectionResult;
}
