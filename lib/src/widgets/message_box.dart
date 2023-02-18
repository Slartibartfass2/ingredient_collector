import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_keys.g.dart';

/// Colored box widget with an icon, a title and a message.
///
/// Used to display information to the user.
class MessageBox extends StatelessWidget {
  /// Color of the icon and the title and message text.
  final Color _textColor;

  /// Color of the background of the box.
  final Color _backgroundColor;

  /// Icon symbol.
  final IconData _iconData;

  /// Title of the [MessageBox].
  final String _title;

  /// Tag for the [_title].
  final String _titleTag;

  /// Message of the [MessageBox].
  final String _message;

  /// Creates a [MessageBox].
  const MessageBox({
    super.key,
    required String title,
    required String titleTag,
    required String message,
    required Color textColor,
    required Color backgroundColor,
    required IconData iconData,
  })  : _textColor = textColor,
        _backgroundColor = backgroundColor,
        _iconData = iconData,
        _message = message,
        _title = title,
        _titleTag = titleTag;

  @override
  Widget build(BuildContext context) {
    var titleRow = Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(
              _iconData,
              color: _textColor,
            ),
          ),
          Flexible(
            child: Text(
              "$_titleTag: $_title",
              textScaleFactor: 1.05,
              style: TextStyle(
                color: _textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleRow,
              Text(
                _message,
                style: TextStyle(color: _textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [MessageBox] which represents an error
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
