import 'package:intl/intl.dart';

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
  try {
    return NumberFormat().parse(amountString).toDouble();

    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    // When the string can't be parsed, try other parsing methods
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