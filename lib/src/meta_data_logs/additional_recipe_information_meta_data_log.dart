part of meta_data_log;

/// [MetaDataLog] for when additional information is stored for a recipe.
class AdditionalRecipeInformationMetaDataLog extends MetaDataLog {
  /// The name of the recipe.
  final String recipeName;

  /// The note that was added.
  final String note;

  /// Creates a [AdditionalRecipeInformationMetaDataLog] object.
  AdditionalRecipeInformationMetaDataLog({
    required this.recipeName,
    required this.note,
  }) : super(
          type: MetaDataLogType.info,
          title: LocaleKeys.additional_information_title.tr(
            namedArgs: {
              'recipeName': recipeName,
            },
          ),
          message: note,
        );
}
