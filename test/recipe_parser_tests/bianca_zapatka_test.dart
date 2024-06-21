import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:ingredient_collector/src/recipe_parser/recipe_parser.dart'
    show BiancaZapatkaParser;
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
      "./test/recipe_parser_tests/parser_test_files/bianca_zapatka",
    ),
    timeout: const Timeout(Duration(minutes: 5)),
    tags: ["parsing-test"],
  );

  test('parse empty ingredient element', () {
    var parser = const BiancaZapatkaParser();
    var ingredientElement = Element.html("<a></a>");
    var result = parser.parseIngredient(
      ingredientElement,
      1,
      Uri.parse("www.example.org"),
      "de",
    );
    expect(hasIngredientParsingErrors(result), isTrue);
  });

  test('parse ingredient element with amount and unit', () {
    var parser = const BiancaZapatkaParser();
    var ingredientElement = Element.html("""
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">ca. 24,5</span>
      <span class="wprm-recipe-ingredient-unit">ml</span>
      <span class="wprm-recipe-ingredient-name">Gemüsebrühe</span>
    </li>
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
      equals(const Ingredient(amount: 24.5, unit: "ml", name: "Gemüsebrühe")),
    );
  });

  test('parse ingredient element with amount and no unit', () {
    var parser = const BiancaZapatkaParser();
    var ingredientElement = Element.html("""
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">½</span>
      <span class="wprm-recipe-ingredient-name">Blumenkohl</span>
    </li>
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
      equals(const Ingredient(amount: 0.5, unit: "", name: "Blumenkohl")),
    );
  });

  test('provide feedback when amount parsing fails', () {
    var parser = const BiancaZapatkaParser();
    var ingredientElement = Element.html("""
    <li class="wprm-recipe-ingredient">
      <span class="wprm-recipe-ingredient-amount">amount</span>
      <span class="wprm-recipe-ingredient-name">Blumenkohl</span>
    </li>
    """);
    var result = parser.parseIngredient(
      ingredientElement,
      1,
      Uri.parse("www.example.org"),
      "de",
    );
    expect(hasIngredientParsingErrors(result), isTrue);
  });
}
