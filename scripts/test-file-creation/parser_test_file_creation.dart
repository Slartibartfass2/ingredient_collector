// ignore_for_file: invalid_use_of_visible_for_testing_member, format-comment

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/recipe.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/recipe_parser_tests/parser_test_helper.dart';

/// How to use:
/// 1. Copy this code to a test file
/// 2. Set file directory to name of recipe website
/// 3. Replace the urls list with recipe urls of the recipe website
/// 4. Go to parser file and modify call to 'createResultFromIngredientParsing'
///   so that the job has the actual recipe servings as requested servings,
///   multiplied by a random integer. The servingsMultiplier is the same number
///   ```
///   var factor = Random().nextInt(4) + 2;
///   return createResultFromIngredientParsing(
///     ingredientElements,
///     recipeParsingJob.copyWith(servings: recipeServings * factor),
///     factor.toDouble(),
///     recipeName,
///     parseIngredient,
///   );
///   ```
/// 5. Run the script and verify the recipes
void main() {
  const fileDirectory = "kptncook";

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecipeCache().cache.clear();
  });

  String ingredientToJson(Ingredient ingredient) => """            {
                "amount": ${ingredient.amount},
                "unit": "${ingredient.unit}",
                "name": "${ingredient.name}"
            }""";

  String recipeToJson(Recipe recipe) => """{
        "name": "${recipe.name}",
        "ingredients": [\n${recipe.ingredients.map(ingredientToJson).join(",\n")}
        ]
    }""";

  String recipeParsingJobToJson(String url, int servings) => """{
        "url": "$url",
        "servings": $servings
    }""";

  String allToJson(RecipeParsingJob job, Recipe recipe) => """{
    "request": ${recipeParsingJobToJson(job.url.toString(), recipe.servings)},
    "result": ${recipeToJson(recipe)}\n}\n""";

  Future<void> write(String text, String fileName) async {
    var file = File(
      './test/recipe_parser_tests/parser_test_files/$fileDirectory/$fileName.json',
    );
    await file.writeAsString(text);
  }

  test("create files", () async {
    var urls = [
      "http://mobile.kptncook.com/recipe/pinterest/4b596ab7",
      "http://mobile.kptncook.com/recipe/pinterest/635c0bad",
      "http://mobile.kptncook.com/recipe/pinterest/11ac751d",
      "http://mobile.kptncook.com/recipe/pinterest/39ca1693",
      "http://mobile.kptncook.com/recipe/pinterest/78953c30",
      "http://mobile.kptncook.com/recipe/pinterest/17a4b8b",
      "http://mobile.kptncook.com/recipe/pinterest/4fcb5947",
      "http://mobile.kptncook.com/recipe/pinterest/50d87d41",
      "http://mobile.kptncook.com/recipe/pinterest/54edf8a0",
      "http://mobile.kptncook.com/recipe/pinterest/5a948e36",
      "http://mobile.kptncook.com/recipe/pinterest/5050d37a",
      "http://mobile.kptncook.com/recipe/pinterest/5f1565c5",
      "http://mobile.kptncook.com/recipe/pinterest/3e110959",
      "http://mobile.kptncook.com/recipe/pinterest/6a9c6549",
      "http://mobile.kptncook.com/recipe/pinterest/49219eeb",
      "http://mobile.kptncook.com/recipe/pinterest/bb082a7",
      "http://mobile.kptncook.com/recipe/pinterest/3ac1047b",
      "http://mobile.kptncook.com/recipe/pinterest/73c683de",
      "http://mobile.kptncook.com/recipe/pinterest/37653916",
      "http://mobile.kptncook.com/recipe/pinterest/15e9a06f",
    ];

    var map = <String, int>{};
    for (var e in urls) {
      map.update(e, (value) => value + 1, ifAbsent: () => 1);
    }
    var duplicates = map.entries.where((element) => element.value > 1).toList();

    expect(
      duplicates.isEmpty,
      true,
      reason: "Duplicates:\n${duplicates.join(",\n")}",
    );

    var jobs = urls
        .map(
          (url) => RecipeController().createRecipeParsingJob(
            url: Uri.parse(url),
            servings: 2,
            language: "de",
          ),
        )
        .toList();

    var notWorkingUrls = <String>[];
    var results = <(RecipeParsingJob, Recipe)>[];
    for (var job in jobs) {
      var result = await RecipeController().collectRecipes(
        recipeParsingJobs: [job],
        language: job.language,
      ).then((value) => value.first);
      var recipe = result.recipe;
      if (hasRecipeParsingErrors(result) || recipe == null) {
        notWorkingUrls.add("${job.url}: ${result.logs.join(", ")}");
      } else {
        results.add((job, recipe));
      }
    }

    var recipeStrings = results.map((e) => allToJson(e.$1, e.$2)).toList();
    for (var i = 0; i < recipeStrings.length; i++) {
      var title = results[i].$1.url.toString().split("/").last;
      var fileName = "recipe${i.toString().padLeft(2, '0')}-$title";
      await write(recipeStrings[i], fileName);
    }
  });
}
