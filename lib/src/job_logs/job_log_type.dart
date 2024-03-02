part of job_log;

/// Type of [JobLog].
///
/// A different type leads to a different representation of the log to the user.
enum JobLogType {
  /// The result of the [RecipeParsingJob] isn't complete and the user may need
  /// to fetch missing information.
  ///
  /// For example information is missing.
  warning,

  /// There was an error while executing the [RecipeParsingJob].
  ///
  /// For example information can't be fetched, the html structure changed.
  error,

  /// A general information for the user.
  ///
  /// For example that the recipe was modified.
  info,
}
