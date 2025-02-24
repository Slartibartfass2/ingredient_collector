import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../job_logs/job_log.dart';
import 'error_message_box.dart';
import 'info_message_box.dart';
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
  }) : _textColor = textColor,
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
            child: Icon(_iconData, color: _textColor),
          ),
          Flexible(
            child: SelectableText(
              "$_titleTag: $_title",
              style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
              textScaler: const TextScaler.linear(1.05),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [titleRow, SelectableText(_message, style: TextStyle(color: _textColor))],
        ),
      ),
    );
  }

  /// Creates a [MessageBox] from a [JobLog].
  factory MessageBox.fromJobLog(JobLog log) => switch (log) {
    RequestFailureJobLog log => ErrorMessageBox(
      title: LocaleKeys.http_request_error_title.tr(),
      message: LocaleKeys.http_request_error_message.tr(
        namedArgs: {
          'recipeUrl': log.recipeUrl.toString(),
          'status': log.statusCode.toString(),
          'message': log.responseMessage,
        },
      ),
    ),
    AmountParsingFailureJobLog log => ErrorMessageBox(
      title: LocaleKeys.parsing_messages_amount_failure_title.tr(),
      message: LocaleKeys.parsing_messages_amount_failure_message.tr(
        namedArgs: {
          'recipeUrl': log.recipeUrl.toString(),
          'amountString': log.amountString,
          'ingredientName': log.ingredientName,
        },
      ),
    ),
    AdditionalRecipeInformationJobLog log => InfoMessageBox(
      title: LocaleKeys.additional_information_title.tr(namedArgs: {'recipeName': log.recipeName}),
      message: log.note,
    ),
    SimpleJobLog log => MessageBox.fromSimpleJobLog(log),
  };

  /// Creates a [MessageBox] from a [SimpleJobLog].
  factory MessageBox.fromSimpleJobLog(SimpleJobLog log) {
    var title = switch (log.subType) {
      JobLogSubType.completeFailure => LocaleKeys.parsing_messages_complete_failure_title.tr(),
      JobLogSubType.deliberatelyNotSupportedUrl =>
        LocaleKeys.parsing_messages_deliberately_unsupported_url_title.tr(),
      JobLogSubType.ingredientParsingFailure =>
        LocaleKeys.parsing_messages_ingredient_failure_title.tr(),
      JobLogSubType.missingCorsPlugin => LocaleKeys.missing_cors_plugin_title.tr(),
    };

    var url = log.recipeUrl.toString();
    var message = switch (log.subType) {
      JobLogSubType.completeFailure => LocaleKeys.parsing_messages_complete_failure_message.tr(
        namedArgs: {'recipeUrl': url},
      ),
      JobLogSubType.deliberatelyNotSupportedUrl => LocaleKeys
          .parsing_messages_deliberately_unsupported_url_message
          .tr(namedArgs: {'recipeUrl': url}),
      JobLogSubType.ingredientParsingFailure => LocaleKeys
          .parsing_messages_ingredient_failure_message
          .tr(namedArgs: {'recipeUrl': url}),
      JobLogSubType.missingCorsPlugin => LocaleKeys.missing_cors_plugin_message.tr(
        namedArgs: {'recipeUrl': url},
      ),
    };

    return switch (log.type) {
      JobLogType.error => ErrorMessageBox(title: title, message: message),
      JobLogType.info => InfoMessageBox(title: title, message: message),
      JobLogType.warning => WarningMessageBox(title: title, message: message),
    };
  }
}
