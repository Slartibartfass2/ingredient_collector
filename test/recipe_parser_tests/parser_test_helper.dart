import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart' show expect, fail, isTrue;
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/helper/levenshtein.dart';
import 'package:ingredient_collector/src/job_logs/job_log.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/ingredient_parsing_result.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_job.dart';
import 'package:ingredient_collector/src/models/recipe_parsing_result.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart';

import 'models/parser_test_case.dart';
import 'models/parser_test_result.dart';

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

/// A [ParserTestCase] paired with the path of the file it was read from.
typedef _PathedTestCase = (String path, ParserTestCase testCase);

Future<List<_PathedTestCase>> _getTestsFromDirectory(String directory) async {
  var files = Directory(directory).listSync();
  var tests = <_PathedTestCase>[];
  for (var file in files) {
    var test = await _getTestFromFile(file.path);
    tests.add((file.path, test));
  }
  return tests;
}

/// Returns an error message describing how [result] doesn't match [expected],
/// or `null` if they match.
String? _getParserTestFailureMessage(RecipeParsingResult result, ParserTestResult expected) {
  if (hasRecipeParsingErrors(result) || result.recipe == null) {
    return "The recipe failed to parse: ${result.logs.join(", ")}";
  }
  var recipe = result.recipe!;

  if (recipe.name != expected.name) {
    return "Actual recipe name '${recipe.name}' didn't match the expected name"
        " '${expected.name}'";
  }

  if (recipe.ingredients.length != expected.ingredients.length) {
    return "Number of ingredients of recipe '${recipe.name}' didn't match:\n"
        "- actual: [${recipe.ingredients.map((e) => "'${e.name}'").join(", ")}]\n"
        "- expected: [${expected.ingredients.map((e) => "'${e.name}'").join(", ")}]";
  }

  // Check expected for missing ingredients in actual
  var missingExpected = <Ingredient>[];
  for (var ingredient in expected.ingredients) {
    var isInActual = _containsIngredient(recipe.ingredients, ingredient);
    if (!isInActual) {
      missingExpected.add(ingredient);
    }
  }

  // Check actual for missing ingredients in expected
  var missingActual = <Ingredient>[];
  for (var ingredient in recipe.ingredients) {
    var isInExpected = _containsIngredient(expected.ingredients, ingredient);
    if (!isInExpected) {
      missingActual.add(ingredient);
    }
  }

  var message = "";

  if (missingExpected.isNotEmpty) {
    var missingExpectedIngredientsString = missingExpected.map((e) => "- $e").join("\n");
    message +=
        "The following ingredients weren't found in the actual recipe "
        "'${result.recipe?.name}':\n$missingExpectedIngredientsString";
  }

  if (missingActual.isNotEmpty) {
    if (message.isNotEmpty) message += "\n";
    var missingActualIngredientsString = missingActual.map((e) => "- $e").join("\n");
    message +=
        "The following ingredients weren't found in the expected recipe "
        "'${result.recipe?.name}':\n$missingActualIngredientsString";
  }

  return message.isEmpty ? null : message;
}

bool _containsIngredient(List<Ingredient> ingredients, Ingredient ingredient) {
  if (ingredients.isEmpty) return false;

  var hasExactMatch = ingredients.contains(ingredient);
  if (hasExactMatch) return true;

  var ingredientsByDistance =
      ingredients.map((ing) => (ing, relativeLevenshtein(ing.name, ingredient.name))).toList()
        ..sort((a, b) => a.$2.compareTo(b.$2));

  var (bestMatch, distance) = ingredientsByDistance.first;

  // If the similarity is smaller than 85%, we consider the ingredients non-equal
  if (distance < 0.85) return false;

  return bestMatch.amount == ingredient.amount && bestMatch.unit == ingredient.unit;
}

Future<void> testParsingTestFiles(String directory) async {
  var tests = await _getTestsFromDirectory(directory);
  var jobs = tests.map(
    (entry) => RecipeController().createRecipeParsingJob(
      url: Uri.parse(entry.$2.request.url),
      servings: entry.$2.request.servings,
      language: "de",
    ),
  );

  var results = await RecipeController().collectRecipes(recipeParsingJobs: jobs, language: "de");
  var resultsList = results.toList();

  var failureMessages = <String>[];
  for (var i = 0; i < resultsList.length; i++) {
    var (path, testCase) = tests[i];
    var failureMessage = _getParserTestFailureMessage(resultsList[i], testCase.result);
    if (failureMessage != null) {
      failureMessages.add("$path:\n$failureMessage");
    }
  }

  if (failureMessages.isNotEmpty) {
    fail(
      "${failureMessages.length} of ${resultsList.length} test file(s) failed:\n\n"
      "${failureMessages.join("\n\n")}",
    );
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
