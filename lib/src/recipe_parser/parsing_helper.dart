import 'package:html/dom.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../models/ingredient_parsing_result.dart';
import '../models/recipe.dart';
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
/// The [amountString] is parsed according to the [language].
double? tryParseAmountString(String amountString, String language) {
  try {
    return NumberFormat.decimalPattern(language).parse(amountString).toDouble();
  } on FormatException {
    // When the string can't be parsed, try other parsing methods
  }

  var words = amountString.split(RegExp(r"\s+"));
  if (words.length == 1) {
    return _tryParseSingleWordAmount(words.first, language);
  }
  return _tryParseMultipleWordsAmount(words, language);
}

double? _tryParseSingleWordAmount(String word, String language) {
  // When string is range return middle
  var range = _tryGetRange(word, language);
  if (range != null) {
    return range;
  }

  var fractionWithSlash = _tryGetFractionWithSlash(word, language);
  if (fractionWithSlash != null) {
    return fractionWithSlash;
  }

  if (fractions.containsKey(word)) {
    return fractions[word];
  }

  var numberInParentheses = _tryGetNumberInParentheses(word, language);
  if (numberInParentheses != null) {
    return numberInParentheses;
  }

  if (word.toLowerCase().contains("optional")) {
    return 0;
  }

  return null;
}

double? _tryParseMultipleWordsAmount(List<String> words, String language) {
  var parsedWords = words.map((word) => tryParseAmountString(word, language)).whereType<double>();

  // Sum up values
  if (parsedWords.length == words.length) {
    return parsedWords.reduce((value1, value2) => value1 + value2);
  }

  // Sometimes there's a leading word e.g. approx. or ca.
  if (parsedWords.length == 1) {
    return parsedWords.first;
  }

  return null;
}

/// Tries to parse a range from the passed [text] e.g. 1-3.
double? _tryGetRange(String text, String language) {
  var parts = text.split("-");

  if (parts.length != 2) {
    return null;
  }

  var start = tryParseAmountString(parts.first.trim(), language);
  var end = tryParseAmountString(parts[1].trim(), language);

  if (start == null || end == null) {
    return null;
  }

  return (end + start) / 2;
}

/// Tries to parse a fraction with '/' from the passed [text] e.g. 1/3.
double? _tryGetFractionWithSlash(String text, String language) {
  var parts = text.split(RegExp("[/⁄]"));

  if (parts.length != 2) {
    return null;
  }

  var numerator = tryParseAmountString(parts.first.trim(), language);
  var denominator = tryParseAmountString(parts[1].trim(), language);

  if (numerator == null || denominator == null) {
    return null;
  }

  return numerator / denominator;
}

/// Tries to parse a number in parentheses from the passed [text] e.g. (2).
double? _tryGetNumberInParentheses(String text, String language) {
  var pattern = RegExp("([0-9]+)");
  var match = pattern.firstMatch(text)?.group(0);
  if (match == null) return null;
  return tryParseAmountString(match, language);
}

/// Parses the passed [elements] using the [parseIngredientMethod].
RecipeParsingResult createResultFromIngredientParsing(
  List<Element> elements,
  RecipeParsingJob job,
  double servingsMultiplier,
  String recipeName,
  IngredientParsingResult Function(Element, double, Uri, String) parseIngredientMethod,
) {
  var ingredientParsingResults =
      elements
          .map(
            (element) => parseIngredientMethod(element, servingsMultiplier, job.url, job.language),
          )
          .toList();

  var logs =
      ingredientParsingResults.map((result) => result.logs).expand((jobLogs) => jobLogs).toList();

  var ingredients =
      ingredientParsingResults
          .map((result) => result.ingredients)
          .expand((ingredient) => ingredient)
          .toList();

  return RecipeParsingResult(
    recipe: Recipe(ingredients: ingredients, name: recipeName, servings: job.servings),
    logs: logs,
  );
}
