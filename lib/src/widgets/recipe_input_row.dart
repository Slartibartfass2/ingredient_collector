import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_keys.g.dart';
import 'recipe_input_form.dart';
import 'servings_input_field.dart';
import 'url_input_field.dart';

/// A row of input fields for a recipe.
///
/// The row contains a [UrlInputField] and a [ServingsInputField].
/// It also contains a close button to remove the row.
/// The row is used in [RecipeInputForm].
class RecipeInputRow extends StatelessWidget {
  /// The function to call when the close button is pressed.
  final void Function(RecipeInputRow) onRemove;

  /// The [TextEditingController] for the url input field.
  final TextEditingController urlController = TextEditingController();

  /// The [TextEditingController] for the servings input field.
  final TextEditingController servingsController = TextEditingController();

  /// Creates a new [RecipeInputRow].
  RecipeInputRow(this.onRemove, {super.key});

  @override
  Widget build(BuildContext context) {
    var urlField = Expanded(
      child: UrlInputField(controller: urlController),
    );

    var servingsField = Padding(
      padding: const EdgeInsets.only(left: 10, right: 2),
      child: SizedBox(
        width: 100,
        child: ServingsInputField(controller: servingsController),
      ),
    );

    var closeButton = IconButton(
      icon: const Icon(Icons.close),
      tooltip: LocaleKeys.recipe_row_close_button_text.tr(),
      splashRadius: 20,
      onPressed: () => onRemove(this),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          urlField,
          servingsField,
          closeButton,
        ],
      ),
    );
  }
}
