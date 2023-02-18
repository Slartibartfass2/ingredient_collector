import 'package:freezed_annotation/freezed_annotation.dart';

import 'meta_data_log.dart';
import 'recipe.dart';
import 'recipe_parsing_job.dart';

part 'recipe_parsing_result.freezed.dart';
part 'recipe_parsing_result.g.dart';

/// Data class which represents the result of a [RecipeParsingJob].
@freezed
class RecipeParsingResult with _$RecipeParsingResult {
  /// Creates [RecipeParsingResult] object.
  const factory RecipeParsingResult({
    /// Optionally parsed recipe.
    Recipe? recipe,

    /// Additional informations about the parsing.
    required List<MetaDataLog> metaDataLog,
  }) = _RecipeParsingResult;

  /// Parses [RecipeParsingResult] object from json string.
  factory RecipeParsingResult.fromJson(Map<String, dynamic> json) =>
      _$RecipeParsingResultFromJson(json);
}

/// Creates a [RecipeParsingResult] for when a [RecipeParsingJob] fails
/// completely.
///
/// The [url] is displayed to the user in the message.
RecipeParsingResult createFailedRecipeParsingResult(Uri url) =>
    RecipeParsingResult(
      metaDataLog: [
        MetaDataLog(
          type: MetaDataLogType.error,
          title: "Parsing failed",
          message: "An error occured while parsing ${url.toString()}.",
        )
      ],
    );
