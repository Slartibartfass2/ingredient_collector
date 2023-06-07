import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../recipe_controller/recipe_controller.dart';

/// A text input field for the URL.
///
/// The input is validated to be a valid URL and to be supported by the app.
/// See [RecipeController.isUrlSupported] for details.
class UrlInputField extends TextFormField {
  /// The helper text to display below the input field.
  final String? helperText;

  /// The color of the helper text.
  final Color? helperColor;

  /// Creates a new [UrlInputField].
  UrlInputField({
    super.key,
    required super.controller,
    this.helperText,
    this.helperColor,
  }) : super(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            iconColor: helperColor,
            labelText: LocaleKeys.url_input_field_label.tr(),
            helperText: helperText,
            helperStyle:
                helperColor != null ? TextStyle(color: helperColor) : null,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null;
            }

            var url = Uri.tryParse(value);

            var isUrl = url?.hasAbsolutePath ?? false;
            if (!isUrl) {
              return LocaleKeys.url_input_field_invalid_url_text.tr();
            }

            if (url != null && !RecipeController().isUrlSupported(url)) {
              return LocaleKeys.url_input_field_unsupported_url_text.tr();
            }

            return null;
          },
        );
}