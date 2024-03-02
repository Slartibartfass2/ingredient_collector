part of job_log;

/// [JobLog] for when a [RecipeParsingJob] fails completely.
class CompleteFailureJobLog extends JobLog {
  /// Url of the recipe that could not be parsed.
  final Uri recipeUrl;

  /// Creates a [CompleteFailureJobLog] object.
  CompleteFailureJobLog({required this.recipeUrl})
      : super(
          type: JobLogType.error,
          title: LocaleKeys.parsing_messages_complete_failure_title.tr(),
          message: LocaleKeys.parsing_messages_complete_failure_message.tr(
            namedArgs: {'recipeUrl': recipeUrl.toString()},
          ),
        );
}
