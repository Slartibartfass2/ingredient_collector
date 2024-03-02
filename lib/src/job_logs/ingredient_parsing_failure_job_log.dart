part of job_log;

/// [JobLog] for when the parsing of an ingredient fails.
class IngredientParsingFailureJobLog extends JobLog {
  /// Url of the recipe that could not be parsed.
  final String recipeUrl;

  /// Creates a [IngredientParsingFailureJobLog] object.
  IngredientParsingFailureJobLog({required this.recipeUrl})
      : super(
          type: JobLogType.error,
          title: LocaleKeys.parsing_messages_ingredient_failure_title.tr(),
          message: LocaleKeys.parsing_messages_ingredient_failure_message.tr(
            namedArgs: {'recipeUrl': recipeUrl},
          ),
        );
}
