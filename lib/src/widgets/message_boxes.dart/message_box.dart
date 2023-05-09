import 'package:flutter/material.dart';

import '../../models/meta_data_log.dart';
import 'error_message_box.dart';
import 'warning_message_box.dart';

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
            child: SelectableText(
              "$_titleTag: $_title",
              style: TextStyle(
                color: _textColor,
                fontWeight: FontWeight.bold,
              ),
              textScaleFactor: 1.05,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(8.0),
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
            SelectableText(
              _message,
              style: TextStyle(color: _textColor),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a [MessageBox] from a [MetaDataLog].
  factory MessageBox.fromMetaDataLog(MetaDataLog log) {
    switch (log.type) {
      case MetaDataLogType.error:
        return ErrorMessageBox(title: log.title, message: log.message);
      case MetaDataLogType.warning:
        return WarningMessageBox(title: log.title, message: log.message);
    }
  }
}
