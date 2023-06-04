import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../recipe_input_form.dart';
import 'recipe_parsing_state.dart';
import 'recipe_parsing_state_wrapper.dart';
import 'servings_input_field.dart';
import 'url_input_field.dart';

/// A row of input fields for a recipe.
///
/// The row contains a [UrlInputField] and a [ServingsInputField].
/// It also contains a close button to remove the row.
/// The row is used in [RecipeInputForm].
class RecipeInputRow extends StatelessWidget {
  /// ID to identify this row.
  final int id;

  /// The function to call when the close button is pressed.
  final void Function(RecipeInputRow) onRemove;

  /// The [TextEditingController] for the url input field.
  final TextEditingController urlController;

  /// The [TextEditingController] for the servings input field.
  final TextEditingController servingsController;

  /// The [RecipeParsingStateWrapper] to display the state of the recipe
  /// parsing.
  final RecipeParsingStateWrapper recipeParsingStateWrapper;

  /// Creates a new [RecipeInputRow].
  const RecipeInputRow({
    required this.id,
    required this.onRemove,
    required this.recipeParsingStateWrapper,
    required this.urlController,
    required this.servingsController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var parsingState = recipeParsingStateWrapper.state;
    var recipeName = recipeParsingStateWrapper.recipeName;

    var urlField = Expanded(
      child: UrlInputField(
        controller: urlController,
        helperText: switch (parsingState) {
          RecipeParsingState.notStarted => null,
          RecipeParsingState.inProgress =>
            LocaleKeys.recipe_row_helper_text_in_progress.tr(),
          RecipeParsingState.successful =>
            recipeName.isEmpty ? null : recipeName,
          RecipeParsingState.failed =>
            LocaleKeys.recipe_row_helper_text_failed.tr(),
        },
        helperColor: switch (parsingState) {
          RecipeParsingState.notStarted => const Color(0xFF0DCAF0),
          RecipeParsingState.inProgress => const Color(0xFF6C757D),
          RecipeParsingState.successful => const Color(0xFF198754),
          RecipeParsingState.failed => const Color(0xFFDC3545),
        },
      ),
    );

    var servingsField = Padding(
      padding: const EdgeInsets.only(left: 10, right: 2),
      child: SizedBox(
        width: 95,
        child: ServingsInputField(controller: servingsController),
      ),
    );

    var closeButton = IconButton(
      splashRadius: 20,
      onPressed: () => onRemove(this),
      tooltip: LocaleKeys.recipe_row_close_button_text.tr(),
      icon: const Icon(Icons.close),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          urlField,
          Row(
            children: [
              servingsField,
              closeButton,
            ],
          ),
        ],
      ),
    );
  }
}
