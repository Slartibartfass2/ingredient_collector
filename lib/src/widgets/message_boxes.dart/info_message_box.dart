import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../theme.dart';
import 'message_box.dart';

/// [MessageBox] that represents an information.
class InfoMessageBox extends MessageBox {
  /// Creates a [InfoMessageBox].
  InfoMessageBox({
    super.key,
    required super.title,
    required super.message,
  }) : super(
          textColor: informationColor,
          backgroundColor: informationBackgroundColor,
          iconData: Icons.info_rounded,
          titleTag: LocaleKeys.message_box_title_info.tr(),
        );
}
