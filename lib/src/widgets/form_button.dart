import 'package:flutter/material.dart';

import 'recipe_input_form.dart';

/// An [ElevatedButton] with fixed style used in the [RecipeInputForm].
class FormButton extends Padding {
  /// The text of this [FormButton].
  final String buttonText;

  /// The function that is called when this [FormButton] is pressed.
  final void Function() onPressed;

  /// Creates a new [FormButton].
  FormButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  }) : super(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(double.maxFinite, 0),
            ),
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        );
}
