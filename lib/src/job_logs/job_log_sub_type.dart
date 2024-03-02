part of job_log;

/// Types of [SimpleJobLog].
enum JobLogSubType {
  /// When a CORS plugin is missing on web.
  missingCorsPlugin(JobLogType.error),

  /// When the HTTP request failed.
  ingredientParsingFailure(JobLogType.error),

  /// When a [RecipeParsingJob] fails because the url is not supported.
  deliberatelyNotSupportedUrl(JobLogType.error),

  /// When a [RecipeParsingJob] fails completely.
  completeFailure(JobLogType.error);

  const JobLogSubType(this.type);

  /// Generic log type of this sub type.
  final JobLogType type;
}
