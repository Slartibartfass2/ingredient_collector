part of job_log;

/// [JobLog] for when the HTTP request failed.
class RequestFailureJobLog extends JobLog {
  /// Url of the recipe that could not be requested.
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
  }) : super(
          type: JobLogType.error,
          title: LocaleKeys.http_request_error_title.tr(),
          message: LocaleKeys.http_request_error_message.tr(
            namedArgs: {
              'recipeUrl': recipeUrl.toString(),
              'status': statusCode.toString(),
              'message': responseMessage,
            },
          ),
        );
}
