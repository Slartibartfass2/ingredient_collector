import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../l10n/locale_keys.g.dart';
import '../ingredient_output_generator.dart';
import '../models/output_format.dart';
import '../models/recipe.dart';
import '../models/recipe_collection_result.dart';
import '../recipe_controller/recipe_controller.dart';
import '../recipe_controller/recipe_tools.dart';
import 'collection_output_textarea.dart';
import 'form_button.dart';
import 'message_boxes.dart/message_box.dart';
import 'recipe_input_row/recipe_input_row.dart';
import 'recipe_input_row/recipe_parsing_state.dart';
import 'recipe_input_row/recipe_parsing_state_wrapper.dart';

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

  int _nextRowId = 0;

  RecipeCollectionResult? collectionResult;

  OutputFormat _selectedFormat = OutputFormat.plaintext;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < recipeRowsAtBeginning; i++) {
      _addRow();
    }
  }

  void _removeRow(RecipeInputRow row) {
    setState(() {
      recipeInputRows.remove(row);
    });
  }

  void _addRow() {
    recipeInputRows.add(
      RecipeInputRow(
        id: _nextRowId++,
        onRemove: _removeRow,
        recipeParsingStateWrapper: RecipeParsingStateWrapper(state: RecipeParsingState.notStarted),
        urlController: TextEditingController(),
        servingsController: TextEditingController(),
      ),
    );
  }

  void _updateRowState(RecipeInputRow row, RecipeParsingStateWrapper wrapper) {
    setState(() {
      var index = recipeInputRows.indexWhere((element) => element.id == row.id);
      recipeInputRows[index] = RecipeInputRow(
        id: row.id,
        onRemove: _removeRow,
        recipeParsingStateWrapper: wrapper,
        urlController: row.urlController,
        servingsController: row.servingsController,
      );
    });
  }

  void _onSuccessfullyParsedRecipe(RecipeInputRow row, String recipeName) {
    _updateRowState(
      row,
      RecipeParsingStateWrapper(state: RecipeParsingState.successful, recipeName: recipeName),
    );
  }

  void _onFailedParsedRecipe(RecipeInputRow row) {
    _updateRowState(row, RecipeParsingStateWrapper(state: RecipeParsingState.failed));
  }

  void _onRecipeParsingStarted(RecipeInputRow row) {
    _updateRowState(row, RecipeParsingStateWrapper(state: RecipeParsingState.inProgress));
  }

  Future<void> _submitForm() async {
    var language = context.locale.languageCode;

    var validRows = recipeInputRows.where(
      (row) => row.urlController.text.isNotEmpty && row.servingsController.text.isNotEmpty,
    );

    // Create recipe parsing jobs from the valid rows.
    var recipeJobs = mergeRecipeParsingJobs(
      validRows.map(
        (row) => RecipeController().createRecipeParsingJob(
          url: Uri.parse(row.urlController.text.trim()),
          servings: int.parse(row.servingsController.text.trim()),
          language: language,
        ),
      ),
    );

    var recipeJobIdToRows = {
      for (var job in recipeJobs)
        job.id: validRows.where((row) => row.urlController.text.trim() == job.url.toString()),
    };

    var formState = _formKey.currentState;
    if (formState == null || !formState.validate() || recipeJobs.isEmpty) {
      return;
    }

    setState(() {
      _messageBoxes.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: const Text(LocaleKeys.processing_recipes_text).tr()));

    var parsingResults = await RecipeController().collectRecipes(
      recipeParsingJobs: recipeJobs,
      language: language,
      onSuccessfullyParsedRecipe:
          (job, recipeName) => recipeJobIdToRows[job.id]!
          // ignore: avoid_function_literals_in_foreach_calls, makes sense here
          .forEach((row) => _onSuccessfullyParsedRecipe(row, recipeName)),
      onFailedParsedRecipe: (job) => recipeJobIdToRows[job.id]!.forEach(_onFailedParsedRecipe),
      onRecipeParsingStarted: (job) => recipeJobIdToRows[job.id]!.forEach(_onRecipeParsingStarted),
    );

    var logs = parsingResults.map((result) => result.logs).expand((jobLogs) => jobLogs).toList();
    var parsedRecipes = parsingResults.map((result) => result.recipe).whereType<Recipe>().toList();
    collectionResult = createCollectionResultFromRecipes(parsedRecipes);

    // If context is still valid, update the state.
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        _messageBoxes = logs.map(MessageBox.fromJobLog).toList();
        _setTextAreaOutput();
      });
    }
  }

  void _setTextAreaOutput() {
    textArea.controller.text = collectionResult?.outputFormats[_selectedFormat] ?? "";
  }

  List<Widget> _buildFormButtons() => [
    Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: ShadButton(
        height: 34,
        onPressed: () => setState(_addRow),
        child: Text(LocaleKeys.add_recipe_button_text).tr(),
      ),
    ),
    Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: ShadButton(
        height: 34,
        onPressed: _submitForm,
        child: Text(LocaleKeys.submit_button_text).tr(),
      ),
    ),
  ];

  Widget _buildOutputFormatTabs() => Row(
    children: [
      ShadTabs<OutputFormat>(
        value: _selectedFormat,
        tabBarConstraints: const BoxConstraints(maxWidth: 220),
        tabs: [
          ShadTab(
            value: OutputFormat.plaintext,
            child: Text(LocaleKeys.output_formats_plaintext).tr(),
          ),
          ShadTab(
            value: OutputFormat.markdown,
            child: Text(LocaleKeys.output_formats_markdown).tr(),
          ),
        ],
        onChanged: (newSelection) {
          setState(() {
            _selectedFormat = newSelection;
            _setTextAreaOutput();
          });
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._messageBoxes
            .map((box) => [box, const SizedBox(height: 10)])
            .expand((element) => element),
        ...recipeInputRows,
        ..._buildFormButtons(),
        SizedBox(height: 10),
        _buildOutputFormatTabs(),
        textArea,
      ],
    ),
  );
}
