import 'package:easy_localization/easy_localization.dart';

import '../../l10n/locale_keys.g.dart';
import '../models/ingredient.dart';
import '../models/ingredient_parsing_result.dart';
import '../models/meta_data_log.dart';
import '../models/recipe_parsing_job.dart';
import '../models/recipe_parsing_result.dart';

/// Mapping of fraction characters and there [double] values.
const fractions = {
  "¼": 0.25,
  "½": 0.5,
  "¾": 0.75,
  "⅐": 0.1429,
  "⅑": 0.1111,
  "⅒": 0.1,
  "⅓": 0.3333,
  "⅔": 0.6667,
  "⅕": 0.2,
  "⅖": 0.4,
  "⅗": 0.6,
  "⅘": 0.8,
  "⅙": 0.1667,
  "⅚": 0.8333,
  "⅛": 0.125,
  "⅜": 0.375,
  "⅝": 0.625,
  "⅞": 0.875,
};

/// Parses the passed [amountString] to the matching [double] value.
///
/// This includes parsing of ranges e.g. 2-3 -> 2.5 and fractions e.g. ⅕ -> 0.2.
double? tryParseAmountString(String amountString) {
  if (double.tryParse(amountString) != null) {
    return double.parse(amountString);
  }

  // When string is range return middle
  if (isRange(amountString)) {
    var parts = amountString.split("-");
    var lower = double.parse(parts[0].trim());
    var upper = double.parse(parts[1].trim());
    return (upper + lower) / 2;
  }

  if (fractions.containsKey(amountString)) {
    return fractions[amountString];
  }

  var words = amountString.split(" ");
  if (words.length > 1) {
    var parsedWords =
        words.map(tryParseAmountString).where((element) => element != null);

    // Sum up values
    if (parsedWords.length == words.length) {
      return parsedWords.reduce((value1, value2) => value1! + value2!);
    }

    // Sometimes there's a leading word e.g. approx. or ca.
    if (parsedWords.length == 1) {
      return parsedWords.first;
    }
  }

  return null;
}

/// Checks whether the passed [text] represents a range e.g. 1-3.
bool isRange(String text) {
  var pattern = RegExp(r"^[1-9][0-9]*-[1-9][0-9]*$");
  return pattern.hasMatch(text);
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
