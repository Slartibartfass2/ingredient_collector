import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/models/domain/ingredient.dart';
import 'package:ingredient_collector/src/models/parsing/ingredient_parsing_result.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_controller.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart'
    show KptnCookParser;
import 'package:shared_preferences/shared_preferences.dart';

import 'parser_test_helper.dart';

void main() {
  const parser = KptnCookParser();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecipeCache().cache.clear();
  });

  IngredientParsingResult parseIngredient(Element ingredientElement) =>
      parser.parseIngredient(
        ingredientElement,
        1.0,
        Uri.parse("www.example.org"),
        "de",
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
    <div class="kptn-recipetitle">
      Example Recipe
    </div>
    """;
    const servingsElement = """
    <div class="kptn-person-count">
      2
    </div>
    """;
    const ingredientsElement = """
    <div class="col-md-offset-3">
      Ingredient Element
    </div>
    """;

    test(
      'When the recipe name element is missing, then parsing returns errors',
      () {
        var document = Document.html("""
        $servingsElement
        $ingredientsElement
        """);
        expectRecipeParsingErrors(parser, [document]);
      },
    );

    test(
      'When the servings element is missing, then parsing returns errors',
      () {
        var document = Document.html("""
        $recipeNameElement
        $ingredientsElement
        """);
        expectRecipeParsingErrors(parser, [document]);
      },
    );

    test(
      'When the ingredients element is missing, then parsing returns errors',
      () {
        var document1 = Document.html("""
        $recipeNameElement
        $servingsElement
        """);
        var document2 = Document.html("""
        $recipeNameElement
        $servingsElement
        <div class="col-md-offset-3">Title Element</div>
        <div class="col-md-offset-3">Description Element</div>
        <div class="col-md-offset-3">Ingredients Element</div>
        """);
        expectRecipeParsingErrors(parser, [document1, document2]);
      },
    );
  });

  group('Ingredient parsing', () {
    test('When empty element is parsed, then parsing returns errors', () {
      var ingredientElement = Element.html("<a></a>");
      var result = parseIngredient(ingredientElement);
      expect(hasIngredientParsingErrors(result), isTrue);
    });

    test(
      'When element with amount and unit is parsed, then parsing is '
      'successful',
      () {
        var ingredientElement = Element.html("""
        <div>
          <div class="kptn-ingredient-measure">
            30 g
          </div>
          <div class="kptn-ingredient">
            Walnusskerne
          </div>
        </div>
        """);
        var result = parseIngredient(ingredientElement);
        expect(hasIngredientParsingErrors(result), isFalse);
        expect(
          result.ingredients.first,
          equals(const Ingredient(amount: 30, unit: "g", name: "Walnusskerne")),
        );
      },
    );

    test(
      'When element with only amount is parsed, then parsing is successful',
      () {
        var ingredientElement = Element.html("""
        <div>
          <div class="kptn-ingredient-measure">
            0.5
          </div>
          <div class="kptn-ingredient">
            Brokkoli
          </div>
        </div>
        """);
        var result = parseIngredient(ingredientElement);
        expect(hasIngredientParsingErrors(result), isFalse);
        expect(
          result.ingredients.first,
          equals(const Ingredient(amount: 0.5, unit: "", name: "Brokkoli")),
        );
      },
    );

    test(
      'When element with invalid amount is parsed, then parsing returns '
      'errors',
      () {
        var ingredientElement = Element.html("""
        <div>
          <div class="kptn-ingredient-measure">
            measure
          </div>
          <div class="kptn-ingredient">
            Walnüsse
          </div>
        </div>
        """);
        var result = parseIngredient(ingredientElement);
        expect(hasIngredientParsingErrors(result), isTrue);
      },
    );
  });

  test(
    'When sharing url is parsed, then url is redirected and correct recipe '
    'parsed',
    () async {
      var recipeJob = RecipeController().createRecipeParsingJob(
        url: Uri.parse("http://mobile.kptncook.com/recipe/pinterest/4b596ab7"),
        servings: 2,
        language: "de",
      );

      var result = await RecipeController().collectRecipes(
        recipeParsingJobs: [recipeJob],
        language: "de",
      );
      var recipe = result.first.recipe!;

      var redirectJob = RecipeController().createRecipeParsingJob(
        url: Uri.parse("https://sharing.kptncook.com/uSnuwfRkhsb"),
        servings: 2,
        language: "de",
      );

      var redirectResult = await RecipeController().collectRecipes(
        recipeParsingJobs: [redirectJob],
        language: "de",
      );
      var redirectRecipe = redirectResult.first.recipe!;

      expect(recipe, equals(redirectRecipe));
    },
    tags: ["parsing-test"],
  );
}
