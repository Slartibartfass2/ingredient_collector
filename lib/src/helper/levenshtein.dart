import 'dart:math';

/// Levenshtein algorithm implementation based on:
/// http://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_two_matrix_rows
/// Source: https://github.com/brinkler/levenshtein-dart/blob/a77f16f1701067c265dc4692f0c37abc1c3177de/lib/levenshtein.dart
int levenshtein(String sourceString, String targetString, {bool caseSensitive = true}) {
  if (!caseSensitive) {
    // ignore: parameter_assignments
    sourceString = sourceString.toLowerCase();
    // ignore: parameter_assignments
    targetString = targetString.toLowerCase();
  }

  if (sourceString == targetString) {
    return 0;
  }

  if (sourceString.isEmpty) {
    return targetString.length;
  }

  if (targetString.isEmpty) {
    return sourceString.length;
  }

  var v0 = List<int>.filled(targetString.length + 1, 0);
  var v1 = List<int>.filled(targetString.length + 1, 0);

  for (var i = 0; i < targetString.length + 1; i < i++) {
    v0[i] = i;
  }

  for (var i = 0; i < sourceString.length; i++) {
    v1[0] = i + 1;

    for (var j = 0; j < targetString.length; j++) {
      var cost = (sourceString[i] == targetString[j]) ? 0 : 1;
      v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
    }

    for (var j = 0; j < targetString.length + 1; j++) {
      v0[j] = v1[j];
    }
  }

  return v1[targetString.length];
}

/// Relative Levenshtein meaning the levenshtein distance divided by the target's length.
double relativeLevenshtein(String sourceString, String targetString, {bool caseSensitive = true}) {
  var distance = levenshtein(sourceString, targetString, caseSensitive: caseSensitive);
  return distance / targetString.length;
}
