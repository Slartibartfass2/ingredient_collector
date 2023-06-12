import 'package:flutter/material.dart';

import '../../local_storage_controller.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../recipe_controller/recipe_tools.dart';
import '../../widgets/form_button.dart';
import 'ingredient_row.dart';

/// The form for modifying a recipe.
class RecipeModificationForm extends StatefulWidget {
  /// The original recipe (used to determine the modification).
  final Recipe originalRecipe;

  /// The url origin of the recipe to modify.
  final String recipeUrlOrigin;

  /// The modified recipe that is used to fill the form.
  /// If there was no modification stored, this is the same as [originalRecipe].
  final Recipe modifiedRecipe;

  /// The original ingredient names (used to determine the modification).
  final List<String> originalIngredientNames;

  /// Creates a recipe modification form.
  RecipeModificationForm({
    super.key,
    required this.originalRecipe,
    required this.recipeUrlOrigin,
    required this.modifiedRecipe,
  }) : originalIngredientNames = originalRecipe.ingredients
            .map((ingredient) => ingredient.name)
            .toList();

  @override
  State<RecipeModificationForm> createState() => _RecipeModificationFormState();
}

class _RecipeModificationFormState extends State<RecipeModificationForm> {
  List<IngredientRow> modifiedRows = [];
  List<IngredientRow> removedRows = [];

  int rowIndex = 0;

  @override
  void initState() {
    super.initState();
    var ingredients = widget.modifiedRecipe.ingredients;
    var originalIngredients = widget.originalRecipe.ingredients;
    modifiedRows = ingredients
        .where((ingredient) => ingredient.amount >= 0)
        .map(
          (ingredient) => _createRow(
            ingredient,
            originalIngredients.firstWhere(
              (originalIngredient) =>
                  originalIngredient.name == ingredient.name &&
                  originalIngredient.unit == ingredient.unit,
              orElse: () => const Ingredient(amount: 0, unit: "", name: ""),
            ),
            true,
            _onDelete,
          ),
        )
        .toList();
    removedRows = ingredients
        .where((ingredient) => ingredient.amount < 0)
        .map(
          (ingredient) => _createRow(ingredient, ingredient, false, _onRestore),
        )
        .toList();
  }

  IngredientRow _createRow(
    Ingredient ingredient,
    Ingredient originalIngredient,
    bool isEnabled,
    void Function(IngredientRow) onPressed,
  ) =>
      IngredientRow(
        key: ValueKey(rowIndex++),
        ingredient: ingredient,
        originalIngredient: originalIngredient,
        isEnabled: isEnabled,
        isNew: !widget.originalIngredientNames.contains(ingredient.name),
        onPressed: onPressed,
      );

  void _onDelete(IngredientRow row) {
    setState(() {
      modifiedRows.remove(row);
      if (row.nameController.text.isNotEmpty && !row.isNew) {
        removedRows.add(
          _createRow(
            row.modifiedIngredient,
            row.originalIngredient,
            false,
            _onRestore,
          ),
        );
      }
    });
  }

  void _onRestore(IngredientRow row) {
    setState(() {
      removedRows.remove(row);
      modifiedRows.add(
        _createRow(
          row.modifiedIngredient,
          row.originalIngredient,
          true,
          _onDelete,
        ),
      );
    });
  }

  void _addNewIngredient() {
    setState(() {
      var newIngredient = const Ingredient(amount: 0, unit: "", name: "");
      modifiedRows.add(
        _createRow(
          newIngredient,
          newIngredient,
          true,
          _onDelete,
        ),
      );
    });
  }

  bool _isRowChanged(IngredientRow row) =>
      row.isNew || row.originalIngredient != row.modifiedIngredient;

  Future<void> _onSave(BuildContext context) async {
    var modification = getModification(
      originalRecipe: widget.originalRecipe,
      modifiedIngredients: modifiedRows
          .where((row) => row.nameController.text.isNotEmpty)
          .where(_isRowChanged)
          .map((row) => row.modifiedIngredient),
      removedIngredient: removedRows.map((row) => row.modifiedIngredient),
    );

    await LocalStorageController().setRecipeModification(
      widget.recipeUrlOrigin,
      widget.originalRecipe.name,
      modification,
    );

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var divider = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Expanded(child: Divider()),
          const SizedBox(width: 8),
          Text(
            "Removed ingredients",
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );

    var addIngredientButton = FormButton(
      buttonText: "Add ingredient",
      onPressed: _addNewIngredient,
    );

    var saveModificationButton = FormButton(
      buttonText: "Save modification",
      onPressed: () async => _onSave(context),
    );

    return Form(
      child: Center(
        child: SizedBox(
          width: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...modifiedRows,
              addIngredientButton,
              removedRows.isEmpty ? const SizedBox.shrink() : divider,
              ...removedRows,
              saveModificationButton,
            ],
          ),
        ),
      ),
    );
  }
}
