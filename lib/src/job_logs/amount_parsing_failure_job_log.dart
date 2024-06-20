part of 'job_log.dart';

/// [JobLog] for when the parsing of an amount string fails.
class AmountParsingFailureJobLog extends JobLog {
  /// Url of [RecipeParsingJob].
  final Uri recipeUrl;

  /// Amount string that could not be parsed.
  final String amountString;

  /// Name of the ingredient that could not be parsed.
  final String ingredientName;

  /// Creates a [AmountParsingFailureJobLog] object.
  AmountParsingFailureJobLog({
    required this.recipeUrl,
    required this.amountString,
    required this.ingredientName,
  }) : super(type: JobLogType.error);

  @override
  String toString() =>
      "AmountParsingFailureJobLog(url=$recipeUrl, amount=$amountString, "
      "ingredientName=$ingredientName)";
}
