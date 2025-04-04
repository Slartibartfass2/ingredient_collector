import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../recipe_controller/recipe_controller.dart';

/// A text input field for the URL.
///
/// The input is validated to be a valid URL and to be supported by the app.
/// See [RecipeController.isUrlSupported] for details.
class UrlInputField extends TextFormField {
  /// The function that is called when the input is validated.
  final void Function({required bool isValid}) onValidated;

  /// The helper text to display below the input field.
  final String? helperText;

  /// The color of the helper text.
  final Color? helperColor;

  /// Creates a new [UrlInputField].
  UrlInputField({
    super.key,
    required super.controller,
    required this.onValidated,
    this.helperText,
    this.helperColor,
  }) : super(
         autovalidateMode: AutovalidateMode.onUserInteraction,
         decoration: InputDecoration(
           iconColor: helperColor,
           labelText: LocaleKeys.url_input_field_label.tr(),
           labelStyle: TextStyle(color: ShadColorScheme.fromName('slate').primary),
           focusedBorder: OutlineInputBorder(
             borderSide: BorderSide(color: ShadColorScheme.fromName('slate').primary),
           ),
           helperText: helperText,
           helperStyle: helperColor != null ? TextStyle(color: helperColor) : null,
           border: const OutlineInputBorder(),
         ),
         cursorColor: ShadColorScheme.fromName('slate').primary,
         keyboardType: TextInputType.url,
         validator: (value) {
           if (value == null || value.isEmpty) {
             onValidated(isValid: false);
             return null;
           }

           var url = Uri.tryParse(value.trim());

           var isUrl = url?.hasAbsolutePath ?? false;
           if (!isUrl) {
             onValidated(isValid: false);
             return LocaleKeys.url_input_field_invalid_url_text.tr();
           }

           if (url != null && !RecipeController().isUrlSupported(url)) {
             onValidated(isValid: false);
             return LocaleKeys.url_input_field_unsupported_url_text.tr();
           }

           onValidated(isValid: true);
           return null;
         },
       );
}
