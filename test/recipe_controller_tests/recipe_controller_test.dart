import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/job_logs/job_log.dart';
import 'package:ingredient_collector/src/local_storage_controller.dart';
import 'package:ingredient_collector/src/models/domain/ingredient.dart';
import 'package:ingredient_collector/src/models/domain/recipe.dart';
import 'package:ingredient_collector/src/models/local_storage/additional_recipe_information.dart';
import 'package:ingredient_collector/src/models/local_storage/recipe_modification.dart';
import 'package:ingredient_collector/src/models/parsing/recipe_parsing_result.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecipeCache().cache.clear();
  });

  test(
    'When recipe is parsed again, then the cached recipe is used to create the '
    'RecipeParsingResult',
    () async {
      var job = RecipeController().createRecipeParsingJob(
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
    var successJob = RecipeController().createRecipeParsingJob(
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

    var failJob = RecipeController().createRecipeParsingJob(
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

  test(
    'When modification and note are stored for recipe, then the modification is'
    ' applied and a log created',
    () async {
      var recipeUrlOrigin = "test origin";

      await LocalStorageController().setAdditionalRecipeInformation(
        AdditionalRecipeInformation(
          recipeUrlOrigin: recipeUrlOrigin,
          recipeName: "Test recipe",
          note: "Test note",
          recipeModification: const RecipeModification(
            servings: 4,
            modifiedIngredients: [
              Ingredient(amount: 4, unit: "", name: "Zucchini"),
            ],
          ),
        ),
      );

      var result = const RecipeParsingResult(
        recipe: Recipe(
          ingredients: [Ingredient(amount: 2, unit: "", name: "Zucchini")],
          name: "Test recipe",
          servings: 4,
        ),
        logs: [],
      );

      var modifiedResult = await RecipeController().applyRecipeModification(
        result,
        recipeUrlOrigin,
      );

      expect(modifiedResult.recipe, isNotNull);
      var recipe = modifiedResult.recipe!;
      var ingredient = recipe.ingredients
          .where((element) => element.name == "Zucchini")
          .first;
      expect(ingredient.amount, 4);

      var logs = modifiedResult.logs;
      expect(logs, isNotEmpty);
      var log = logs.first;
      expect(log, isA<AdditionalRecipeInformationJobLog>());

      var additionalInformationLog = log as AdditionalRecipeInformationJobLog;

      expect(additionalInformationLog.recipeName, "Test recipe");
      expect(additionalInformationLog.note, "Test note");
      expect(modifiedResult.wasModified, isTrue);
    },
  );

  test(
    'When note is stored for recipe, then a log is created',
    () async {
      var recipeUrlOrigin = "test origin";

      await LocalStorageController().setAdditionalRecipeInformation(
        AdditionalRecipeInformation(
          recipeUrlOrigin: recipeUrlOrigin,
          recipeName: "Test recipe",
          note: "Test note",
        ),
      );

      var result = const RecipeParsingResult(
        recipe: Recipe(
          ingredients: [Ingredient(amount: 2, unit: "", name: "Zucchini")],
          name: "Test recipe",
          servings: 4,
        ),
        logs: [],
      );

      var modifiedResult = await RecipeController().applyRecipeModification(
        result,
        recipeUrlOrigin,
      );

      var logs = modifiedResult.logs;
      expect(logs, isNotEmpty);
      var log = logs.first;
      expect(log, isA<AdditionalRecipeInformationJobLog>());

      var additionalInformationLog = log as AdditionalRecipeInformationJobLog;

      expect(additionalInformationLog.recipeName, "Test recipe");
      expect(additionalInformationLog.note, "Test note");
      expect(modifiedResult.wasModified, isFalse);
    },
  );

  test('When url is not supported, then isUrlSupported returns false', () {
    var url = Uri.parse("https://example.org");
    var isSupported = RecipeController().isUrlSupported(url);
    expect(isSupported, isFalse);
  });

  test(
    'When recipe is parsed and only modification is stored, then no log is '
    'created',
    () async {
      var url =
          Uri.parse("http://mobile.kptncook.com/recipe/pinterest/50d87d41");

      var job = RecipeController().createRecipeParsingJob(
        url: url,
        servings: 4,
        language: "de",
      );

      await LocalStorageController().setAdditionalRecipeInformation(
        AdditionalRecipeInformation(
          recipeUrlOrigin: url.origin,
          recipeName: "Zucchini-Karotten-Kichererbsen-Pfanne",
          recipeModification: const RecipeModification(
            servings: 4,
            modifiedIngredients: [
              Ingredient(amount: 4, unit: "", name: "Zucchini"),
            ],
          ),
        ),
      );

      var results = await RecipeController().collectRecipes(
        recipeParsingJobs: [job],
        language: "de",
        onSuccessfullyParsedRecipe: (job, text) {
          expect(text, endsWith(" (recipe_row.modified)"));
        },
      );
      var result = results.first;

      expect(
        result.logs.whereType<AdditionalRecipeInformationJobLog>(),
        isEmpty,
      );
    },
  );
}
