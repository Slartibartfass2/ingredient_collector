import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../l10n/locale_keys.g.dart';

/// A text input field for the number of servings.
///
/// The input is restricted to positive integers.
class ServingsInputField extends TextFormField {
  /// Creates a new [ServingsInputField].
  ServingsInputField({super.key, required super.controller})
    : super(
        decoration: InputDecoration(
          labelText: LocaleKeys.servings_field_label.tr(),
          labelStyle: TextStyle(color: ShadColorScheme.fromName('slate').primary),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ShadColorScheme.fromName('slate').primary),
          ),
          border: const OutlineInputBorder(),
        ),
        cursorColor: ShadColorScheme.fromName('slate').primary,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[1-9][0-9]*')),
        ],
      );
}
