import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/job_logs/job_log.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/ingredient_parsing_result.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart'
    show EatThisParser;
import 'package:shared_preferences/shared_preferences.dart';

import 'parser_test_helper.dart';

void main() {
  const parser = EatThisParser();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecipeCache().cache.clear();
  });

  IngredientParsingResult parseIngredientOldDesign(Element ingredientElement) =>
      parser.parseIngredientOldDesign(
        ingredientElement,
        1.0,
        Uri.parse("www.example.org"),
        "de",
      );

  test(
    'When unsupported recipe is collected, then correct error is returned',
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

  group('Recipe parsing', () {
    const recipeNameElement = """
    <div class="entry-title">
      Example Recipe
    </div>
    """;
    const recipeContainerOld = """
    <div class="zutaten">
      <p>Zutaten für 2 Personen</p>
      <ul>
        <li>12 g Example Ingredient</li>
      </ul>
    </div>
  	""";

    test(
      'When the recipe name element is missing, then parsing returns errors',
      () {
        var document1 = Document.html("""
        $recipeContainerOld
        """);
        var document2 = Document.html("""
        $recipeContainerOld
        <div class="entry-title"></div>
        """);
        expectRecipeParsingErrors(parser, [document1, document2]);
      },
    );

    test(
      'When the recipe container is missing, then parsing returns errors',
      () {
        var document = Document.html("""
        $recipeNameElement
        """);
        expectRecipeParsingErrors(parser, [document]);
      },
    );

    test(
      'When the servings element is missing, then parsing returns errors',
      () {
        var document = Document.html("""
        $recipeNameElement
        <div class="zutaten">
          <ul>
            <li>12 g Example Ingredient</li>
          </ul>
        </div>
        """);
        expectRecipeParsingErrors(parser, [document]);
      },
    );

    test(
      'When the ingredients element is missing, then parsing returns errors',
      () {
        var document = Document.html("""
        $recipeNameElement
        <div class="zutaten">
          <ul>
            <li>12 g Example Ingredient</li>
          </ul>
        </div>
        """);
        expectRecipeParsingErrors(parser, [document]);
      },
    );
  });

  group('Ingredient parsing', () {
    test('When empty element is parsed, then parsing returns errors', () {
      var ingredientElement = Element.html("<a></a>");
      var result = parseIngredientOldDesign(ingredientElement);
      expect(hasIngredientParsingErrors(result), isTrue);
    });

    test(
      'When element with amount and unit is parsed, then parsing is '
      'successful (old design)',
      () {
        var ingredientElement = Element.html("""
        <li>
          1 1/2 EL Reis- oder Ahornsirup
        </li>
        """);
        var result = parseIngredientOldDesign(ingredientElement);
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
      },
    );
  });
}
