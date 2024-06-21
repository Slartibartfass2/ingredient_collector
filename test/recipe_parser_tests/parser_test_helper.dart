import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart' show expect, fail, isTrue;
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/job_logs/job_log.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/ingredient_parsing_result.dart';
import 'package:ingredient_collector/src/models/recipe.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_result.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart';

import 'models/parser_test_case.dart';
import 'models/parser_test_result.dart';

void expectIngredient(
  Recipe recipe,
  Ingredient ingredient,
) {
  var isInRecipe = recipe.ingredients.contains(ingredient);
  if (!isInRecipe) {
    fail("$ingredient was not found in the recipe '${recipe.name}'");
  }
}

bool hasRecipeParsingErrors(RecipeParsingResult result) =>
    result.logs.where((log) => log.type == JobLogType.error).isNotEmpty;

bool hasIngredientParsingErrors(IngredientParsingResult result) =>
    result.logs.where((log) => log.type == JobLogType.error).isNotEmpty;

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
    expectIngredient(recipe, ingredient);
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

RecipeParsingJob getExampleParsingJob() =>
    RecipeParsingJob(id: 1, url: Uri.parse("www.example.org"), servings: 2);

void expectRecipeParsingErrors(RecipeParser parser, List<Document> documents) {
  for (var document in documents) {
    var result = parser.parseRecipe(document, getExampleParsingJob());
    expect(hasRecipeParsingErrors(result), isTrue);
  }
}
