import 'package:freezed_annotation/freezed_annotation.dart';

import '../recipe_parsing_job.dart';

part 'meta_data_log.freezed.dart';

/// Data class which represents additional information which is generated when a
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
}
