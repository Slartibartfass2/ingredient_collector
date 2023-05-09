import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import 'message_box.dart';

/// [MessageBox] which represents a warning.
class WarningMessageBox extends MessageBox {
  /// Creates a [WarningMessageBox].
  WarningMessageBox({
    super.key,
    required super.title,
    required super.message,
  }) : super(
          textColor: const Color.fromARGB(255, 255, 145, 0),
          backgroundColor: const Color.fromARGB(255, 253, 241, 229),
          iconData: Icons.warning,
          titleTag: LocaleKeys.message_box_title_warning.tr(),
        );
}
