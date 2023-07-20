part of meta_data_log;

/// [MetaDataLog] for when additional information is stored for a recipe.
class AdditionalRecipeInformationMetaDataLog extends MetaDataLog {
  /// The name of the recipe.
  final String recipeName;

  /// The note that was added.
  final String note;

  /// Whether the recipe was modified.
  final bool wasRecipeModified;

  /// Creates a [AdditionalRecipeInformationMetaDataLog] object.
  AdditionalRecipeInformationMetaDataLog({
    required this.recipeName,
    required this.note,
    required this.wasRecipeModified,
  }) : super(
          type: MetaDataLogType.info,
          title: LocaleKeys.additional_information_title.tr(
            namedArgs: {
              'recipeName': recipeName,
            },
          ),
          message: [
            note.isNotEmpty
                ? LocaleKeys.additional_information_note_message.tr(
                    namedArgs: {
                      'note': note,
                    },
                  )
                : '',
            wasRecipeModified
                ? LocaleKeys.additional_information_modification_message.tr()
                : '',
          ].where((text) => text.isNotEmpty).join('\n'),
        );
}
