part of meta_data_log;

/// [MetaDataLog] for when the parsing of an amount string fails.
class AmountParsingFailureMetaDataLog extends MetaDataLog {
  /// Url of the recipe that could not be parsed.
  final String recipeUrl;

  /// Amount string that could not be parsed.
  final String amountString;

  /// Name of the ingredient that could not be parsed.
  final String ingredientName;

  /// Creates a [AmountParsingFailureMetaDataLog] object.
  AmountParsingFailureMetaDataLog({
    required this.recipeUrl,
    required this.amountString,
    required this.ingredientName,
  }) : super(
          type: MetaDataLogType.error,
          title: LocaleKeys.parsing_messages_amount_failure_title.tr(),
          message: LocaleKeys.parsing_messages_amount_failure_message.tr(
            namedArgs: {
              'recipeUrl': recipeUrl,
              'amountString': amountString,
              'ingredientName': ingredientName,
            },
          ),
        );
}
