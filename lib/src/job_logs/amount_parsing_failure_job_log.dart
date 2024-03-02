part of job_log;

/// [JobLog] for when the parsing of an amount string fails.
class AmountParsingFailureJobLog extends JobLog {
  /// Url of the recipe that could not be parsed.
  final String recipeUrl;

  /// Amount string that could not be parsed.
  final String amountString;

  /// Name of the ingredient that could not be parsed.
  final String ingredientName;

  /// Creates a [AmountParsingFailureJobLog] object.
  AmountParsingFailureJobLog({
    required this.recipeUrl,
    required this.amountString,
    required this.ingredientName,
  }) : super(
          type: JobLogType.error,
          title: LocaleKeys.parsing_messages_amount_failure_title.tr(),
          message: LocaleKeys.parsing_messages_amount_failure_message.tr(
            namedArgs: {
              'recipeUrl': recipeUrl,
              'amountString': amountString,
              'ingredientName': ingredientName,
            },
          ),
        );
}
