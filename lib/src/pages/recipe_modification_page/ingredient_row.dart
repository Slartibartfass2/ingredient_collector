import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../models/ingredient.dart';

/// A row to display the properties of an ingredient.
class IngredientRow extends StatefulWidget {
  /// The original ingredient (used to determine the modification).
  final Ingredient originalIngredient;

  /// Whether this [IngredientRow] is enabled.
  final bool isEnabled;

  /// Whether this [IngredientRow] is new ie. not in the original recipe.
  final bool isNew;

  /// The controller for the amount field.
  final TextEditingController amountController = TextEditingController();

  /// The controller for the unit field.
  final TextEditingController unitController = TextEditingController();

  /// The controller for the name field.
  final TextEditingController nameController = TextEditingController();

  /// The function to call when the delete button is pressed.
  final void Function(IngredientRow row) onPressed;

  /// The function to call when the name field is validated.
  final String? Function(String) onNameValidation;

  /// Creates a new [IngredientRow].
  IngredientRow({
    super.key,
    required Ingredient ingredient,
    required this.originalIngredient,
    required this.isEnabled,
    required this.isNew,
    required this.onPressed,
    required this.onNameValidation,
  }) {
    amountController.text = ingredient.amount.toString();
    unitController.text = ingredient.unit;
    nameController.text = ingredient.name;
  }

  /// The modified ingredient.
  Ingredient get modifiedIngredient => Ingredient(
        amount: double.tryParse(amountController.text) ?? 0,
        unit: unitController.text.trim(),
        name: nameController.text.trim(),
      );

  @override
  State<IngredientRow> createState() => _IngredientRowState();
}

class _IngredientRowState extends State<IngredientRow> {
  Color? amountColor;
  Color? unitColor;

  @override
  void initState() {
    super.initState();
    amountColor =
        widget.modifiedIngredient.amount != widget.originalIngredient.amount
            ? Colors.orange
            : null;
    unitColor = widget.modifiedIngredient.unit != widget.originalIngredient.unit
        ? Colors.orange
        : null;
  }

  void _onAmountChange(String? newText) {
    var newAmount = double.tryParse(newText ?? "") ?? 0;
    setState(() {
      amountColor =
          newAmount != widget.originalIngredient.amount ? Colors.orange : null;
    });
  }

  void _onUnitChange(String? newUnit) {
    setState(() {
      unitColor =
          newUnit != widget.originalIngredient.unit ? Colors.orange : null;
    });
  }

  String? _onNameValidation(String? newName) {
    if (!widget.isEnabled) {
      return null;
    }

    if (newName == null || newName.isEmpty) {
      return LocaleKeys.recipe_modification_empty_name_text.tr();
    }

    return widget.onNameValidation(newName);
  }

  @override
  Widget build(BuildContext context) {
    var color = widget.isNew ? Colors.green : null;

    var amountField = Expanded(
      child: _CustomTextFormField(
        controller: widget.amountController,
        labelText: LocaleKeys.modification_page_amount.tr(),
        isEnabled: widget.isEnabled,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            RegExp(r'[0-9]+(\.[0-9]*){0,1}'),
          ),
        ],
        color: color ?? amountColor,
        onChanged: _onAmountChange,
      ),
    );

    var unitField = Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: _CustomTextFormField(
          controller: widget.unitController,
          labelText: LocaleKeys.modification_page_unit.tr(),
          isEnabled: widget.isEnabled,
          color: color ?? unitColor,
          onChanged: _onUnitChange,
        ),
      ),
    );

    var nameField = Expanded(
      flex: 2,
      child: _CustomTextFormField(
        controller: widget.nameController,
        labelText: LocaleKeys.modification_page_name.tr(),
        isEnabled: widget.isEnabled,
        isReadOnly: !widget.isNew,
        color: color,
        validator: _onNameValidation,
      ),
    );

    var deleteButton = Padding(
      padding: const EdgeInsets.only(top: 6),
      child: IconButton(
        onPressed: () => widget.onPressed(widget),
        icon: widget.isEnabled
            ? const Icon(Icons.delete)
            : const Icon(Icons.restore_from_trash),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          amountField,
          unitField,
          nameField,
          deleteButton,
        ],
      ),
    );
  }
}

class _CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isEnabled;
  final bool isReadOnly;
  final void Function(String?)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Color? color;
  final String? Function(String?)? validator;

  const _CustomTextFormField({
    required this.controller,
    required this.labelText,
    required this.isEnabled,
    this.isReadOnly = false,
    this.keyboardType,
    this.inputFormatters,
    this.color,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFCBCBCB), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color ?? Colors.grey),
          ),
        ),
        keyboardType: keyboardType,
        readOnly: isReadOnly,
        onChanged: onChanged,
        validator: validator,
        inputFormatters: inputFormatters,
        enabled: isEnabled,
      );
}
