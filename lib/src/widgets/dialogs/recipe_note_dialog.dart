import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../local_storage_controller.dart';

/// A dialog to add a note to a recipe.
///
/// The dialog contains a text area to enter the note.
/// It also contains a cancel and a save button.
class RecipeNoteDialog extends StatelessWidget {
  /// The url of the recipe website.
  final String recipeUrlOrigin;

  /// The name of the recipe.
  final String recipeName;

  /// Creates a new [RecipeNoteDialog].
  const RecipeNoteDialog({super.key, required this.recipeUrlOrigin, required this.recipeName});

  Future<void> _onSave(BuildContext context, TextField textArea) async {
    await LocalStorageController().setRecipeNote(
      recipeUrlOrigin,
      recipeName,
      textArea.controller?.text ?? "",
    );
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var textField = const TextField();
    var textAreaFutureBuilder = FutureBuilder(
      future: Future(
        () async => LocalStorageController().getRecipeNote(recipeUrlOrigin, recipeName),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          textField = TextField(
            controller: TextEditingController(text: snapshot.data),
            decoration: InputDecoration(
              labelText: LocaleKeys.recipe_note_dialog_text_area_label.tr(),
              helperText: LocaleKeys.recipe_note_dialog_text_area_helper.tr(),
              helperMaxLines: 100,
              hintText: LocaleKeys.recipe_note_dialog_text_area_hint.tr(),
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
          );
        }

        return textField;
      },
    );

    var cancelButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text(LocaleKeys.recipe_note_dialog_cancel).tr(),
    );

    var saveButton = ElevatedButton(
      onPressed: () async => _onSave(context, textField),
      child: const Text(LocaleKeys.recipe_note_dialog_save).tr(),
    );

    return SimpleDialog(
      title: const Text(LocaleKeys.recipe_note_dialog_title).tr(),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      semanticLabel: LocaleKeys.recipe_note_dialog_title.tr(),
      children: [
        textAreaFutureBuilder,
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [cancelButton, const SizedBox(width: 10), saveButton],
        ),
      ],
    );
  }
}
