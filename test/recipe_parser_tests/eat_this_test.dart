import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/job_logs/job_log.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart'
    show EatThisParser;
import 'package:shared_preferences/shared_preferences.dart';

import 'parser_test_helper.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecipeCache().cache.clear();
  });

  test(
    'collect unsupported Eat this! recipe',
    () async {
      var recipeJob = RecipeController().createRecipeParsingJob(
        url: Uri.parse(
          "https://www.eat-this.org/veganes-raclette/",
        ),
        servings: 4,
        language: "de",
      );

      var result = await RecipeController().collectRecipes(
        recipeParsingJobs: [recipeJob],
        language: "de",
      );
      expect(result.length, 1);
      expect(hasRecipeParsingErrors(result.first), isTrue);
      expect(
        result.first.logs.any(
          (log) =>
              log is SimpleJobLog &&
              log.subType == JobLogSubType.deliberatelyNotSupportedUrl,
        ),
        isTrue,
      );
    },
    tags: ["parsing-test"],
  );

  test(
    'When test files are parsed, then expected results are met',
    () async => testParsingTestFiles(
      "./test/recipe_parser_tests/parser_test_files/eat_this",
    ),
    timeout: const Timeout(Duration(minutes: 5)),
    tags: ["parsing-test"],
  );

  test('parse empty ingredient element new design', () {
    var parser = const EatThisParser();
    var ingredientElement = Element.html("<a></a>");
    var result = parser.parseIngredientNewDesign(
      ingredientElement,
      1,
      Uri.parse("www.example.org"),
      "de",
    );
    expect(hasIngredientParsingErrors(result), isTrue);
  });

  test('parse empty ingredient element old design', () {
    var parser = const EatThisParser();
    var ingredientElement = Element.html("<a></a>");
    var result = parser.parseIngredientOldDesign(
      ingredientElement,
      1,
      Uri.parse("www.example.org"),
      "de",
    );
    expect(hasIngredientParsingErrors(result), isTrue);
  });

  test('parse ingredient element new design', () {
    var parser = const EatThisParser();
    var ingredientElement = Element.html("""
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">½</span>
      <span class="wprm-recipe-ingredient-unit">TL</span>
      <span class="wprm-recipe-ingredient-name">Zucker</span>
    </li>
    """);
    var result = parser.parseIngredientNewDesign(
      ingredientElement,
      1,
      Uri.parse("www.example.org"),
      "de",
    );
    expect(hasIngredientParsingErrors(result), isFalse);
    expect(
      result.ingredients.first,
      equals(
        const Ingredient(
          amount: 0.5,
          unit: "TL",
          name: "Zucker",
        ),
      ),
    );
  });

  test('parse ingredient element old design', () {
    var parser = const EatThisParser();
    var ingredientElement = Element.html("""
    <li>
      1 1/2 EL Reis- oder Ahornsirup
    </li>
    """);
    var result = parser.parseIngredientOldDesign(
      ingredientElement,
      1,
      Uri.parse("www.example.org"),
      "de",
    );
    expect(hasIngredientParsingErrors(result), isFalse);
    expect(
      result.ingredients.first,
      equals(
        const Ingredient(
          amount: 1.5,
          unit: "EL",
          name: "Reis- oder Ahornsirup",
        ),
      ),
    );
  });

  test('provide feedback when amount parsing fails', () {
    var parser = const EatThisParser();
    var ingredientElement = Element.html("""
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">amount</span>
      <span class="wprm-recipe-ingredient-name">Blumenkohl</span>
    </li>
    """);
    var result = parser.parseIngredientNewDesign(
      ingredientElement,
      1,
      Uri.parse("www.example.org"),
      "de",
    );
    expect(hasIngredientParsingErrors(result), isTrue);
  });
}
