import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_keys.g.dart';
import '../ingredient_output_generator.dart';
import '../models/recipe.dart';
import '../models/recipe_parsing_job.dart';
import '../recipe_controller/recipe_controller.dart';
import 'collection_output_textarea.dart';
import 'form_button.dart';
import 'message_boxes.dart/message_box.dart';
import 'recipe_input_row.dart';

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
  /// Number of [RecipeInputRow]s that are created on startup.
  static const recipeRowsAtBeginning = 2;

  /// The key to identify the form.
  final _formKey = GlobalKey<FormState>();

  /// The list of [RecipeInputRow]s.
  final recipeInputRows = <RecipeInputRow>[];

  /// The list of [MessageBox]es to display.
  List<MessageBox> _messageBoxes = [];

  final textArea = CollectionOutputTextArea();

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < recipeRowsAtBeginning; i++) {
      _addRow();
    }
  }

  void _addRow() {
    recipeInputRows.add(
      RecipeInputRow((row) {
        setState(() {
          recipeInputRows.remove(row);
        });
      }),
    );
  }

  Future<void> _submitForm() async {
    var language = context.locale.languageCode;

    var validRows = recipeInputRows.where(
      (row) =>
          row.urlController.text.isNotEmpty &&
          row.servingsController.text.isNotEmpty,
    );

    var jobsToRows = <RecipeParsingJob, RecipeInputRow>{};
    for (var row in validRows) {
      var recipeParsingJob = RecipeParsingJob(
        url: Uri.parse(row.urlController.text),
        servings: int.parse(row.servingsController.text),
        language: language,
      );

      jobsToRows[recipeParsingJob] = row;
    }
    var recipeJobs = jobsToRows.keys.toList();

    var formState = _formKey.currentState;
    if (formState == null || !formState.validate() || recipeJobs.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text(LocaleKeys.processing_recipes_text).tr()),
    );

    var parsingResults = await RecipeController().collectRecipes(
      recipeParsingJobs: recipeJobs,
      language: language,
      onSuccessfullyParsedRecipe: (job, recipeName) {
        jobsToRows[job]!.onSuccessfulParsing(recipeName);
      },
      onFailedParsedRecipe: (job) {
        jobsToRows[job]!.onFailedParsing();
      },
    );

    var metaDataLogs = parsingResults
        .map((result) => result.metaDataLogs)
        .expand((log) => log)
        .toList();
    var parsedRecipes = parsingResults
        .map((result) => result.recipe)
        .whereType<Recipe>()
        .toList();
    var collectionResult = createCollectionResultFromRecipes(parsedRecipes);

    // If context is still valid, update the state.
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        _messageBoxes = metaDataLogs.map(MessageBox.fromMetaDataLog).toList();
        textArea.controller.text = collectionResult.resultSortedByAmount;
      });
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
              onPressed: () => setState(_addRow),
            ),
            FormButton(
              buttonText: LocaleKeys.submit_button_text.tr(),
              onPressed: _submitForm,
            ),
            textArea,
          ],
        ),
      );
}
