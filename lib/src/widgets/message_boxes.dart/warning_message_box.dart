import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../theme.dart';
import 'message_box.dart';

/// [MessageBox] that represents a warning.
class WarningMessageBox extends MessageBox {
  /// Creates a [WarningMessageBox].
  WarningMessageBox({super.key, required super.title, required super.message})
    : super(
        textColor: warningColor,
        backgroundColor: warningBackgroundColor,
        iconData: Icons.warning,
        titleTag: LocaleKeys.message_box_title_warning.tr(),
      );
}
