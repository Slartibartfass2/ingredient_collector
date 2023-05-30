part of meta_data_log;

/// [MetaDataLog] for when a recipe url is deliberately not supported.
class DeliberatelyNotSupportedUrlMetaDataLog extends MetaDataLog {
  /// Url of the recipe that could not be parsed.
  final Uri recipeUrl;

  /// Creates a [DeliberatelyNotSupportedUrlMetaDataLog] object.
  DeliberatelyNotSupportedUrlMetaDataLog({required this.recipeUrl})
      : super(
          type: MetaDataLogType.error,
          title: LocaleKeys.parsing_messages_deliberately_unsupported_url_title
              .tr(),
          message: LocaleKeys
              .parsing_messages_deliberately_unsupported_url_message
              .tr(
            namedArgs: {'recipeUrl': recipeUrl.toString()},
          ),
        );
}