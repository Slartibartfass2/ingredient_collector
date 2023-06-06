import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../models/recipe.dart';
import '../../models/recipe_parsing_job.dart';
import '../../pages/recipe_modification_page.dart';
import '../../recipe_controller/recipe_cache.dart';
import '../../recipe_controller/recipe_controller.dart';
import '../dialogs/recipe_note_dialog.dart';
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
class RecipeInputRow extends StatefulWidget {
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

  final _ModificationWrapper _modificationEnabledWrapper =
      _ModificationWrapper(isEnabled: false);

  /// Creates a new [RecipeInputRow].
  RecipeInputRow({
    required this.id,
    required this.onRemove,
    required this.recipeParsingStateWrapper,
    required this.urlController,
    required this.servingsController,
    super.key,
  });

  @override
  State<RecipeInputRow> createState() => _RecipeInputRowState();
}

class _RecipeInputRowState extends State<RecipeInputRow> {
  Future<void> _onAddNote(BuildContext context) async {
    var url = Uri.tryParse(widget.urlController.text);
    if (url == null) {
      return;
    }

    var recipe = await _getRecipe(context, url);
    if (recipe == null) {
      return;
    }
    // There needs to be a delay to prevent the dialog from being closed by the
    // popup menu.
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => RecipeNoteDialog(
          recipeUrlOrigin: url.origin,
          recipeName: recipe.name,
        ),
      );
    }
  }

  Future<void> _onModifyRecipe(BuildContext context) async {
    var url = Uri.tryParse(widget.urlController.text);
    if (url == null) {
      return;
    }

    var recipe = await _getRecipe(context, url);
    if (recipe == null) {
      return;
    }

    // There needs to be a delay to prevent the dialog from being closed by the
    // popup menu.
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => RecipeModificationPage(
          recipe: recipe,
          recipeUrlOrigin: url.origin,
        ),
      );
    }
  }

  Future<Recipe?> _getRecipe(BuildContext context, Uri url) async {
    var cachedRecipe = RecipeCache().getRecipe(url);
    if (cachedRecipe != null) {
      return cachedRecipe;
    }

    var language = context.locale.languageCode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(LocaleKeys.recipe_row_parsing_snackbar).tr(),
      ),
    );
    var result = await RecipeController().collectRecipes(
      recipeParsingJobs: [
        RecipeParsingJob(
          url: url,
          servings: int.tryParse(widget.servingsController.text) ?? 1,
          language: language,
        ),
      ],
      language: language,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    if (result.isEmpty || result.first.recipe == null) {
      return null;
    }
    return result.first.recipe;
  }

  // ignore: use_setters_to_change_properties, used for callback
  void _onValidated({required bool isValid}) =>
      widget._modificationEnabledWrapper.isEnabled = isValid;

  @override
  Widget build(BuildContext context) {
    var parsingState = widget.recipeParsingStateWrapper.state;
    var recipeName = widget.recipeParsingStateWrapper.recipeName;
    var modificationEnabledWrapper = widget._modificationEnabledWrapper;

    var urlField = Expanded(
      child: UrlInputField(
        controller: widget.urlController,
        onValidated: _onValidated,
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
        child: ServingsInputField(controller: widget.servingsController),
      ),
    );

    var settingsButton = PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          onTap: () => widget.onRemove(widget),
          child: const Text(LocaleKeys.recipe_row_remove_recipe_text).tr(),
        ),
        PopupMenuItem<void>(
          onTap: () async => _onAddNote(context),
          enabled: modificationEnabledWrapper.isEnabled,
          child: Tooltip(
            message: modificationEnabledWrapper.isEnabled
                ? ""
                : LocaleKeys.recipe_row_add_note_disabled_tooltip.tr(),
            child: const Text(LocaleKeys.recipe_row_add_note_text).tr(),
          ),
        ),
        PopupMenuItem<void>(
          onTap: () async => _onModifyRecipe(context),
          enabled: modificationEnabledWrapper.isEnabled,
          child: Tooltip(
            message: modificationEnabledWrapper.isEnabled
                ? ""
                : LocaleKeys.recipe_row_modify_recipe_disabled_tooltip.tr(),
            child: const Text(LocaleKeys.recipe_row_modify_recipe_text).tr(),
          ),
        ),
      ],
      offset: const Offset(0, 40),
      child: const Icon(Icons.more_vert),
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
              settingsButton,
            ],
          ),
        ],
      ),
    );
  }
}

class _ModificationWrapper {
  bool isEnabled;
  _ModificationWrapper({required this.isEnabled});
}
