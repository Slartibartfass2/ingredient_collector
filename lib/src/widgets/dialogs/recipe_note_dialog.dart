import 'package:flutter/material.dart';

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
  const RecipeNoteDialog({
    super.key,
    required this.recipeUrlOrigin,
    required this.recipeName,
  });

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
        () async =>
            LocalStorageController().getRecipeNote(recipeUrlOrigin, recipeName),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          textField = TextField(
            controller: TextEditingController(text: snapshot.data),
            decoration: const InputDecoration(
              labelText: "Recipe note",
              helperText: "This note will be saved and displayed when the "
                  "ingredients for this recipe are collected in the future.",
              helperMaxLines: 100,
              hintText: "e.g. \"4 servings is not enough for two people,"
                  " use 8 instead!\"",
              border: OutlineInputBorder(),
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
      child: const Text("Cancel"),
    );

    var saveButton = ElevatedButton(
      onPressed: () async => _onSave(context, textField),
      child: const Text("Save"),
    );

    return SimpleDialog(
      title: const Text("Add recipe note"),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      semanticLabel: "Add recipe note",
      children: [
        textAreaFutureBuilder,
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            cancelButton,
            const SizedBox(width: 10),
            saveButton,
          ],
        ),
      ],
    );
  }
}
