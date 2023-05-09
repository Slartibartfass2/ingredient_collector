import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import 'message_box.dart';

/// [MessageBox] which represents an error.
class ErrorMessageBox extends MessageBox {
  /// Creates a [ErrorMessageBox].
  ErrorMessageBox({
    super.key,
    required super.title,
    required super.message,
  }) : super(
          textColor: const Color.fromARGB(255, 255, 82, 82),
          backgroundColor: const Color.fromARGB(255, 253, 234, 236),
          iconData: Icons.error,
          titleTag: LocaleKeys.message_box_title_error.tr(),
        );
}
