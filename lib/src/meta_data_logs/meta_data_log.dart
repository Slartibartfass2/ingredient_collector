library meta_data_log;

import 'package:easy_localization/easy_localization.dart';

import '../../l10n/locale_keys.g.dart';
import '../models/recipe_parsing_job.dart';

part 'additional_recipe_information_meta_data_log.dart';
part 'amount_parsing_failure_meta_data_log.dart';
part 'complete_failure_meta_data_log.dart';
part 'deliberately_not_supported_url_meta_data_log.dart';
part 'ingredient_parsing_failure_meta_data_log.dart';
part 'missing_cors_plugin_meta_data_log.dart';
part 'request_failure_meta_data_log.dart';

/// Data class that represents additional information which is generated when a
/// [RecipeParsingJob] is executed.
class MetaDataLog {
  /// Type of log.
  final MetaDataLogType type;

  /// Title of log.
  final String title;

  /// Message of log.
  final String message;

  /// Creates a [MetaDataLog] object.
  const MetaDataLog({
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  String toString() =>
      "MetaDataLog(type=$type, title=$title, message=$message)";
}

/// Type of [MetaDataLog].
///
/// A different type leads to a different representation of the log to the user.
enum MetaDataLogType {
  /// The result of the [RecipeParsingJob] isn't complete and the user may need
  /// to fetch missing information.
  ///
  /// For example information is missing.
  warning,

  /// There was an error while executing the [RecipeParsingJob].
  ///
  /// For example information can't be fetched, the html structure changed.
  error,

  /// A general information for the user.
  ///
  /// For example that the recipe was modified.
  info,
}
