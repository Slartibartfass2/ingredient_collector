part of meta_data_log;

/// [MetaDataLog] for when the HTTP request failed.
class RequestFailureMetaDataLog extends MetaDataLog {
  /// Url of the recipe that could not be requested.
  final Uri recipeUrl;

  /// Status code of the HTTP request.
  final int statusCode;

  /// Response message of the HTTP request.
  final String responseMessage;

  /// Creates a [RequestFailureMetaDataLog] object.
  RequestFailureMetaDataLog({
    required this.recipeUrl,
    required this.statusCode,
    required this.responseMessage,
  }) : super(
          type: MetaDataLogType.error,
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
