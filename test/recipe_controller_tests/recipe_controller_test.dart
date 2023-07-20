import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() => RecipeCache().cache.clear());

  test(
    'When recipe is parsed again, then the cached recipe is used to create the '
    'RecipeParsingResult',
    () async {
      var job = RecipeParsingJob(
        url: Uri.parse("http://mobile.kptncook.com/recipe/pinterest/50d87d41"),
        servings: 4,
        language: "de",
      );

      var result = await RecipeController().collectRecipes(
        recipeParsingJobs: [job],
        language: "de",
      ).then((value) => value.first);

      expect(result.recipe, isNotNull);
      var recipe = result.recipe!;
      expect(RecipeCache().getRecipe(job.url), equals(recipe));

      var secondResult = await RecipeController().collectRecipes(
        recipeParsingJobs: [job.copyWith(servings: 2)],
        language: "de",
      ).then((value) => value.first);

      expect(secondResult.recipe, isNotNull);
      var secondRecipe = secondResult.recipe!;
      expect(secondRecipe, isNot(equals(recipe)));
      expect(secondRecipe.servings, equals(2));
      expect(RecipeCache().getRecipe(job.url), equals(recipe));
    },
  );

  test('When recipe is parsed, then callback functions are called', () async {
    var successJob = RecipeParsingJob(
      url: Uri.parse("http://mobile.kptncook.com/recipe/pinterest/50d87d41"),
      servings: 4,
      language: "de",
    );

    var isSuccessful = false;
    var wasStarted = false;
    var result = await RecipeController().collectRecipes(
      recipeParsingJobs: [successJob],
      language: "de",
      onSuccessfullyParsedRecipe: (job, _) {
        expect(job, equals(successJob));
        isSuccessful = true;
      },
      onFailedParsedRecipe: (job) {
        fail("Should not be called");
      },
      onRecipeParsingStarted: (job) {
        expect(job, equals(successJob));
        wasStarted = true;
      },
    ).then((value) => value.first);

    expect(result.recipe, isNotNull);
    expect(isSuccessful, isTrue);
    expect(wasStarted, isTrue);

    var failJob = RecipeParsingJob(
      url: Uri.parse("https://example.org/recipe"),
      servings: 4,
      language: "de",
    );

    var isFailed = false;
    wasStarted = false;
    var secondResult = await RecipeController().collectRecipes(
      recipeParsingJobs: [failJob],
      language: "de",
      onSuccessfullyParsedRecipe: (job, _) {
        fail("Should not be called");
      },
      onFailedParsedRecipe: (job) {
        expect(job, equals(failJob));
        isFailed = true;
      },
      onRecipeParsingStarted: (job) {
        expect(job, equals(failJob));
        wasStarted = true;
      },
    ).then((value) => value.first);

    expect(secondResult.recipe, isNull);
    expect(isFailed, isTrue);
    expect(wasStarted, isTrue);
  });
}
