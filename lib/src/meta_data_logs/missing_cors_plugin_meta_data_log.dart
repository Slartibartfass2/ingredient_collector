part of meta_data_log;

/// [MetaDataLog] for when a CORS plugin is missing on web.
class MissingCorsPluginMetaDataLog extends MetaDataLog {
  /// Url of the recipe that could not be parsed.
  final Uri recipeUrl;

  /// Creates a [MissingCorsPluginMetaDataLog] object.
  MissingCorsPluginMetaDataLog({required this.recipeUrl})
      : super(
          type: MetaDataLogType.error,
          title: LocaleKeys.missing_cors_plugin_title.tr(),
          message: LocaleKeys.missing_cors_plugin_message.tr(
            namedArgs: {'recipeUrl': recipeUrl.toString()},
          ),
        );
}