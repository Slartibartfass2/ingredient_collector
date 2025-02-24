import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../theme.dart';
import 'message_box.dart';

/// [MessageBox] that represents an error.
class ErrorMessageBox extends MessageBox {
  /// Creates a [ErrorMessageBox].
  ErrorMessageBox({super.key, required super.title, required super.message})
    : super(
        textColor: errorColor,
        backgroundColor: errorBackgroundColor,
        iconData: Icons.error,
        titleTag: LocaleKeys.message_box_title_error.tr(),
      );
}
