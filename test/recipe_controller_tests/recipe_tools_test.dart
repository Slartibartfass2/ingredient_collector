import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_tools.dart';

void main() {
  group('Test mergeRecipePrasingJobs', () {
    test('When empty list is merged, then an empty list is returned', () {
      var mergedJobs = mergeRecipeParsingJobs([]);
      expect(mergedJobs, isEmpty);
    });

    test(
      'When list with no duplicates is merged, then equal list is returned',
      () {
        var jobs = [
          RecipeParsingJob(url: Uri.parse("url1"), servings: 1, language: ""),
          RecipeParsingJob(url: Uri.parse("url2"), servings: 2, language: ""),
          RecipeParsingJob(url: Uri.parse("url3"), servings: 3, language: ""),
        ];
        var mergedJobs = mergeRecipeParsingJobs(jobs);
        expect(mergedJobs, equals(jobs));
      },
    );

    test(
      'When duplicates are merged, then duplicates result in one job',
      () {
        var jobs = [
          RecipeParsingJob(url: Uri.parse("url1"), servings: 1, language: ""),
          RecipeParsingJob(url: Uri.parse("url2"), servings: 2, language: ""),
          RecipeParsingJob(url: Uri.parse("url1"), servings: 3, language: ""),
        ];
        var mergedJobs = mergeRecipeParsingJobs(jobs);
        expect(
          mergedJobs,
          equals([
            RecipeParsingJob(url: Uri.parse("url1"), servings: 4, language: ""),
            RecipeParsingJob(url: Uri.parse("url2"), servings: 2, language: ""),
          ]),
        );
      },
    );
  });
}
