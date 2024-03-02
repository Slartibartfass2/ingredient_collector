library job_log;

import '../models/recipe_parsing_job.dart';

part 'additional_recipe_information_job_log.dart';
part 'amount_parsing_failure_job_log.dart';
part 'job_log_sub_type.dart';
part 'job_log_type.dart';
part 'simple_job_log.dart';
part 'request_failure_job_log.dart';

/// Data class that represents additional information which is generated when a
/// [RecipeParsingJob] is executed.
sealed class JobLog {
  /// Type of log.
  final JobLogType type;

  /// Creates a [JobLog] object.
  const JobLog({
    required this.type,
  });

  @override
  String toString() => "JobLog(type=$type)";
}
