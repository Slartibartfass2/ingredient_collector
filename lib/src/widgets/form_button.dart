import 'package:flutter/material.dart';

import 'recipe_input_form.dart';

/// An [ElevatedButton] with fixed style used in the [RecipeInputForm].
class FormButton extends StatelessWidget {
  /// The text of this [FormButton].
  final String buttonText;

  /// The function that is called when this [FormButton] is pressed.
  final void Function() onPressed;

  /// Creates a new [FormButton].
  const FormButton({super.key, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ElevatedButton(onPressed: onPressed, child: Text(buttonText)),
      ),
    );
  }
}
