part of job_log;

/// [JobLog] for when the HTTP request failed.
class RequestFailureJobLog extends JobLog {
  /// Url of [RecipeParsingJob].
  final Uri recipeUrl;

  /// Status code of the HTTP request.
  final int statusCode;

  /// Response message of the HTTP request.
  final String responseMessage;

  /// Creates a [RequestFailureJobLog] object.
  RequestFailureJobLog({
    required this.recipeUrl,
    required this.statusCode,
    required this.responseMessage,
  }) : super(type: JobLogType.error);

  @override
  String toString() =>
      "RequestFailureJobLog(url=$recipeUrl, statusCode=$statusCode, "
      "message=$responseMessage)";
}
