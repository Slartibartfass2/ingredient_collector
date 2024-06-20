import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart' show expect, fail;
import 'package:ingredient_collector/src/job_logs/job_log.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/ingredient_parsing_result.dart';
import 'package:ingredient_collector/src/models/recipe.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_result.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';

import 'models/parser_test_case.dart';
import 'models/parser_test_result.dart';

void expectIngredient(
  Recipe recipe,
  String name, {
  double amount = 0.0,
  String unit = "",
}) =>
    expectIngredient2(
      recipe,
      Ingredient(amount: amount, unit: unit, name: name),
    );

void expectIngredient2(
  Recipe recipe,
  Ingredient ingredient,
) {
  var isInRecipe = recipe.ingredients.contains(ingredient);
  if (!isInRecipe) {
    fail("$ingredient was not found in the recipe");
  }
}

bool hasRecipeParsingErrors(RecipeParsingResult result) =>
    result.logs.where((log) => log.type == JobLogType.error).isNotEmpty;

bool hasIngredientParsingErrors(IngredientParsingResult result) =>
    result.logs.where((log) => log.type == JobLogType.error).isNotEmpty;

Future<void> testParsingRecipes(
  List<String> urls, {
  required String language,
}) async {
  var jobs = urls
      .map(
        (url) => RecipeController().createRecipeParsingJob(
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
      notWorkingUrls.add("${job.url}: ${result.logs.join(", ")}");
    }
  }

  if (notWorkingUrls.isNotEmpty) {
    fail("The following recipes failed:\n${notWorkingUrls.join("\n")}");
  }
}

Future<ParserTestCase> _getTestFromFile(String path) async {
  var file = File(path);
  var content = await file.readAsString();
  var json = jsonDecode(content);
  return ParserTestCase.fromJson(json);
}

Future<List<ParserTestCase>> _getTestsFromDirectory(String directory) async {
  var files = Directory(directory).listSync();
  var tests = <ParserTestCase>[];
  for (var file in files) {
    var test = await _getTestFromFile(file.path);
    tests.add(test);
  }
  return tests;
}

void _testParserTest(RecipeParsingResult result, ParserTestResult expected) {
  if (hasRecipeParsingErrors(result) || result.recipe == null) {
    fail("The recipe failed to parse: ${result.logs.join(", ")}");
  }
  var recipe = result.recipe!;
  expect(recipe.name, expected.name);
  expect(recipe.ingredients.length, expected.ingredients.length);
  for (var ingredient in expected.ingredients) {
    expectIngredient2(recipe, ingredient);
  }
}

Future<void> testParsingTestFiles(String directory) async {
  var tests = await _getTestsFromDirectory(directory);
  var jobs = tests.map(
    (test) => RecipeController().createRecipeParsingJob(
      url: Uri.parse(test.request.url),
      servings: test.request.servings,
      language: "de",
    ),
  );
  var expectedResults = tests.map((test) => test.result).toList();

  var results = await RecipeController().collectRecipes(
    recipeParsingJobs: jobs,
    language: "de",
  );
  var resultsList = results.toList();

  for (var i = 0; i < resultsList.length; i++) {
    var result = resultsList[i];
    var expected = expectedResults[i];
    _testParserTest(result, expected);
  }
}
