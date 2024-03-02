part of job_log;

/// [JobLog] for when a CORS plugin is missing on web.
class MissingCorsPluginJobLog extends JobLog {
  /// Url of the recipe that could not be parsed.
  final Uri recipeUrl;

  /// Creates a [MissingCorsPluginJobLog] object.
  MissingCorsPluginJobLog({required this.recipeUrl})
      : super(
          type: JobLogType.error,
          title: LocaleKeys.missing_cors_plugin_title.tr(),
          message: LocaleKeys.missing_cors_plugin_message.tr(
            namedArgs: {'recipeUrl': recipeUrl.toString()},
          ),
        );
}
