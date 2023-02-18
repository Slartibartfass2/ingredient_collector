import 'package:freezed_annotation/freezed_annotation.dart';

import 'recipe_parsing_job.dart';

part 'meta_data_log.freezed.dart';
part 'meta_data_log.g.dart';

/// Data class which represents additional information which is generated when a
/// [RecipeParsingJob] is executed.
@freezed
class MetaDataLog with _$MetaDataLog {
  /// Creates [MetaDataLog] object.
  const factory MetaDataLog({
    /// Type of log.
    required MetaDataLogType type,

    /// Title of log.
    required String title,

    /// Message of log.
    required String message,
  }) = _MetaDataLog;

  /// Parses [MetaDataLog] object from json string.
  factory MetaDataLog.fromJson(Map<String, dynamic> json) =>
      _$MetaDataLogFromJson(json);
}

/// Type of [MetaDataLog].
///
/// A different type leads to a different representation of the log to the user.
enum MetaDataLogType {
  /// The result of the [RecipeParsingJob] isn't complete and the user may need
  /// to fetch missing information.
  ///
  /// e.g. information is missing
  warning,

  /// There was an error while executing the [RecipeParsingJob].
  ///
  /// e.g. information can't be fetched, the html structure changed
  error,
}
