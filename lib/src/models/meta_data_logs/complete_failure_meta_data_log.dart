import 'package:easy_localization/easy_localization.dart';

import '../../../l10n/locale_keys.g.dart';
import '../recipe_parsing_job.dart';
import 'meta_data_log.dart';

/// [MetaDataLog] for when a [RecipeParsingJob] fails completely.
class CompleteFailureMetaDataLog extends MetaDataLog {
  /// Url of the recipe that could not be parsed.
  final Uri recipeUrl;

  /// Creates a [CompleteFailureMetaDataLog] object.
  CompleteFailureMetaDataLog({required this.recipeUrl})
      : super(
          type: MetaDataLogType.error,
          title: LocaleKeys.parsing_messages_complete_failure_title.tr(),
          message: LocaleKeys.parsing_messages_complete_failure_message.tr(
            namedArgs: {'recipeUrl': recipeUrl.toString()},
          ),
        );
}
