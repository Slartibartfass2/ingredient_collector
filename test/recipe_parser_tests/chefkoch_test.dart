import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/models/ingredient_parsing_result.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart'
    show ChefkochParser;
import 'package:shared_preferences/shared_preferences.dart';

import 'parser_test_helper.dart';

void main() {
  const parser = ChefkochParser();

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
      "./test/recipe_parser_tests/parser_test_files/chefkoch",
    ),
    timeout: const Timeout(Duration(minutes: 5)),
    tags: ["parsing-test"],
  );

  group('Recipe parsing', () {
    const recipeNameElement = """
    <div class="recipe-header">
      <h1>Example Recipe</h1>
    </div>
    """;
    const servingsElement = """
    <div class="recipe-servings">
      <input value="2">
    </div>
    """;
    const ingredientsElement = """
    <div class="ingredients">
      <table>
        <tr><td>Ingredient Element</td></tr>
      </table>
    </div>
    """;

    test(
      'When the recipe name element is missing, then parsing returns errors',
      () {
        var document1 = Document.html("""
        $servingsElement
        $ingredientsElement
        """);
        var document2 = Document.html("""
        <div class="recipe-header"> </div>
        $servingsElement
        $ingredientsElement
        """);
        expectRecipeParsingErrors(parser, [document1, document2]);
      },
    );

    test(
      'When the servings element is missing, then parsing returns errors',
      () {
        var document1 = Document.html("""
        $recipeNameElement
        $ingredientsElement
        """);
        var document2 = Document.html("""
        $recipeNameElement
        <div class="recipe-servings"> </div>
        $ingredientsElement
        """);
        var document3 = Document.html("""
        $recipeNameElement
        <div class="recipe-servings">
          <input>
        </div>
        $ingredientsElement
        """);
        var document4 = Document.html("""
        $recipeNameElement
        <div class="recipe-servings">
          <input value="invalid_value">
        </div>
        $ingredientsElement
        """);
        expectRecipeParsingErrors(parser, [
          document1,
          document2,
          document3,
          document4,
        ]);
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
        <div class="ingredients"> </div>
        """);
        var document3 = Document.html("""
        $recipeNameElement
        $servingsElement
        <div class="ingredients">
          <table>
          </table>
        </div>
        """);
        expectRecipeParsingErrors(parser, [document1, document2, document3]);
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
        <tr>
          <td>
            <span>200  ml   </span>
          </td>
          <td>
            <span>Weißwein, trockener </span>
          </td>
        </tr>
        """);
        var result = parseIngredient(ingredientElement);
        expect(hasIngredientParsingErrors(result), isFalse);
        expect(
          result.ingredients.first,
          equals(
            const Ingredient(
              amount: 200,
              unit: "ml",
              name: "Weißwein, trockener",
            ),
          ),
        );
      },
    );

    test(
      'When element with only amount is parsed, then parsing is successful',
      () {
        var ingredientElement = Element.html("""
        <tr>
          <td>
            <span> ½ </span>
          </td>
          <td>
            <span>Zitrone(n), Saft davon </span>
          </td>
        </tr>
        """);
        var result = parseIngredient(ingredientElement);
        expect(hasIngredientParsingErrors(result), isFalse);
        expect(
          result.ingredients.first,
          equals(
            const Ingredient(
              amount: 0.5,
              unit: "",
              name: "Zitrone(n), Saft davon",
            ),
          ),
        );
      },
    );
  });
}
