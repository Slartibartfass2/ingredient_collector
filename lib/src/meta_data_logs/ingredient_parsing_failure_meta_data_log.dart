part of meta_data_log;

/// [MetaDataLog] for when the parsing of an ingredient fails.
class IngredientParsingFailureMetaDataLog extends MetaDataLog {
  /// Url of the recipe that could not be parsed.
  final String recipeUrl;

  /// Creates a [IngredientParsingFailureMetaDataLog] object.
  IngredientParsingFailureMetaDataLog({required this.recipeUrl})
      : super(
          type: MetaDataLogType.error,
          title: LocaleKeys.parsing_messages_ingredient_failure_title.tr(),
          message: LocaleKeys.parsing_messages_ingredient_failure_message.tr(
            namedArgs: {'recipeUrl': recipeUrl},
          ),
        );
}
