import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_collection_result.freezed.dart';

/// Data class that holds different string representations of the recipe
/// collection result.
@freezed
class RecipeCollectionResult with _$RecipeCollectionResult {
  /// Creates [RecipeCollectionResult] object.
  const factory RecipeCollectionResult({
    /// Representation with the ingredients sorted by amount.
    required String resultSortedByAmount,
  }) = _RecipeCollectionResult;
}
