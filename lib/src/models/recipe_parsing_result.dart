import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../l10n/locale_keys.g.dart';
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
    required List<MetaDataLog> metaDataLogs,
  }) = _RecipeParsingResult;

  /// Parses [RecipeParsingResult] object from json string.
  factory RecipeParsingResult.fromJson(Map<String, dynamic> json) =>
      _$RecipeParsingResultFromJson(json);
}

/// Creates a [RecipeParsingResult] for when a [RecipeParsingJob] fails
/// completely.
///
/// The [recipeUrl] is displayed to the user in the message.
RecipeParsingResult createFailedRecipeParsingResult(String recipeUrl) =>
    RecipeParsingResult(
      metaDataLogs: [
        MetaDataLog(
          type: MetaDataLogType.error,
          title: LocaleKeys.parsing_messages_complete_failure_title.tr(),
          message: LocaleKeys.parsing_messages_complete_failure_message.tr(
            namedArgs: {'recipeUrl': recipeUrl},
          ),
        ),
      ],
    );

/// Creates a [MetaDataLog] for when a [RecipeParsingJob] fails on parsing an
/// amount string.
///
/// The [recipeUrl], [amountString] and [ingredientName] is displayed to the
/// user in the message.
MetaDataLog createFailedAmountParsingMetaDataLog(
  String recipeUrl,
  String amountString,
  String ingredientName,
) =>
    MetaDataLog(
      type: MetaDataLogType.error,
      title: LocaleKeys.parsing_messages_amount_parsing_failure_title.tr(),
      message: LocaleKeys.parsing_messages_amount_parsing_failure_message.tr(
        namedArgs: {
          'recipeUrl': recipeUrl,
          'amountString': amountString,
          'ingredientName': ingredientName,
        },
      ),
    );
