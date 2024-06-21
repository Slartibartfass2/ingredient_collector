part of 'job_log.dart';

/// [JobLog] for simple jobs.
class SimpleJobLog extends JobLog {
  /// Subtype of [SimpleJobLog].
  final JobLogSubType subType;

  /// Url of [RecipeParsingJob].
  final Uri recipeUrl;

  /// Creates a [SimpleJobLog] object.
  SimpleJobLog({
    required this.subType,
    required this.recipeUrl,
  }) : super(type: subType.type);

  @override
  String toString() => "SimpleJobLog(subType=$subType, url=$recipeUrl)";
}
