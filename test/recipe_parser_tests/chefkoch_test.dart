import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'parser_test_helper.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecipeCache().cache.clear();
  });

  test(
    'When test files are parsed, then expected results are met',
    () async => testParsingTestFiles(
      "./test/recipe_parser_tests/parser_test_files/chefkoch",
    ),
    timeout: const Timeout(Duration(minutes: 5)),
    tags: ["parsing-test"],
  );

  group('Ingredient parsing', () {
    test('When empty element is parsed, then parsing returns errors', () {
      var parser = const ChefkochParser();
      var ingredientElement = Element.html("<a></a>");
      var result = parser.parseIngredient(
        ingredientElement,
        1,
        Uri.parse("www.example.org"),
        "de",
      );
      expect(hasIngredientParsingErrors(result), isTrue);
    });

    test(
      'When element with amount and unit is parsed, then parsing is '
      'successful',
      () {
        var parser = const ChefkochParser();
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
        var result = parser.parseIngredient(
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
        var parser = const ChefkochParser();
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
        var result = parser.parseIngredient(
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
              unit: "",
              name: "Zitrone(n), Saft davon",
            ),
          ),
        );
      },
    );
  });
}