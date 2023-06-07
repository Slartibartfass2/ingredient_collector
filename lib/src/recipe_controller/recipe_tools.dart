import '../models/recipe_parsing_job.dart';

/// Merges the passed [RecipeParsingJob]s.
///
/// If two [RecipeParsingJob]s have the same url, they are merged into one
/// [RecipeParsingJob] with the sum of the servings.
/// The merged [RecipeParsingJob]s are returned.
/// The order of the [RecipeParsingJob]s is preserved.
List<RecipeParsingJob> mergeRecipeParsingJobs(List<RecipeParsingJob> jobs) {
  var mergedJobs = <RecipeParsingJob>[];
  for (var job in jobs) {
    var existingJobIndex = mergedJobs.indexWhere(
      (mergedJob) => mergedJob.url == job.url,
    );
    if (existingJobIndex == -1) {
      mergedJobs.add(job);
    } else {
      var existingJob = mergedJobs[existingJobIndex];
      mergedJobs[existingJobIndex] = existingJob.copyWith(
        servings: existingJob.servings + job.servings,
      );
    }
  }
  return mergedJobs;
}
