part of 'job_log.dart';

/// [JobLog] for when additional information is stored for a recipe.
class AdditionalRecipeInformationJobLog extends JobLog {
  /// The name of the recipe.
  final String recipeName;

  /// The note that was added.
  final String note;

  /// Creates a [AdditionalRecipeInformationJobLog] object.
  AdditionalRecipeInformationJobLog({required this.recipeName, required this.note})
    : super(type: JobLogType.info);

  @override
  String toString() => "AdditionalRecipeInformationJobLog(recipeName=$recipeName, note=$note)";
}
