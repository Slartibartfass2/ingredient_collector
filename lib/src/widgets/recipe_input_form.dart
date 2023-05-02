import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart' show Platform;

import '../../l10n/locale_keys.g.dart';
import '../ingredient_output_generator.dart';
import '../models/recipe_parsing_job.dart';
import '../recipe_controller.dart';
import 'form_button.dart';
import 'message_box.dart';
import 'recipe_input_row.dart';

/// Number of [RecipeInputRow]s that are created on startup.
const recipeRowsAtBeginning = 2;

/// The form to input recipes.
///
/// The form contains a list of [RecipeInputRow]s, a button to add a new
/// [RecipeInputRow], a submit button and a text area to display the collected
/// ingredients.
class RecipeInputForm extends StatefulWidget {
  /// Creates a new [RecipeInputForm].
  const RecipeInputForm({super.key});

  @override
  State<StatefulWidget> createState() => _RecipeInputFormState();
}

class _RecipeInputFormState extends State<RecipeInputForm> {
  /// The key to identify the form.
  final _formKey = GlobalKey<FormState>();

  /// The list of [RecipeInputRow]s.
  final recipeInputRows = <RecipeInputRow>[];

  /// The controller for the text area to display the collected ingredients.
  final collectionResultController = TextEditingController();

  /// The list of [MessageBox]es to display.
  List<MessageBox> _messageBoxes = [];

  void _addRow() {
    setState(() {
      recipeInputRows.add(
        RecipeInputRow((row) {
          setState(() {
            recipeInputRows.remove(row);
          });
        }),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < recipeRowsAtBeginning; i++) {
      _addRow();
    }
  }

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: Column(
          children: [
            ..._messageBoxes,
            ...recipeInputRows,
            FormButton(
              buttonText: LocaleKeys.add_recipe_button_text.tr(),
              onPressed: _addRow,
            ),
            FormButton(
              buttonText: LocaleKeys.submit_button_text.tr(),
              onPressed: _submitForm,
            ),
            TextField(
              controller: collectionResultController,
              maxLines: 10,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: LocaleKeys.collection_result_text_hint.tr(),
              ),
            ),
          ],
        ),
      );

  Future<void> _submitForm() async {
    // Get first part of local language e.g. en_US -> en
    var language = Platform.localeName.split("_")[0];

    var recipeJobs = recipeInputRows
        .where(
          (row) =>
              row.urlController.text.isNotEmpty &&
              row.servingsController.text.isNotEmpty,
        )
        .map(
          (row) => RecipeParsingJob(
            url: Uri.parse(row.urlController.text),
            servings: int.parse(row.servingsController.text),
            language: language,
          ),
        )
        .toList();

    if (_formKey.currentState!.validate() && recipeJobs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(LocaleKeys.processing_recipes_text).tr(),
        ),
      );

      var parsingResults = await collectRecipes(recipeJobs, language);
      var metaDataLogs = parsingResults
          .map((result) => result.metaDataLogs)
          .expand((log) => log)
          .toList();
      var parsedRecipes = parsingResults
          .where((result) => result.recipe != null)
          .map((result) => result.recipe!)
          .toList();
      var collectionResult = createCollectionResultFromRecipes(parsedRecipes);

      _messageBoxes = metaDataLogs.map(MessageBox.fromMetaDataLog).toList();

      collectionResultController.text = collectionResult.resultSortedByAmount;

      setState(() {});
    }
  }
}
