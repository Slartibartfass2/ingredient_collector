import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../theme.dart';
import 'message_box.dart';

/// [MessageBox] which represents an error.
class ErrorMessageBox extends MessageBox {
  /// Creates a [ErrorMessageBox].
  ErrorMessageBox({
    super.key,
    required super.title,
    required super.message,
  }) : super(
          textColor: informationColor,
          backgroundColor: informationBackgroundColor,
          iconData: Icons.error,
          titleTag: LocaleKeys.message_box_title_error.tr(),
        );
}
