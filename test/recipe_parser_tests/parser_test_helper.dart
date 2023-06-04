import 'package:flutter_test/flutter_test.dart' show fail;
import 'package:ingredient_collector/src/meta_data_logs/meta_data_log.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/ingredient_parsing_result.dart';
import 'package:ingredient_collector/src/models/recipe.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_result.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';

void expectIngredient(
  Recipe recipe,
  String name, {
  double amount = 0.0,
  String unit = "",
}) {
  var ingredient = Ingredient(amount: amount, unit: unit, name: name);
  var isInRecipe = recipe.ingredients.contains(ingredient);
  if (!isInRecipe) {
    fail("$ingredient was not found in the recipe");
  }
}

bool hasRecipeParsingErrors(RecipeParsingResult result) => result.metaDataLogs
    .where((log) => log.type == MetaDataLogType.error)
    .isNotEmpty;

bool hasIngredientParsingErrors(IngredientParsingResult result) =>
    result.metaDataLogs
        .where((log) => log.type == MetaDataLogType.error)
        .isNotEmpty;

Future<void> testParsingRecipes(
  List<String> urls, {
  required String language,
}) async {
  var jobs = urls
      .map(
        (url) => RecipeParsingJob(
          url: Uri.parse(url),
          servings: 2,
          language: language,
        ),
      )
      .toList();

  var notWorkingUrls = <String>[];
  for (var job in jobs) {
    var result = await RecipeController().collectRecipes(
      recipeParsingJobs: [job],
      language: job.language,
    ).then((value) => value.first);
    if (hasRecipeParsingErrors(result) || result.recipe == null) {
      notWorkingUrls.add(job.url.toString());
    }
  }

  if (notWorkingUrls.isNotEmpty) {
    fail("The following recipes failed:\n${notWorkingUrls.join("\n")}");
  }
}
