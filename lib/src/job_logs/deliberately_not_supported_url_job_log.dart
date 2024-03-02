part of job_log;

/// [JobLog] for when a recipe url is deliberately not supported.
class DeliberatelyNotSupportedUrlJobLog extends JobLog {
  /// Url of the recipe that could not be parsed.
  final Uri recipeUrl;

  /// Creates a [DeliberatelyNotSupportedUrlJobLog] object.
  DeliberatelyNotSupportedUrlJobLog({required this.recipeUrl})
      : super(
          type: JobLogType.error,
          title: LocaleKeys.parsing_messages_deliberately_unsupported_url_title
              .tr(),
          message: LocaleKeys
              .parsing_messages_deliberately_unsupported_url_message
              .tr(
            namedArgs: {'recipeUrl': recipeUrl.toString()},
          ),
        );
}
