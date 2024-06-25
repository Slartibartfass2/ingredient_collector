import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/models/domain/ingredient.dart';
import 'package:ingredient_collector/src/models/parsing/ingredient_parsing_result.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart'
    show WordPressParser;
import 'package:shared_preferences/shared_preferences.dart';

import 'parser_test_helper.dart';

void main() {
  const parser = WordPressParser();

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

  group('Recipe parsing', () {
    const recipeNameElement = """
    <div class="wprm-recipe-name">
      Example Recipe
    </div>
    """;
    const servingsElement = """
    <div class="wprm-recipe-servings">
      2
    </div>
    """;
    const ingredientsElement = """
    <div class="wprm-recipe-ingredient">
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
        var document = Document.html("""
        $recipeNameElement
        $servingsElement
        """);
        expectRecipeParsingErrors(parser, [document]);
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
        <li class="wprm-recipe-ingredient">
          <span class="wprm-recipe-ingredient-amount">ca. 24,5</span>
          <span class="wprm-recipe-ingredient-unit">ml</span>
          <span class="wprm-recipe-ingredient-name">Gemüsebrühe</span>
        </li>
        """);
        var result = parseIngredient(ingredientElement);
        expect(hasIngredientParsingErrors(result), isFalse);
        expect(
          result.ingredients.first,
          equals(
            const Ingredient(amount: 24.5, unit: "ml", name: "Gemüsebrühe"),
          ),
        );
      },
    );

    test(
      'When element with only amount is parsed, then parsing is successful',
      () {
        var ingredientElement = Element.html("""
        <li class="wprm-recipe-ingredient">
          <span class="wprm-recipe-ingredient-amount">½</span>
          <span class="wprm-recipe-ingredient-name">Blumenkohl</span>
        </li>
        """);
        var result = parseIngredient(ingredientElement);
        expect(hasIngredientParsingErrors(result), isFalse);
        expect(
          result.ingredients.first,
          equals(const Ingredient(amount: 0.5, unit: "", name: "Blumenkohl")),
        );
      },
    );

    test(
      'When element with invalid amount is parsed, then parsing returns '
      'errors',
      () {
        var ingredientElement = Element.html("""
        <li class="wprm-recipe-ingredient">
          <span class="wprm-recipe-ingredient-amount">amount</span>
          <span class="wprm-recipe-ingredient-name">Blumenkohl</span>
        </li>
        """);
        var result = parseIngredient(ingredientElement);
        expect(hasIngredientParsingErrors(result), isTrue);
      },
    );
  });
}
