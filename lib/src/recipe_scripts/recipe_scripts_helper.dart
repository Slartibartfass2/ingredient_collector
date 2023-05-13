import 'package:easy_localization/easy_localization.dart';

import '../../l10n/locale_keys.g.dart';
import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/meta_data_logs/meta_data_log.dart';
import '../models/recipe_parsing_job.dart';

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
