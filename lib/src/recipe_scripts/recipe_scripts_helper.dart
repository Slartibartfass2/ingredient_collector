import 'package:easy_localization/easy_localization.dart';

import '../../l10n/locale_keys.g.dart';
import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/meta_data_log.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';

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

/// Creates a [RecipeParsingResult] for when the user misses a CORS plugin on
/// web, which results in an exception when making a request.
///
/// The [recipeUrl] is displayed to the user in the message.
RecipeParsingResult createMissingCorsPluginResult(String recipeUrl) =>
    RecipeParsingResult(
      metaDataLogs: [
        MetaDataLog(
          type: MetaDataLogType.error,
          title: LocaleKeys.missing_cors_plugin_title.tr(),
          message: LocaleKeys.missing_cors_plugin_message.tr(
            namedArgs: {'recipeUrl': recipeUrl},
          ),
        ),
      ],
    );

/// Creates a [RecipeParsingResult] for when a [RecipeParsingJob] fails
/// because the recipe website is deliberately not supported.
///
/// The [recipeUrl] is displayed to the user in the message.
RecipeParsingResult createDeliberatelyNotSupportedUrlParsingResult(
  String recipeUrl,
) =>
    RecipeParsingResult(
      metaDataLogs: [
        MetaDataLog(
          type: MetaDataLogType.error,
          title: LocaleKeys.parsing_messages_deliberately_unsupported_url_title
              .tr(),
          message: LocaleKeys
              .parsing_messages_deliberately_unsupported_url_message
              .tr(
            namedArgs: {'recipeUrl': recipeUrl},
          ),
        ),
      ],
    );

/// Creates a [MetaDataLog] for when a [RecipeParsingJob] fails on parsing an
/// amount string.
///
/// The [recipeUrl], [amountString] and [ingredientName] are displayed to the
/// user in the message.
MetaDataLog createFailedAmountParsingMetaDataLog(
  String recipeUrl,
  String amountString,
  String ingredientName,
) =>
    MetaDataLog(
      type: MetaDataLogType.error,
      title: LocaleKeys.parsing_messages_amount_failure_title.tr(),
      message: LocaleKeys.parsing_messages_amount_failure_message.tr(
        namedArgs: {
          'recipeUrl': recipeUrl,
          'amountString': amountString,
          'ingredientName': ingredientName,
        },
      ),
    );

/// Creates a [IngredientParsingResult] for when the parsing of a html element
/// representing an [Ingredient] fails.
///
/// The [recipeUrl] is displayed to the user in the message.
IngredientParsingResult createFailedIngredientParsingResult(
  String recipeUrl,
) =>
    IngredientParsingResult(
      metaDataLogs: [
        MetaDataLog(
          type: MetaDataLogType.error,
          title: LocaleKeys.parsing_messages_ingredient_failure_title.tr(),
          message: LocaleKeys.parsing_messages_ingredient_failure_message.tr(
            namedArgs: {'recipeUrl': recipeUrl},
          ),
        ),
      ],
    );
